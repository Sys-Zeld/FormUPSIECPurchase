const { v4: uuidv4 } = require("uuid");
const db = require("../db");

async function createSubmission() {
  const token = uuidv4().replace(/-/g, "");
  const now = new Date().toISOString();
  const result = await db.query(
    "INSERT INTO submissions (token, created_at, updated_at, status) VALUES ($1, $2, $3, $4) RETURNING id",
    [token, now, now, "draft"]
  );
  return {
    id: result.rows[0].id,
    token
  };
}

async function getSubmissionByToken(token) {
  const result = await db.query("SELECT * FROM submissions WHERE token = $1", [token]);
  return result.rows[0] || null;
}

async function getAnswersMap(submissionId) {
  const result = await db.query("SELECT field_id, value FROM answers WHERE submission_id = $1", [submissionId]);
  const rows = result.rows;
  return rows.reduce((acc, row) => {
    acc[row.field_id] = row.value;
    return acc;
  }, {});
}

async function saveAnswers(submissionId, answersObj) {
  const now = new Date().toISOString();
  const items = Object.entries(answersObj).map(([field_id, value]) => ({
    submission_id: submissionId,
    field_id,
    value: value === undefined || value === null ? "" : String(value)
  }));

  const client = await db.connect();
  try {
    await client.query("BEGIN");
    for (const item of items) {
      await client.query(
        `
          INSERT INTO answers (submission_id, field_id, value)
          VALUES ($1, $2, $3)
          ON CONFLICT(submission_id, field_id) DO UPDATE SET
            value = EXCLUDED.value
        `,
        [item.submission_id, item.field_id, item.value]
      );
    }
    await client.query("UPDATE submissions SET updated_at = $1 WHERE id = $2", [now, submissionId]);
    await client.query("COMMIT");
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
}

async function updateStatus(submissionId, status) {
  const now = new Date().toISOString();
  await db.query("UPDATE submissions SET status = $1, updated_at = $2 WHERE id = $3", [status, now, submissionId]);
}

async function listSubmissionsWithBuyerContact() {
  const result = await db.query(`
    SELECT
      s.id,
      s.token,
      s.status,
      s.created_at,
      s.updated_at,
      COALESCE(MAX(CASE WHEN a.field_id = 'purchaser' THEN a.value END), '') AS purchaser,
      COALESCE(MAX(CASE WHEN a.field_id = 'purchaser_contact' THEN a.value END), '') AS purchaser_contact
    FROM submissions s
    LEFT JOIN answers a
      ON a.submission_id = s.id
      AND a.field_id IN ('purchaser', 'purchaser_contact')
    GROUP BY s.id
    ORDER BY s.created_at DESC
  `);
  return result.rows;
}

async function deleteSubmissionById(submissionId) {
  const result = await db.query("DELETE FROM submissions WHERE id = $1", [submissionId]);
  return result.rowCount > 0;
}

module.exports = {
  createSubmission,
  getSubmissionByToken,
  getAnswersMap,
  saveAnswers,
  updateStatus,
  listSubmissionsWithBuyerContact,
  deleteSubmissionById
};
