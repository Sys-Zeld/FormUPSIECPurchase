const fs = require("fs");
const path = require("path");

function normalizeMode(rawMode) {
  const value = String(rawMode || "").trim().toLowerCase();
  if (["enable", "on", "true", "1"].includes(value)) return "enable";
  if (["disable", "off", "false", "0"].includes(value)) return "disable";
  return "";
}

function upsertEnvVar(content, key, value) {
  const lineBreak = content.includes("\r\n") ? "\r\n" : "\n";
  const lines = content.split(/\r?\n/);
  const targetPrefix = `${key}=`;
  let replaced = false;

  const updatedLines = lines.map((line) => {
    if (line.startsWith(targetPrefix)) {
      replaced = true;
      return `${key}=${value}`;
    }
    return line;
  });

  if (!replaced) {
    if (updatedLines.length && updatedLines[updatedLines.length - 1] !== "") {
      updatedLines.push("");
    }
    updatedLines.push(`${key}=${value}`);
  }

  return updatedLines.join(lineBreak);
}

function run() {
  const mode = normalizeMode(process.argv[2]);
  if (!mode) {
    // eslint-disable-next-line no-console
    console.error("Uso: node scripts/module-spec-toggle.js <enable|disable>");
    process.exit(1);
  }

  const envFilePath = path.join(process.cwd(), ".env");
  const currentContent = fs.existsSync(envFilePath)
    ? fs.readFileSync(envFilePath, "utf8")
    : "";

  const enabled = mode === "enable";
  const nextContent = upsertEnvVar(currentContent, "MODULE_SPEC_ENABLED", enabled ? "true" : "false");
  fs.writeFileSync(envFilePath, nextContent, "utf8");

  // eslint-disable-next-line no-console
  console.log(`MODULE_SPEC_ENABLED=${enabled ? "true" : "false"} (${enabled ? "ativado" : "desativado"}).`);
  process.exit(0);
}

run();
