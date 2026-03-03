const path = require("path");
const dotenv = require("dotenv");

dotenv.config({ path: path.join(process.cwd(), ".env") });

module.exports = {
  port: Number(process.env.PORT || 3000),
  appBaseUrl: process.env.APP_BASE_URL || "http://localhost:3000",
  admin: {
    user: process.env.ADMIN_USER || "admin",
    pass: process.env.ADMIN_PASS || "change-me",
    sessionSecret: process.env.ADMIN_SESSION_SECRET || "change-me-too"
  },
  database: {
    url: process.env.DATABASE_URL || "postgres://postgres:postgres@localhost:5432/annexd_form",
    ssl: process.env.DATABASE_SSL === "true"
  },
  smtp: {
    host: process.env.SMTP_HOST || "",
    port: Number(process.env.SMTP_PORT || 587),
    user: process.env.SMTP_USER || "",
    pass: process.env.SMTP_PASS || "",
    from: process.env.SMTP_FROM || "no-reply@example.com"
  }
};
