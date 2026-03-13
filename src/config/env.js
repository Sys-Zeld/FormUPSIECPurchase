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
    sessionSecret: process.env.ADMIN_SESSION_SECRET || "change-me-too",
    sessionCookieName: process.env.ADMIN_SESSION_COOKIE_NAME || "admin_session",
    sessionTtlHours: Math.max(1, Number(process.env.ADMIN_SESSION_TTL_HOURS || 12)),
    sessionStateFile: process.env.ADMIN_SESSION_STATE_FILE || path.join(process.cwd(), "dados", "admin-session-state.json"),
    usersFile: process.env.ADMIN_USERS_FILE || path.join(process.cwd(), "dados", "admin-users.json")
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
  apiKeys: {
    pepper: process.env.API_KEY_PEPPER || process.env.ADMIN_SESSION_SECRET || "change-me-too",
    defaultTtlDays: Math.max(1, Number(process.env.API_KEY_DEFAULT_TTL_DAYS || 365))
  },
  openai: {
    apiKey: process.env.OPENAI_API_KEY || "",
    model: process.env.OPENAI_MODEL || "gpt-4.1-mini",
    baseUrl: String(process.env.OPENAI_BASE_URL || "https://api.openai.com/v1").replace(/\/+$/, ""),
    maxOutputTokens: Math.max(1000, Number(process.env.OPENAI_MAX_OUTPUT_TOKENS || 8000)),
    maxOutputRetries: Math.max(0, Number(process.env.OPENAI_MAX_OUTPUT_RETRIES || 2)),
    maxOutputTokensCap: Math.max(1000, Number(process.env.OPENAI_MAX_OUTPUT_TOKENS_CAP || 20000))
  },
  storage: {
    docsDir: process.env.DOCS_DIR || path.join(process.cwd(), "dados", "docs")
  }
};
