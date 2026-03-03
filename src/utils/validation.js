const { createTranslator } = require("../i18n");

function toNumber(value) {
  if (value === "" || value === null || value === undefined) return null;
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
}

function validateField(field, rawValue, t) {
  const errors = [];
  const value = rawValue === undefined || rawValue === null ? "" : rawValue;

  if (field.required && String(value).trim() === "") {
    errors.push(t("validation.required"));
    return errors;
  }

  if (String(value).trim() === "") {
    return errors;
  }

  if (field.type === "number") {
    const num = toNumber(value);
    if (num === null) {
      errors.push(t("validation.invalidNumber"));
      return errors;
    }
    if (field.validation && typeof field.validation.min === "number" && num < field.validation.min) {
      errors.push(t("validation.minValue", { value: field.validation.min }));
    }
    if (field.validation && typeof field.validation.max === "number" && num > field.validation.max) {
      errors.push(t("validation.maxValue", { value: field.validation.max }));
    }
  }

  if (field.validation && field.validation.pattern) {
    const re = new RegExp(field.validation.pattern);
    if (!re.test(String(value))) {
      errors.push(field.validation.patternMessage || t("validation.invalidFormat"));
    }
  }

  if ((field.type === "select" || field.type === "radio") && Array.isArray(field.options) && field.options.length > 0) {
    if (!field.options.includes(String(value))) {
      errors.push(t("validation.invalidSelection"));
    }
  }

  return errors;
}

function validateSection(section, payload, lang) {
  const errors = {};
  const t = createTranslator(lang);
  (section.fields || []).forEach((field) => {
    const fieldErrors = validateField(field, payload[field.id], t);
    if (fieldErrors.length > 0) {
      errors[field.id] = fieldErrors;
    }
  });
  return errors;
}

module.exports = {
  validateSection
};
