const db = require("../db");

async function getFieldSettingsMap(allFieldIds) {
  const result = await db.query("SELECT field_id, enabled FROM field_settings");
  const map = {};
  (allFieldIds || []).forEach((fieldId) => {
    map[fieldId] = true;
  });
  result.rows.forEach((row) => {
    map[row.field_id] = Boolean(row.enabled);
  });
  return map;
}

async function saveFieldSettings(enabledMap) {
  const entries = Object.entries(enabledMap || {});
  const client = await db.connect();
  try {
    await client.query("BEGIN");
    for (const [fieldId, enabled] of entries) {
      await client.query(
        `
          INSERT INTO field_settings (field_id, enabled, updated_at)
          VALUES ($1, $2, NOW())
          ON CONFLICT (field_id) DO UPDATE SET
            enabled = EXCLUDED.enabled,
            updated_at = NOW()
        `,
        [fieldId, Boolean(enabled)]
      );
    }
    await client.query("COMMIT");
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
}

module.exports = {
  getFieldSettingsMap,
  saveFieldSettings
};
