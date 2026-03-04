const db = require("./index");

async function migrate() {
  await db.query(`
    CREATE TABLE IF NOT EXISTS submissions (
      id BIGSERIAL PRIMARY KEY,
      token TEXT NOT NULL UNIQUE,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL,
      status TEXT NOT NULL DEFAULT 'draft'
    );
  `);
  await db.query(`
    CREATE TABLE IF NOT EXISTS answers (
      submission_id BIGINT NOT NULL,
      field_id TEXT NOT NULL,
      value TEXT,
      PRIMARY KEY (submission_id, field_id),
      FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE CASCADE
    );
  `);
  await db.query(`
    CREATE TABLE IF NOT EXISTS field_settings (
      field_id TEXT PRIMARY KEY,
      enabled BOOLEAN NOT NULL DEFAULT TRUE,
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);
}

module.exports = {
  migrate
};
