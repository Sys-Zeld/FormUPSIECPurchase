const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");
const db = require("../../src/db");
const env = require("../../src/config/env");

function parseArgs(argv) {
  const args = {
    count: 1000,
    concurrency: 10,
    skipBackup: false,
    fieldsPerProfile: 12,
    outputDir: path.join(process.cwd(), "dados", "teste", "backups")
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--count" && argv[i + 1]) {
      args.count = Math.max(1, Number(argv[i + 1]) || args.count);
      i += 1;
      continue;
    }
    if (arg === "--concurrency" && argv[i + 1]) {
      args.concurrency = Math.max(1, Number(argv[i + 1]) || args.concurrency);
      i += 1;
      continue;
    }
    if (arg === "--fields-per-profile" && argv[i + 1]) {
      args.fieldsPerProfile = Math.max(1, Number(argv[i + 1]) || args.fieldsPerProfile);
      i += 1;
      continue;
    }
    if (arg === "--output-dir" && argv[i + 1]) {
      args.outputDir = path.resolve(argv[i + 1]);
      i += 1;
      continue;
    }
    if (arg === "--skip-backup") {
      args.skipBackup = true;
    }
  }

  return args;
}

function randomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randomFrom(list) {
  return list[Math.floor(Math.random() * list.length)];
}

function buildProfileName(seed) {
  const prefixes = ["Stress", "Bench", "Scale", "Load", "Mass"];
  const suffixes = ["Perfil", "Formulario", "Cadastro", "Template", "Config"];
  return `${randomFrom(prefixes)}-${randomFrom(suffixes)}-${Date.now()}-${seed}-${randomInt(1000, 9999)}`;
}

function pickRandomFields(fieldCatalog, fieldsPerProfile) {
  if (!fieldCatalog.length) return [];
  const chosen = new Set();
  const max = Math.min(fieldsPerProfile, fieldCatalog.length);
  while (chosen.size < max) {
    chosen.add(randomInt(0, fieldCatalog.length - 1));
  }
  return Array.from(chosen).map((idx) => fieldCatalog[idx]);
}

async function backupDatabase(outputDir) {
  fs.mkdirSync(outputDir, { recursive: true });
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const outputFile = path.join(outputDir, `backup-before-profile-stress-${timestamp}.sql`);

  const dbUrl = env.database.url;
  if (!dbUrl) {
    throw new Error("DATABASE_URL nao definido para backup.");
  }

  await new Promise((resolve, reject) => {
    const child = spawn("pg_dump", ["--no-owner", "--no-privileges", "--file", outputFile, dbUrl], {
      stdio: "inherit",
      shell: false,
      windowsHide: true
    });

    child.on("error", (err) => {
      reject(new Error(`Falha ao iniciar pg_dump: ${err.message}`));
    });

    child.on("exit", (code) => {
      if (code === 0) {
        resolve();
        return;
      }
      reject(new Error(`pg_dump retornou codigo ${code}.`));
    });
  });

  return outputFile;
}

async function getFieldCatalog() {
  const result = await db.query(
    `
      SELECT id, label, section, field_type, unit, enum_options, has_default, default_value, display_order
      FROM fields
      ORDER BY display_order ASC, id ASC
    `
  );
  return result.rows.map((row) => ({
    id: Number(row.id),
    label: row.label,
    section: row.section,
    fieldType: row.field_type,
    unit: row.unit || null,
    enumOptions: Array.isArray(row.enum_options) ? row.enum_options : null,
    hasDefault: row.has_default === null || row.has_default === undefined ? false : Boolean(row.has_default),
    defaultValue: row.default_value === undefined ? null : row.default_value,
    displayOrder: Number(row.display_order || 0)
  }));
}

async function createProfileRecord(client, seed, fieldCatalog, fieldsPerProfile) {
  const profileResult = await client.query(
    `
      INSERT INTO field_profiles (name, created_at, updated_at)
      VALUES ($1, NOW(), NOW())
      RETURNING id
    `,
    [buildProfileName(seed)]
  );
  const profileId = Number(profileResult.rows[0].id);
  const selectedFields = pickRandomFields(fieldCatalog, fieldsPerProfile);

  for (const field of selectedFields) {
    await client.query(
      `
        INSERT INTO field_profile_fields
          (profile_id, field_id, is_enabled, label, section, field_type, unit, enum_options, has_default, default_value, display_order, created_at)
        VALUES
          ($1, $2, TRUE, $3, $4, $5, $6, $7::jsonb, $8, $9::jsonb, $10, NOW())
      `,
      [
        profileId,
        field.id,
        field.label,
        field.section,
        field.fieldType,
        field.unit,
        field.enumOptions ? JSON.stringify(field.enumOptions) : null,
        Boolean(field.hasDefault),
        field.hasDefault ? JSON.stringify(field.defaultValue) : null,
        field.displayOrder
      ]
    );
  }

  return profileId;
}

async function runBatch(startIndex, batchSize, fieldCatalog, fieldsPerProfile) {
  const client = await db.connect();
  let created = 0;
  try {
    for (let i = 0; i < batchSize; i += 1) {
      await createProfileRecord(client, startIndex + i + 1, fieldCatalog, fieldsPerProfile);
      created += 1;
    }
  } finally {
    client.release();
  }
  return created;
}

async function runStressInsert({ count, concurrency, fieldsPerProfile }) {
  const fieldCatalog = await getFieldCatalog();
  if (!fieldCatalog.length) {
    throw new Error("Nenhum campo encontrado na tabela fields.");
  }

  const workers = Math.min(Math.max(1, concurrency), count);
  const chunk = Math.ceil(count / workers);

  const tasks = [];
  for (let w = 0; w < workers; w += 1) {
    const start = w * chunk;
    const remaining = count - start;
    if (remaining <= 0) break;
    const size = Math.min(chunk, remaining);
    tasks.push(runBatch(start, size, fieldCatalog, fieldsPerProfile));
  }

  const results = await Promise.all(tasks);
  return results.reduce((acc, n) => acc + n, 0);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  console.log("[stress-profile] configuracao:", args);

  if (!args.skipBackup) {
    const backupPath = await backupDatabase(args.outputDir);
    console.log(`[stress-profile] backup criado em: ${backupPath}`);
  } else {
    console.log("[stress-profile] backup ignorado (--skip-backup).");
  }

  const startedAt = Date.now();
  const created = await runStressInsert(args);
  const durationSec = ((Date.now() - startedAt) / 1000).toFixed(2);

  console.log(`[stress-profile] perfis criados: ${created}`);
  console.log(`[stress-profile] duracao: ${durationSec}s`);
}

main()
  .catch((err) => {
    console.error("[stress-profile] erro:", err.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    try {
      await db.end();
    } catch (_err) {
      // noop
    }
  });
