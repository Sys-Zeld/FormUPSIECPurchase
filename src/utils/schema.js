const fs = require("fs");
const path = require("path");

const schemaPath = path.join(process.cwd(), "src", "schema", "annexD.purchaseTable.json");

function loadSchema() {
  const raw = fs.readFileSync(schemaPath, "utf8");
  const parsed = JSON.parse(raw);
  return parsed.sections || [];
}

function resolveLocalizedText(value, lang) {
  if (value && typeof value === "object" && !Array.isArray(value)) {
    return value[lang] || value.pt || value.en || "";
  }
  return value || "";
}

function localizeSections(sections, lang) {
  return (sections || []).map((section) => ({
    ...section,
    title: resolveLocalizedText(section.title, lang),
    description: resolveLocalizedText(section.description, lang),
    fields: (section.fields || []).map((field) => {
      const optionDisplay = {};
      (field.options || []).forEach((opt) => {
        const translated =
          field.optionLabels && field.optionLabels[opt]
            ? resolveLocalizedText(field.optionLabels[opt], lang)
            : resolveLocalizedText(opt, lang);
        optionDisplay[opt] = translated || opt;
      });
      return {
        ...field,
        label: resolveLocalizedText(field.label, lang),
        help: resolveLocalizedText(field.help, lang),
        optionDisplay
      };
    })
  }));
}

function flattenFields(sections) {
  const fields = [];
  sections.forEach((section) => {
    (section.fields || []).forEach((field) => {
      fields.push({
        ...field,
        sectionId: section.id,
        sectionTitle: resolveLocalizedText(section.title, "pt") || resolveLocalizedText(section.title, "en")
      });
    });
  });
  return fields;
}

module.exports = {
  loadSchema,
  localizeSections,
  flattenFields
};
