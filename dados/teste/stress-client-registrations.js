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
    fieldsPerClient: 12,
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
    if (arg === "--fields-per-client" && argv[i + 1]) {
      args.fieldsPerClient = Math.max(1, Number(argv[i + 1]) || args.fieldsPerClient);
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

function randomFrom(list) {
  return list[Math.floor(Math.random() * list.length)];
}

function randomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randomPhone() {
  return `+55 11 9${randomInt(1000, 9999)}-${randomInt(1000, 9999)}`;
}

function randomCompany(seed) {
  const prefixes = ["Alpha", "Delta", "Omega", "Prime", "Nexa", "Atlas", "Lumen", "Vector", "Astra"];
  const suffixes = ["Engenharia", "Industrial", "Tecnologia", "Energia", "Logistica", "Alimentos", "Metalurgia", "Consultoria"];
  return `${randomFrom(prefixes)} ${randomFrom(suffixes)} ${seed}`;
}

function randomName() {
  const firstNames = ["Ana", "Carlos", "Marina", "Rafael", "Joao", "Fernanda", "Paula", "Bruno", "Renata"];
  const lastNames = ["Silva", "Souza", "Oliveira", "Lima", "Costa", "Mendes", "Almeida", "Santos"];
  return `${randomFrom(firstNames)} ${randomFrom(lastNames)}`;
}

function randomEmail(name, seed) {
  const normalized = name
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/\s+/g, ".");
  return `${normalized}.${seed}@example.com`;
}

function randomProject(seed) {
  const kinds = ["UPS Retrofit", "Datacenter Expansion", "Hospital Backup", "Factory Upgrade", "Critical Load"];
  return `${randomFrom(kinds)} ${seed}`;
}

function randomSite() {
  const cities = ["Sao Paulo", "Campinas", "Curitiba", "Belo Horizonte", "Porto Alegre", "Rio de Janeiro"];
  return `${randomFrom(cities)} Plant`;
}

function randomAddress(seed) {
  return `Rua ${randomFrom(["das Flores", "Paulista", "dos Andradas", "XV de Novembro", "Sete de Setembro"])}, ${100 + seed}, Brasil`;
}

function randomToken() {
  const alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  let out = "";
  for (let i = 0; i < 32; i += 1) {
    out += alphabet[Math.floor(Math.random() * alphabet.length)];
  }
  return out;
}

function generateFieldValue(fieldType, enumOptions) {
  if (fieldType === "number") {
    return Math.round((Math.random() * 1000 + 1) * 100) / 100;
  }
  if (fieldType === "boolean") {
    return Math.random() > 0.5;
  }
  if (fieldType === "enum") {
    const options = Array.isArray(enumOptions) ? enumOptions : [];
    if (!options.length) return null;
    return randomFrom(options);
  }
  return `valor_teste_${randomInt(1, 9999)}`;
}

async function backupDatabase(outputDir) {
  fs.mkdirSync(outputDir, { recursive: true });
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const outputFile = path.join(outputDir, `backup-before-stress-${timestamp}.sql`);

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
    "SELECT id, field_type, enum_options FROM fields ORDER BY id ASC"
  );
  return result.rows.map((row) => ({
    id: Number(row.id),
    fieldType: row.field_type,
    enumOptions: Array.isArray(row.enum_options) ? row.enum_options : []
  }));
}

async function createClientRecord(client, seed, fieldCatalog, fieldsPerClient) {
  const contactName = randomName();
  const purchaser = randomCompany(seed);

  const equipmentResult = await client.query(
    `
      INSERT INTO equipments (
        token,
        purchaser,
        purchaser_contact,
        contact_email,
        contact_phone,
        project_name,
        site_name,
        address,
        status,
        created_at,
        updated_at
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'draft', NOW(), NOW())
      RETURNING id
    `,
    [
      randomToken(),
      purchaser,
      contactName,
      randomEmail(contactName, seed),
      randomPhone(),
      randomProject(seed),
      randomSite(),
      randomAddress(seed)
    ]
  );

  const equipmentId = Number(equipmentResult.rows[0].id);

  if (!fieldCatalog.length) {
    return equipmentId;
  }

  const chosen = new Set();
  const max = Math.min(fieldsPerClient, fieldCatalog.length);
  while (chosen.size < max) {
    chosen.add(randomInt(0, fieldCatalog.length - 1));
  }

  for (const idx of chosen) {
    const field = fieldCatalog[idx];
    const value = generateFieldValue(field.fieldType, field.enumOptions);
    if (value === null || value === undefined) continue;

    await client.query(
      `
        INSERT INTO equipment_field_values (equipment_id, field_id, value, created_at, updated_at)
        VALUES ($1, $2, $3::jsonb, NOW(), NOW())
        ON CONFLICT (equipment_id, field_id)
        DO UPDATE SET value = EXCLUDED.value, updated_at = NOW()
      `,
      [equipmentId, field.id, JSON.stringify(value)]
    );
  }

  return equipmentId;
}

async function runBatch(startIndex, batchSize, fieldCatalog, fieldsPerClient) {
  const client = await db.connect();
  let created = 0;
  try {
    for (let i = 0; i < batchSize; i += 1) {
      await createClientRecord(client, startIndex + i + 1, fieldCatalog, fieldsPerClient);
      created += 1;
    }
  } finally {
    client.release();
  }
  return created;
}

async function runStressInsert({ count, concurrency, fieldsPerClient }) {
  const fieldCatalog = await getFieldCatalog();
  const workers = Math.min(Math.max(1, concurrency), count);
  const chunk = Math.ceil(count / workers);

  const tasks = [];
  for (let w = 0; w < workers; w += 1) {
    const start = w * chunk;
    const remaining = count - start;
    if (remaining <= 0) break;
    const size = Math.min(chunk, remaining);
    tasks.push(runBatch(start, size, fieldCatalog, fieldsPerClient));
  }

  const results = await Promise.all(tasks);
  return results.reduce((acc, n) => acc + n, 0);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));

  console.log("[stress] configuracao:", args);

  if (!args.skipBackup) {
    const backupPath = await backupDatabase(args.outputDir);
    console.log(`[stress] backup criado em: ${backupPath}`);
  } else {
    console.log("[stress] backup ignorado (--skip-backup).");
  }

  const startedAt = Date.now();
  const created = await runStressInsert(args);
  const durationSec = ((Date.now() - startedAt) / 1000).toFixed(2);

  console.log(`[stress] clientes criados: ${created}`);
  console.log(`[stress] duracao: ${durationSec}s`);
}

main()
  .catch((err) => {
    console.error("[stress] erro:", err.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    try {
      await db.end();
    } catch (_err) {
      // noop
    }
  });
