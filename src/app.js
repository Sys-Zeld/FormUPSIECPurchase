const path = require("path");
const crypto = require("crypto");
const express = require("express");
const helmet = require("helmet");
const cookieParser = require("cookie-parser");
const csrf = require("csurf");
const rateLimit = require("express-rate-limit");
const dayjs = require("dayjs");

const env = require("./config/env");
const { migrate } = require("./db/migrate");
const { sanitizeInput } = require("./utils/sanitize");
const { SUPPORTED_LANGS, DEFAULT_LANG, normalizeLang, createTranslator } = require("./i18n");
const { buildSubmissionQrPayload } = require("./services/qr");
const { generatePdfBuffer } = require("./services/pdf");
const { sendSubmissionEmail } = require("./services/email");
const {
  SECTION_ORDER,
  FIELD_TYPES,
  parseBooleanInput,
  validateTypedValue,
  listFields,
  listSectionsWithFields,
  getFieldById,
  createField,
  updateField,
  deleteField
} = require("./services/fields");
const { seedAnnexDFields } = require("./services/fieldSeed");
const {
  createEquipment,
  listEquipments,
  getEquipmentById,
  getEquipmentByToken,
  updateEquipmentStatus,
  deleteEquipmentById
} = require("./services/equipments");
const { getEquipmentSpecification, saveEquipmentSpecification } = require("./services/specifications");
const { listProfiles, getProfileById, getProfileFieldIds, createProfile } = require("./services/profiles");

const app = express();
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

app.use(helmet({ contentSecurityPolicy: false }));
app.use(express.urlencoded({ extended: false }));
app.use(express.json());
app.use(cookieParser());
app.use("/public", express.static(path.join(__dirname, "public")));

const supportedLangSet = new Set(SUPPORTED_LANGS);
const csrfProtection = csrf({ cookie: true });
const asyncHandler = (handler) => (req, res, next) => Promise.resolve(handler(req, res, next)).catch(next);

function resolveLanguage(req) {
  const queryLang = normalizeLang(req.query.lang);
  if (req.query.lang && supportedLangSet.has(queryLang)) return queryLang;
  const cookieLang = normalizeLang(req.cookies.lang);
  if (req.cookies.lang && supportedLangSet.has(cookieLang)) return cookieLang;
  const acceptLanguage = req.headers["accept-language"];
  if (acceptLanguage) {
    const headerLang = normalizeLang(acceptLanguage.split(",")[0]);
    if (supportedLangSet.has(headerLang)) return headerLang;
  }
  return DEFAULT_LANG;
}

app.use((req, res, next) => {
  const lang = resolveLanguage(req);
  if (normalizeLang(req.cookies.lang) !== lang) {
    res.cookie("lang", lang, { sameSite: "lax", maxAge: 365 * 24 * 60 * 60 * 1000 });
  }
  req.lang = lang;
  req.t = createTranslator(lang);
  res.locals.lang = lang;
  res.locals.t = req.t;
  res.locals.currentPath = req.path;
  next();
});

function signAdminSessionPayload(payload) {
  return crypto.createHmac("sha256", env.admin.sessionSecret).update(payload).digest("hex");
}

function createAdminSessionToken(username) {
  const payload = `${username}.${Date.now()}`;
  const signature = signAdminSessionPayload(payload);
  return Buffer.from(`${payload}.${signature}`).toString("base64url");
}

function isValidAdminSessionToken(token) {
  if (!token) return false;
  let raw;
  try {
    raw = Buffer.from(token, "base64url").toString("utf8");
  } catch (_err) {
    return false;
  }
  const parts = raw.split(".");
  if (parts.length < 3) return false;
  const signature = parts.pop();
  const payload = parts.join(".");
  const expectedSignature = signAdminSessionPayload(payload);
  const sigA = Buffer.from(signature);
  const sigB = Buffer.from(expectedSignature);
  if (sigA.length !== sigB.length) return false;
  return crypto.timingSafeEqual(sigA, sigB);
}

function requireAdminAuth(req, res, next) {
  if (isValidAdminSessionToken(req.cookies.admin_session)) return next();
  return res.redirect("/admin/login");
}

async function resolveEquipmentByTokenOr404(req, res) {
  const equipment = await getEquipmentByToken(req.params.token);
  if (!equipment) {
    res.status(404).send(req.t("app.submissionNotFound"));
    return null;
  }
  return equipment;
}

function parseFieldPayloadFromBody(body) {
  const enumLines = String(body.enum_options || "")
    .split(/\r?\n/)
    .map((line) => sanitizeInput(line))
    .filter(Boolean);
  const hasDefault = parseBooleanInput(body.has_default) === true;
  return {
    key: sanitizeInput(body.key),
    label: sanitizeInput(body.label),
    section: sanitizeInput(body.section),
    fieldType: sanitizeInput(body.field_type),
    unit: sanitizeInput(body.unit),
    enumOptions: enumLines,
    hasDefault,
    defaultValue: hasDefault ? sanitizeInput(body.default_value) : null
  };
}

function parseSelectedFieldIds(input) {
  const source = Array.isArray(input) ? input : [input];
  const unique = new Set();
  source.forEach((item) => {
    const parsed = Number(sanitizeInput(item));
    if (Number.isInteger(parsed) && parsed > 0) {
      unique.add(parsed);
    }
  });
  return Array.from(unique);
}

async function renderAdminFieldsPage(req, res, options = {}) {
  const groupedMap = await listSectionsWithFields();
  const presentSections = Object.keys(groupedMap).filter((section) => !SECTION_ORDER.includes(section));
  const sectionNames = [...SECTION_ORDER, ...presentSections];
  const sections = sectionNames
    .map((name) => ({ name, fields: groupedMap[name] || [] }))
    .filter((item) => item.fields.length > 0 || item.name === options.formValues?.section);

  res.status(options.statusCode || 200).render("admin-fields", {
    pageTitle: req.t("admin.fieldsTitle"),
    sections,
    sectionNames: [...SECTION_ORDER, ...presentSections],
    fieldTypes: Array.from(FIELD_TYPES),
    editingFieldId: options.editingFieldId || "",
    formValues: options.formValues || {
      key: "",
      label: "",
      section: SECTION_ORDER[0],
      field_type: "text",
      unit: "",
      enum_options: "",
      has_default: false,
      default_value: ""
    },
    errors: options.errors || {},
    saved: req.query.saved === "1",
    deleted: req.query.deleted === "1",
    csrfToken: req.csrfToken()
  });
}

async function renderAdminNewClientPage(req, res, options = {}) {
  const groupedMap = await listSectionsWithFields();
  const presentSections = Object.keys(groupedMap).filter((section) => !SECTION_ORDER.includes(section));
  const sectionNames = [...SECTION_ORDER, ...presentSections];
  const sections = sectionNames
    .map((name) => ({ name, fields: groupedMap[name] || [] }))
    .filter((item) => item.fields.length > 0);
  const profiles = await listProfiles();
  const profileFieldPairs = await Promise.all(
    profiles.map(async (profile) => [String(profile.id), await getProfileFieldIds(profile.id)])
  );
  const profileFieldMap = Object.fromEntries(profileFieldPairs);
  const allFieldIds = sections.flatMap((section) => section.fields.map((field) => field.id));
  const selectedFieldIds = Array.isArray(options.selectedFieldIds) ? options.selectedFieldIds : allFieldIds;

  res.status(options.statusCode || 200).render("admin-new-client", {
    pageTitle: req.t("admin.newClientTitle"),
    values: options.values || {
      purchaser: "",
      purchaser_contact: "",
      profile_id: "",
      profile_name: ""
    },
    errors: options.errors || {},
    sections,
    profiles,
    profileFieldMap,
    selectedFieldIds,
    csrfToken: req.csrfToken()
  });
}

function buildSpecificationRenderModel(specification, submittedValues = {}) {
  return specification.sections.map((section) => ({
    section: section.section,
    fields: section.fields.map((field) => {
      const rawSubmitted = Object.prototype.hasOwnProperty.call(submittedValues, field.id)
        ? submittedValues[field.id]
        : undefined;
      const displayValue = rawSubmitted !== undefined ? rawSubmitted : field.effectiveValue;
      return {
        ...field,
        displayValue: displayValue === null || displayValue === undefined ? "" : displayValue,
        cameFromDefault: rawSubmitted === undefined && field.valueSource === "default"
      };
    })
  }));
}

function parseSpecificationFormBody(fields, body) {
  const values = {};
  const submittedValues = {};
  const errors = {};

  fields.forEach((field) => {
    const key = `field_${field.id}`;
    const raw = body[key];
    const safe = sanitizeInput(raw);
    submittedValues[field.id] = safe;
    try {
      const normalized = validateTypedValue(field, safe, true);
      values[field.id] = normalized.hasValue ? normalized.value : "";
    } catch (err) {
      errors[field.id] = err.message;
    }
  });

  return { values, submittedValues, errors };
}

app.get("/", (req, res) => {
  res.redirect("/admin/tokens");
});

app.get("/admin/login", csrfProtection, (req, res) => {
  res.render("admin-login", {
    pageTitle: req.t("admin.loginTitle"),
    invalidCredentials: req.query.error === "1",
    csrfToken: req.csrfToken()
  });
});

app.post("/admin/login", csrfProtection, (req, res) => {
  const username = sanitizeInput(req.body.username);
  const password = sanitizeInput(req.body.password);
  if (username !== env.admin.user || password !== env.admin.pass) {
    return res.redirect("/admin/login?error=1");
  }
  res.cookie("admin_session", createAdminSessionToken(username), {
    httpOnly: true,
    sameSite: "lax",
    secure: false,
    maxAge: 12 * 60 * 60 * 1000
  });
  return res.redirect("/admin/tokens");
});

app.post("/admin/logout", csrfProtection, (req, res) => {
  res.clearCookie("admin_session");
  return res.redirect("/admin/login");
});

app.get("/admin/tokens", csrfProtection, requireAdminAuth, asyncHandler(async (req, res) => {
  const rows = await listEquipments();
  res.render("admin-tokens", {
    pageTitle: req.t("admin.pageTitle"),
    rows,
    deleted: req.query.deleted === "1",
    csrfToken: req.csrfToken()
  });
}));

app.post("/admin/tokens/:id/delete", csrfProtection, requireAdminAuth, asyncHandler(async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).send(req.t("admin.invalidId"));
  }
  await deleteEquipmentById(id);
  return res.redirect("/admin/tokens?deleted=1");
}));

app.get("/admin/clients/new", csrfProtection, requireAdminAuth, asyncHandler(async (req, res) => {
  await renderAdminNewClientPage(req, res);
}));

app.post("/admin/clients/new", csrfProtection, requireAdminAuth, asyncHandler(async (req, res) => {
  const purchaser = sanitizeInput(req.body.purchaser);
  const purchaserContact = sanitizeInput(req.body.purchaser_contact);
  const profileIdRaw = sanitizeInput(req.body.profile_id);
  const profileName = sanitizeInput(req.body.profile_name);
  const selectedFieldIds = parseSelectedFieldIds(req.body.enabled_fields);
  const errors = {};
  if (!purchaser) errors.purchaser = req.t("admin.newClientRequired");
  if (!purchaserContact) errors.purchaser_contact = req.t("admin.newClientRequired");
  if (!selectedFieldIds.length) errors.enabled_fields = req.t("admin.newClientFieldsRequired");

  let selectedProfile = null;
  if (profileIdRaw) {
    const profileId = Number(profileIdRaw);
    if (!Number.isInteger(profileId) || profileId <= 0) {
      errors.profile_id = req.t("admin.invalidId");
    } else {
      selectedProfile = await getProfileById(profileId);
      if (!selectedProfile) {
        errors.profile_id = req.t("admin.invalidId");
      }
    }
  }

  if (Object.keys(errors).length > 0) {
    return renderAdminNewClientPage(req, res, {
      statusCode: 422,
      values: {
        purchaser,
        purchaser_contact: purchaserContact,
        profile_id: profileIdRaw,
        profile_name: profileName
      },
      errors,
      selectedFieldIds
    });
  }

  let profileId = selectedProfile ? selectedProfile.id : null;
  if (profileName) {
    try {
      const createdProfile = await createProfile({ name: profileName, fieldIds: selectedFieldIds });
      profileId = createdProfile.id;
    } catch (err) {
      return renderAdminNewClientPage(req, res, {
        statusCode: err.statusCode || 422,
        values: {
          purchaser,
          purchaser_contact: purchaserContact,
          profile_id: profileIdRaw,
          profile_name: profileName
        },
        errors: err.details || { generic: err.message },
        selectedFieldIds
      });
    }
  }

  const equipment = await createEquipment({
    purchaser,
    purchaserContact,
    profileId,
    enabledFieldIds: selectedFieldIds
  });
  return res.redirect(`/form/${equipment.token}/specification`);
}));

app.get("/admin/fields", csrfProtection, requireAdminAuth, asyncHandler(async (req, res) => {
  const editId = Number(req.query.edit);
  if (Number.isInteger(editId) && editId > 0) {
    const field = await getFieldById(editId);
    if (field) {
      await renderAdminFieldsPage(req, res, {
        editingFieldId: String(editId),
        formValues: {
          key: field.key,
          label: field.label,
          section: field.section,
          field_type: field.fieldType,
          unit: field.unit || "",
          enum_options: Array.isArray(field.enumOptions) ? field.enumOptions.join("\n") : "",
          has_default: field.hasDefault,
          default_value: field.hasDefault ? JSON.stringify(field.defaultValue) : ""
        }
      });
      return;
    }
  }
  await renderAdminFieldsPage(req, res);
}));

app.post("/admin/fields/create", csrfProtection, requireAdminAuth, asyncHandler(async (req, res) => {
  const payload = parseFieldPayloadFromBody(req.body);
  const formValues = {
    key: payload.key,
    label: payload.label,
    section: payload.section,
    field_type: payload.fieldType,
    unit: payload.unit || "",
    enum_options: (payload.enumOptions || []).join("\n"),
    has_default: payload.hasDefault,
    default_value: payload.defaultValue || ""
  };
  try {
    await createField(payload);
    return res.redirect("/admin/fields?saved=1");
  } catch (err) {
    return renderAdminFieldsPage(req, res, {
      statusCode: err.statusCode || 422,
      errors: err.details || { generic: err.message },
      formValues
    });
  }
}));

app.post("/admin/fields/:id/update", csrfProtection, requireAdminAuth, asyncHandler(async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).send(req.t("admin.invalidId"));
  }
  const payload = parseFieldPayloadFromBody(req.body);
  const formValues = {
    key: payload.key,
    label: payload.label,
    section: payload.section,
    field_type: payload.fieldType,
    unit: payload.unit || "",
    enum_options: (payload.enumOptions || []).join("\n"),
    has_default: payload.hasDefault,
    default_value: payload.defaultValue || ""
  };
  try {
    await updateField(id, payload);
    return res.redirect("/admin/fields?saved=1");
  } catch (err) {
    return renderAdminFieldsPage(req, res, {
      statusCode: err.statusCode || 422,
      errors: err.details || { generic: err.message },
      formValues,
      editingFieldId: String(id)
    });
  }
}));

app.post("/admin/fields/:id/delete", csrfProtection, requireAdminAuth, asyncHandler(async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).send(req.t("admin.invalidId"));
  }
  await deleteField(id);
  return res.redirect("/admin/fields?deleted=1");
}));

app.get("/fields", asyncHandler(async (req, res) => {
  const section = sanitizeInput(req.query.section);
  const data = await listFields(section ? { section } : {});
  res.json({ data });
}));

app.post("/fields", requireAdminAuth, asyncHandler(async (req, res) => {
  const created = await createField(req.body || {});
  res.status(201).json({ data: created });
}));

app.put("/fields/:id", requireAdminAuth, asyncHandler(async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: "Invalid id." });
  }
  const updated = await updateField(id, req.body || {});
  res.json({ data: updated });
}));

app.delete("/fields/:id", requireAdminAuth, asyncHandler(async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: "Invalid id." });
  }
  const deleted = await deleteField(id);
  if (!deleted) return res.status(404).json({ error: "Field not found." });
  return res.status(204).send();
}));

app.get("/equipment/:id/specification", asyncHandler(async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: "Invalid id." });
  }
  const equipment = await getEquipmentById(id);
  if (!equipment) return res.status(404).json({ error: "Equipment not found." });
  const section = sanitizeInput(req.query.section);
  const data = await getEquipmentSpecification(id, section || null);
  res.json({ data });
}));

app.put("/equipment/:id/specification", requireAdminAuth, asyncHandler(async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: "Invalid id." });
  }
  const equipment = await getEquipmentById(id);
  if (!equipment) return res.status(404).json({ error: "Equipment not found." });
  const values = req.body && req.body.values ? req.body.values : {};
  const result = await saveEquipmentSpecification(id, values);
  res.json({ data: result });
}));

app.get("/form/:token/specification", csrfProtection, asyncHandler(async (req, res) => {
  const equipment = await resolveEquipmentByTokenOr404(req, res);
  if (!equipment) return;
  const specification = await getEquipmentSpecification(equipment.id);
  const qr = await buildSubmissionQrPayload(equipment.token, []);
  res.render("section", {
    pageTitle: req.t("section.headerTitle"),
    equipment,
    sections: buildSpecificationRenderModel(specification),
    errors: {},
    saved: req.query.saved === "1",
    qrDataUrl: qr.qrDataUrl,
    csrfToken: req.csrfToken()
  });
}));

app.post("/form/:token/specification", csrfProtection, asyncHandler(async (req, res) => {
  const equipment = await resolveEquipmentByTokenOr404(req, res);
  if (!equipment) return;

  const specification = await getEquipmentSpecification(equipment.id);
  const allFields = specification.sections.flatMap((section) => section.fields);
  const parsed = parseSpecificationFormBody(allFields, req.body);
  if (Object.keys(parsed.errors).length > 0) {
    const qr = await buildSubmissionQrPayload(equipment.token, []);
    return res.status(422).render("section", {
      pageTitle: req.t("section.headerTitle"),
      equipment,
      sections: buildSpecificationRenderModel(specification, parsed.submittedValues),
      errors: parsed.errors,
      saved: false,
      qrDataUrl: qr.qrDataUrl,
      csrfToken: req.csrfToken()
    });
  }

  await saveEquipmentSpecification(equipment.id, parsed.values);
  if (sanitizeInput(req.body.action) === "review") {
    return res.redirect(`/form/${equipment.token}/review`);
  }
  return res.redirect(`/form/${equipment.token}/specification?saved=1`);
}));

app.get("/form/:token/review", csrfProtection, asyncHandler(async (req, res) => {
  const equipment = await resolveEquipmentByTokenOr404(req, res);
  if (!equipment) return;
  const specification = await getEquipmentSpecification(equipment.id);
  const qr = await buildSubmissionQrPayload(equipment.token, []);
  res.render("review", {
    pageTitle: req.t("app.reviewTitle"),
    equipment,
    sections: buildSpecificationRenderModel(specification),
    emailSent: req.query.email === "1",
    qrDataUrl: qr.qrDataUrl,
    csrfToken: req.csrfToken()
  });
}));

const emailLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 8,
  standardHeaders: true,
  legacyHeaders: false
});

app.post("/form/:token/send-email", csrfProtection, emailLimiter, asyncHandler(async (req, res) => {
  const equipment = await resolveEquipmentByTokenOr404(req, res);
  if (!equipment) return;
  const to = sanitizeInput(req.body.to);
  if (!to || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(to)) {
    return res.status(400).send(req.t("app.invalidRecipientEmail"));
  }

  const specification = await getEquipmentSpecification(equipment.id);
  const sections = buildSpecificationRenderModel(specification);
  try {
    const pdfBuffer = await generatePdfBuffer({ submission: equipment, sections, lang: req.lang });
    await sendSubmissionEmail({ to, submission: equipment, sections, pdfBuffer, lang: req.lang });
    await updateEquipmentStatus(equipment.id, "sent");
    return res.redirect(`/form/${equipment.token}/review?email=1`);
  } catch (err) {
    return res.status(500).send(req.t("app.emailSendError", { message: err.message }));
  }
}));

app.get("/form/:token/pdf", asyncHandler(async (req, res) => {
  const equipment = await resolveEquipmentByTokenOr404(req, res);
  if (!equipment) return;
  const specification = await getEquipmentSpecification(equipment.id);
  const sections = buildSpecificationRenderModel(specification);
  const pdfBuffer = await generatePdfBuffer({ submission: equipment, sections, lang: req.lang });
  res.setHeader("Content-Type", "application/pdf");
  res.setHeader("Content-Disposition", `attachment; filename=annexD-${equipment.token}.pdf`);
  res.send(pdfBuffer);
}));

app.get("/form/:token/export.json", asyncHandler(async (req, res) => {
  const equipment = await resolveEquipmentByTokenOr404(req, res);
  if (!equipment) return;
  const specification = await getEquipmentSpecification(equipment.id);
  const sections = buildSpecificationRenderModel(specification);
  const payload = {
    meta: {
      token: equipment.token,
      status: equipment.status,
      created_at: equipment.createdAt,
      updated_at: equipment.updatedAt,
      exported_at: dayjs().toISOString()
    },
    sections: sections.map((section) => ({
      section: section.section,
      fields: section.fields.map((field) => ({
        id: field.id,
        key: field.key,
        label: field.label,
        unit: field.unit || null,
        value: field.displayValue,
        source: field.cameFromDefault ? "default" : "saved_or_empty"
      }))
    }))
  };
  res.setHeader("Content-Type", "application/json");
  res.send(JSON.stringify(payload, null, 2));
}));

app.get("/form/start", (req, res) => {
  res.redirect("/admin/clients/new");
});

app.post("/admin/seed-annexd", csrfProtection, requireAdminAuth, asyncHandler(async (_req, res) => {
  await seedAnnexDFields({ overwrite: true });
  res.redirect("/admin/fields?saved=1");
}));

app.use((err, req, res, next) => {
  if (err.code === "EBADCSRFTOKEN") {
    return res.status(403).send(req.t("app.csrfExpired"));
  }
  if (err.statusCode && req.path.startsWith("/fields")) {
    return res.status(err.statusCode).json({ error: err.message, details: err.details || null });
  }
  return next(err);
});

async function start() {
  await migrate();
  await seedAnnexDFields();
  app.listen(env.port, () => {
    // eslint-disable-next-line no-console
    console.log(`Server running on ${env.appBaseUrl}`);
  });
}

start().catch((err) => {
  // eslint-disable-next-line no-console
  console.error("Startup failed:", err.message);
  process.exit(1);
});
