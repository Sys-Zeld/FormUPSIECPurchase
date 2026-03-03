const fs = require("fs");
const path = require("path");
const pdf = require("pdf-parse");

const inputPath = process.argv[2] || path.join(process.cwd(), "assets", "IEC62040-3.pdf");
const outputPath = path.join(process.cwd(), "src", "schema", "annexD.purchaseTable.json");
const fallbackPath = path.join(process.cwd(), "src", "schema", "annexD.purchaseTable.seed.json");

function normalizeId(value) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

function buildSchemaFromText(text) {
  const idx = text.toLowerCase().indexOf("table d.1");
  if (idx < 0) return null;
  const tableText = text.slice(idx, Math.min(text.length, idx + 7000));
  const lines = tableText
    .split(/\r?\n/)
    .map((l) => l.trim())
    .filter(Boolean);

  const sections = [];
  let current = null;

  lines.forEach((line) => {
    if (/^D\.\d+/.test(line) && /[A-Za-z]/.test(line)) {
      const title = line.replace(/^D\.\d+\s*/, "");
      current = {
        id: normalizeId(title),
        title,
        description: "Extracted automatically from Annex D purchase table.",
        fields: []
      };
      sections.push(current);
      return;
    }
    if (!current) return;
    if (/^[A-Za-z].{2,}$/.test(line) && line.length < 140 && !/IEC 62040-3/i.test(line)) {
      const id = normalizeId(line);
      if (id && !current.fields.some((f) => f.id === id)) {
        current.fields.push({
          id,
          label: line,
          type: "text",
          required: false,
          unit: "",
          help: ""
        });
      }
    }
  });

  return sections.length > 0 ? { sections } : null;
}

async function main() {
  if (!fs.existsSync(inputPath)) {
    fs.copyFileSync(fallbackPath, outputPath);
    // eslint-disable-next-line no-console
    console.log(`PDF not found at ${inputPath}. Fallback schema copied.`);
    return;
  }

  const buffer = fs.readFileSync(inputPath);
  const parsed = await pdf(buffer);
  const generated = buildSchemaFromText(parsed.text);

  if (!generated || !generated.sections || generated.sections.length === 0) {
    fs.copyFileSync(fallbackPath, outputPath);
    // eslint-disable-next-line no-console
    console.log("Automatic extraction failed. Fallback schema copied.");
    return;
  }

  fs.writeFileSync(outputPath, `${JSON.stringify(generated, null, 2)}\n`, "utf8");
  // eslint-disable-next-line no-console
  console.log(`Schema extracted to ${outputPath}`);
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(err);
  process.exit(1);
});
