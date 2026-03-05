const db = require("./index");

async function migrate() {
  await db.query(`
    CREATE TABLE IF NOT EXISTS fields (
      id BIGSERIAL PRIMARY KEY,
      key TEXT NOT NULL UNIQUE,
      label TEXT NOT NULL,
      section TEXT NOT NULL,
      field_type TEXT NOT NULL,
      unit TEXT,
      enum_options JSONB,
      has_default BOOLEAN NOT NULL DEFAULT FALSE,
      default_value JSONB,
      display_order INTEGER NOT NULL DEFAULT 0,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);
  await db.query(`
    CREATE TABLE IF NOT EXISTS field_profiles (
      id BIGSERIAL PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);
  await db.query(`
    CREATE TABLE IF NOT EXISTS field_profile_fields (
      id BIGSERIAL PRIMARY KEY,
      profile_id BIGINT NOT NULL REFERENCES field_profiles(id) ON DELETE CASCADE,
      field_id BIGINT NOT NULL REFERENCES fields(id) ON DELETE CASCADE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      UNIQUE (profile_id, field_id)
    );
  `);
  await db.query(`
    CREATE TABLE IF NOT EXISTS equipments (
      id BIGSERIAL PRIMARY KEY,
      token TEXT NOT NULL UNIQUE,
      purchaser TEXT NOT NULL DEFAULT '',
      purchaser_contact TEXT NOT NULL DEFAULT '',
      profile_id BIGINT REFERENCES field_profiles(id) ON DELETE SET NULL,
      status TEXT NOT NULL DEFAULT 'draft',
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);
  await db.query(`
    ALTER TABLE equipments
    ADD COLUMN IF NOT EXISTS profile_id BIGINT REFERENCES field_profiles(id) ON DELETE SET NULL;
  `);
  await db.query(`
    CREATE TABLE IF NOT EXISTS equipment_field_values (
      id BIGSERIAL PRIMARY KEY,
      equipment_id BIGINT NOT NULL REFERENCES equipments(id) ON DELETE CASCADE,
      field_id BIGINT NOT NULL REFERENCES fields(id) ON DELETE CASCADE,
      value JSONB,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      UNIQUE (equipment_id, field_id)
    );
  `);
  await db.query(`
    CREATE TABLE IF NOT EXISTS equipment_enabled_fields (
      id BIGSERIAL PRIMARY KEY,
      equipment_id BIGINT NOT NULL REFERENCES equipments(id) ON DELETE CASCADE,
      field_id BIGINT NOT NULL REFERENCES fields(id) ON DELETE CASCADE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      UNIQUE (equipment_id, field_id)
    );
  `);
}

module.exports = {
  migrate
};
