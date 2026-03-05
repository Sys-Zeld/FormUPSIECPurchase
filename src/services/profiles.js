const db = require("../db");

function normalizeProfileRow(row) {
  return {
    id: Number(row.id),
    name: row.name,
    fieldsCount: Number(row.fields_count || 0),
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

function toSafeString(value) {
  return value === null || value === undefined ? "" : String(value).trim();
}

function normalizeFieldIds(fieldIds) {
  const list = Array.isArray(fieldIds) ? fieldIds : [];
  const unique = new Set();
  list.forEach((item) => {
    const id = Number(item);
    if (Number.isInteger(id) && id > 0) {
      unique.add(id);
    }
  });
  return Array.from(unique);
}

async function listProfiles() {
  const result = await db.query(`
    SELECT p.*, COUNT(pf.field_id)::int AS fields_count
    FROM field_profiles p
    LEFT JOIN field_profile_fields pf ON pf.profile_id = p.id
    GROUP BY p.id
    ORDER BY p.name ASC
  `);
  return result.rows.map(normalizeProfileRow);
}

async function getProfileById(id) {
  const result = await db.query("SELECT * FROM field_profiles WHERE id = $1", [id]);
  if (!result.rows[0]) return null;
  const profile = normalizeProfileRow({ ...result.rows[0], fields_count: 0 });
  const fieldIds = await getProfileFieldIds(id);
  profile.fieldsCount = fieldIds.length;
  return profile;
}

async function getProfileFieldIds(profileId) {
  const result = await db.query(
    "SELECT field_id FROM field_profile_fields WHERE profile_id = $1 ORDER BY field_id ASC",
    [profileId]
  );
  return result.rows.map((row) => Number(row.field_id));
}

async function createProfile({ name, fieldIds }) {
  const cleanName = toSafeString(name);
  const cleanFieldIds = normalizeFieldIds(fieldIds);

  const errors = {};
  if (!cleanName) errors.name = "Profile name is required.";
  if (!cleanFieldIds.length) errors.fieldIds = "Select at least one field.";
  if (Object.keys(errors).length > 0) {
    const err = new Error("Validation failed.");
    err.statusCode = 422;
    err.details = errors;
    throw err;
  }

  const client = await db.connect();
  try {
    await client.query("BEGIN");
    const created = await client.query(
      `
        INSERT INTO field_profiles (name, created_at, updated_at)
        VALUES ($1, NOW(), NOW())
        RETURNING *
      `,
      [cleanName]
    );
    const profile = normalizeProfileRow({ ...created.rows[0], fields_count: cleanFieldIds.length });
    for (const fieldId of cleanFieldIds) {
      await client.query(
        `
          INSERT INTO field_profile_fields (profile_id, field_id, created_at)
          VALUES ($1, $2, NOW())
          ON CONFLICT (profile_id, field_id) DO NOTHING
        `,
        [profile.id, fieldId]
      );
    }
    await client.query("COMMIT");
    return profile;
  } catch (err) {
    await client.query("ROLLBACK");
    if (err.code === "23505") {
      const conflict = new Error("Profile name already exists.");
      conflict.statusCode = 409;
      conflict.details = { name: "Profile name already exists." };
      throw conflict;
    }
    throw err;
  } finally {
    client.release();
  }
}

module.exports = {
  listProfiles,
  getProfileById,
  getProfileFieldIds,
  createProfile
};
