const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");
const env = require("../src/config/env");

function buildBackupPath() {
  const backupDir = path.join(process.cwd(), "dados", "backups");
  fs.mkdirSync(backupDir, { recursive: true });
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  return path.join(backupDir, `db-backup-${timestamp}.sql`);
}

async function runPgDump(databaseUrl, outputFile) {
  await new Promise((resolve, reject) => {
    const child = spawn(
      "pg_dump",
      ["--no-owner", "--no-privileges", "--file", outputFile, databaseUrl],
      {
        stdio: "inherit",
        shell: false,
        windowsHide: true
      }
    );

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
}

async function run() {
  const databaseUrl = env.database.url;
  if (!databaseUrl) {
    throw new Error("DATABASE_URL nao configurado.");
  }

  const outputFile = buildBackupPath();
  await runPgDump(databaseUrl, outputFile);
  // eslint-disable-next-line no-console
  console.log(`Backup concluido: ${outputFile}`);
}

run().catch((err) => {
  // eslint-disable-next-line no-console
  console.error("Falha no backup:", err.message);
  process.exit(1);
});
