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
const { loadSchema, localizeSections } = require("./utils/schema");
const { sanitizeInput } = require("./utils/sanitize");
const { validateSection } = require("./utils/validation");
const { SUPPORTED_LANGS, DEFAULT_LANG, normalizeLang, createTranslator } = require("./i18n");
const {
  createSubmission,
  getSubmissionByToken,
  getAnswersMap,
  saveAnswers,
  updateStatus,
  listSubmissionsWithBuyerContact,
  deleteSubmissionById
} = require("./services/submissions");
const { buildSubmissionQrPayload } = require("./services/qr");
const { generatePdfBuffer } = require("./services/pdf");
const { sendSubmissionEmail } = require("./services/email");

const app = express();
const baseSections = loadSchema();
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

app.use(helmet({ contentSecurityPolicy: false }));
app.use(express.urlencoded({ extended: false }));
app.use(express.json());
app.use(cookieParser());
app.use("/public", express.static(path.join(__dirname, "public")));

const supportedLangSet = new Set(SUPPORTED_LANGS);

function resolveLanguage(req) {
  const queryLang = normalizeLang(req.query.lang);
  if (req.query.lang && supportedLangSet.has(queryLang)) {
    return queryLang;
  }
  const cookieLang = normalizeLang(req.cookies.lang);
  if (req.cookies.lang && supportedLangSet.has(cookieLang)) {
    return cookieLang;
  }
  const acceptLanguage = req.headers["accept-language"];
  if (acceptLanguage) {
    const fromHeader = normalizeLang(acceptLanguage.split(",")[0]);
    if (supportedLangSet.has(fromHeader)) {
      return fromHeader;
    }
  }
  return DEFAULT_LANG;
}

app.use((req, res, next) => {
  const lang = resolveLanguage(req);
  if (normalizeLang(req.cookies.lang) !== lang) {
    res.cookie("lang", lang, { sameSite: "lax", maxAge: 365 * 24 * 60 * 60 * 1000 });
  }
  const t = createTranslator(lang);
  req.lang = lang;
  req.t = t;
  res.locals.lang = lang;
  res.locals.t = t;
  res.locals.currentPath = req.path;
  next();
});

const csrfProtection = csrf({ cookie: true });
const asyncHandler = (handler) => (req, res, next) => Promise.resolve(handler(req, res, next)).catch(next);

function resolveSectionOr404(req, res, sections) {
  const sectionId = req.params.sectionId;
  const idx = sections.findIndex((section) => section.id === sectionId);
  if (idx < 0) {
    res.status(404).send(req.t("app.sectionNotFound"));
    return null;
  }
  return { section: sections[idx], idx };
}

async function resolveSubmissionOr404(req, res) {
  const submission = await getSubmissionByToken(req.params.token);
  if (!submission) {
    res.status(404).send(req.t("app.submissionNotFound"));
    return null;
  }
  return submission;
}

function sanitizeSectionPayload(section, body) {
  const data = {};
  (section.fields || []).forEach((field) => {
    const raw = body[field.id];
    if (field.type === "checkbox") {
      data[field.id] = raw ? "true" : "false";
    } else {
      data[field.id] = sanitizeInput(raw);
    }
  });
  return data;
}

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
  if (isValidAdminSessionToken(req.cookies.admin_session)) {
    return next();
  }
  return res.redirect("/admin/login");
}

app.get("/", (req, res) => {
  res.redirect("/form/start");
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
  const validUser = username === env.admin.user;
  const validPass = password === env.admin.pass;
  if (!validUser || !validPass) {
    return res.redirect("/admin/login?error=1");
  }
  const token = createAdminSessionToken(username);
  res.cookie("admin_session", token, {
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
  const rows = await listSubmissionsWithBuyerContact();
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
  await deleteSubmissionById(id);
  return res.redirect("/admin/tokens?deleted=1");
}));

app.get("/form/start", asyncHandler(async (req, res) => {
  if (!baseSections.length) {
    return res.status(500).send(req.t("app.schemaMissing"));
  }
  const { token } = await createSubmission();
  res.redirect(`/form/${token}/section/${baseSections[0].id}`);
}));

app.get("/form/:token/section/:sectionId", csrfProtection, asyncHandler(async (req, res) => {
  const sections = localizeSections(baseSections, req.lang);
  const submission = await resolveSubmissionOr404(req, res);
  if (!submission) return;
  const sectionInfo = resolveSectionOr404(req, res, sections);
  if (!sectionInfo) return;

  const answersMap = await getAnswersMap(submission.id);
  const qr = await buildSubmissionQrPayload(submission.token, sections);
  res.render("section", {
    pageTitle: sectionInfo.section.title,
    submission,
    section: sectionInfo.section,
    sectionIndex: sectionInfo.idx,
    sections,
    answersMap,
    errors: {},
    saved: req.query.saved === "1",
    qrDataUrl: qr.qrDataUrl,
    csrfToken: req.csrfToken()
  });
}));

app.post("/form/:token/section/:sectionId", csrfProtection, asyncHandler(async (req, res) => {
  const sections = localizeSections(baseSections, req.lang);
  const submission = await resolveSubmissionOr404(req, res);
  if (!submission) return;
  const sectionInfo = resolveSectionOr404(req, res, sections);
  if (!sectionInfo) return;

  const action = sanitizeInput(req.body.action || "next");
  const section = sectionInfo.section;
  const payload = sanitizeSectionPayload(section, req.body);
  const errors = action === "previous" ? {} : validateSection(section, payload, req.lang);

  if (Object.keys(errors).length > 0) {
    const merged = { ...(await getAnswersMap(submission.id)), ...payload };
    const qr = await buildSubmissionQrPayload(submission.token, sections);
    return res.status(422).render("section", {
      pageTitle: section.title,
      submission,
      section,
      sectionIndex: sectionInfo.idx,
      sections,
      answersMap: merged,
      errors,
      saved: false,
      qrDataUrl: qr.qrDataUrl,
      csrfToken: req.csrfToken()
    });
  }

  await saveAnswers(submission.id, payload);

  if (action === "draft") {
    return res.redirect(`/form/${submission.token}/section/${section.id}?saved=1`);
  }

  if (action === "previous") {
    const prevIdx = Math.max(0, sectionInfo.idx - 1);
    return res.redirect(`/form/${submission.token}/section/${sections[prevIdx].id}`);
  }

  const nextIdx = sectionInfo.idx + 1;
  if (nextIdx >= sections.length) {
    return res.redirect(`/form/${submission.token}/review`);
  }
  return res.redirect(`/form/${submission.token}/section/${sections[nextIdx].id}`);
}));

app.get("/form/:token/review", csrfProtection, asyncHandler(async (req, res) => {
  const sections = localizeSections(baseSections, req.lang);
  const submission = await resolveSubmissionOr404(req, res);
  if (!submission) return;
  const answersMap = await getAnswersMap(submission.id);
  const qr = await buildSubmissionQrPayload(submission.token, sections);
  res.render("review", {
    pageTitle: req.t("app.reviewTitle"),
    submission,
    sections,
    answersMap,
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
  const sections = localizeSections(baseSections, req.lang);
  const submission = await resolveSubmissionOr404(req, res);
  if (!submission) return;

  const to = sanitizeInput(req.body.to);
  if (!to || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(to)) {
    return res.status(400).send(req.t("app.invalidRecipientEmail"));
  }

  const answersMap = await getAnswersMap(submission.id);
  try {
    const pdfBuffer = await generatePdfBuffer({ submission, sections, answersMap, lang: req.lang });
    await sendSubmissionEmail({ to, submission, sections, answersMap, pdfBuffer, lang: req.lang });
    await updateStatus(submission.id, "sent");
    res.redirect(`/form/${submission.token}/review?email=1`);
  } catch (err) {
    res.status(500).send(req.t("app.emailSendError", { message: err.message }));
  }
}));

app.get("/form/:token/pdf", asyncHandler(async (req, res) => {
  const sections = localizeSections(baseSections, req.lang);
  const submission = await resolveSubmissionOr404(req, res);
  if (!submission) return;
  const answersMap = await getAnswersMap(submission.id);
  const pdfBuffer = await generatePdfBuffer({ submission, sections, answersMap, lang: req.lang });
  res.setHeader("Content-Type", "application/pdf");
  res.setHeader("Content-Disposition", `attachment; filename=annexD-${submission.token}.pdf`);
  res.send(pdfBuffer);
}));

app.get("/form/:token/export.json", asyncHandler(async (req, res) => {
  const sections = localizeSections(baseSections, req.lang);
  const submission = await resolveSubmissionOr404(req, res);
  if (!submission) return;
  const answersMap = await getAnswersMap(submission.id);
  const payload = {
    meta: {
      token: submission.token,
      status: submission.status,
      created_at: submission.created_at,
      updated_at: submission.updated_at,
      exported_at: dayjs().toISOString()
    },
    sections: sections.map((section) => ({
      id: section.id,
      title: section.title,
      fields: section.fields.map((field) => ({
        id: field.id,
        label: field.label,
        unit: field.unit || null,
        value: answersMap[field.id] || ""
      }))
    }))
  };
  res.setHeader("Content-Type", "application/json");
  res.send(JSON.stringify(payload, null, 2));
}));

app.use((err, req, res, next) => {
  if (err.code === "EBADCSRFTOKEN") {
    return res.status(403).send(req.t("app.csrfExpired"));
  }
  return next(err);
});

async function start() {
  await migrate();
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
