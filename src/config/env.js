const path = require("path");
const dotenv = require("dotenv");

dotenv.config({ path: path.join(process.cwd(), ".env") });

function normalizeAppBaseUrl(raw, options = {}) {
  const isProduction = Boolean(options.isProduction);
  const fallback = "http://localhost:3000";
  const candidate = String(raw || fallback).trim();
  try {
    const parsed = new URL(candidate);
    if (isProduction && parsed.port === "3000") {
      parsed.port = "";
    }
    return parsed.toString().replace(/\/+$/, "");
  } catch (_err) {
    return fallback;
  }
}

const nodeEnv = String(process.env.NODE_ENV || "development").toLowerCase();
const appBaseUrl = normalizeAppBaseUrl(process.env.APP_BASE_URL, {
  isProduction: nodeEnv === "production"
});

module.exports = {
  nodeEnv,
  port: Number(process.env.PORT || 3000),
  appBaseUrl,
  admin: {
    user: process.env.ADMIN_USER || "admin",
    pass: process.env.ADMIN_PASS || "change-me",
    sessionSecret: process.env.ADMIN_SESSION_SECRET || "change-me-too"
  },
  database: {
    url: process.env.DATABASE_URL || "postgres://postgres:postgres@localhost:5432/formupsiec",
    ssl: process.env.DATABASE_SSL === "true"
  },
  smtp: {
    host: process.env.SMTP_HOST || "",
    port: Number(process.env.SMTP_PORT || 587),
    user: process.env.SMTP_USER || "",
    pass: process.env.SMTP_PASS || "",
    from: process.env.SMTP_FROM || "no-reply@example.com"
  },
  storage: {
    docsDir: process.env.DOCS_DIR || path.join(process.cwd(), "dados", "docs")
  }
};
