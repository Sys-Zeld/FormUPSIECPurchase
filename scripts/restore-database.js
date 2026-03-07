const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");
const env = require("../src/config/env");

function resolveBackupFileFromArgs() {
  const argPath = process.argv[2];
  if (!argPath) return null;

  const resolved = path.resolve(argPath);
  if (!fs.existsSync(resolved)) {
    throw new Error(`Arquivo de backup nao encontrado: ${resolved}`);
  }

  const stat = fs.statSync(resolved);
  if (!stat.isFile()) {
    throw new Error(`Caminho informado nao e arquivo: ${resolved}`);
  }

  return resolved;
}

function findLatestBackup() {
  const backupDir = path.join(process.cwd(), "dados", "backups");
  if (!fs.existsSync(backupDir)) {
    throw new Error(`Diretorio de backups nao encontrado: ${backupDir}`);
  }

  const files = fs
    .readdirSync(backupDir)
    .filter((file) => file.toLowerCase().endsWith(".sql"))
    .map((file) => {
      const fullPath = path.join(backupDir, file);
      const stat = fs.statSync(fullPath);
      const match = file.match(
        /^db-backup-(\d{4})-(\d{2})-(\d{2})T(\d{2})-(\d{2})-(\d{2})-(\d{3})Z\.sql$/i
      );
      const nameDateMs = match
        ? Date.parse(`${match[1]}-${match[2]}-${match[3]}T${match[4]}:${match[5]}:${match[6]}.${match[7]}Z`)
        : null;

      return {
        fullPath,
        mtimeMs: stat.mtimeMs,
        name: file,
        isFile: stat.isFile(),
        nameDateMs
      };
    })
    .filter((entry) => entry.isFile);

  if (!files.length) {
    throw new Error(`Nenhum arquivo .sql encontrado em: ${backupDir}`);
  }

  files.sort((a, b) => {
    if (a.nameDateMs !== null || b.nameDateMs !== null) {
      const aDate = a.nameDateMs === null ? -Infinity : a.nameDateMs;
      const bDate = b.nameDateMs === null ? -Infinity : b.nameDateMs;
      if (bDate !== aDate) return bDate - aDate;
    }
    if (b.mtimeMs !== a.mtimeMs) return b.mtimeMs - a.mtimeMs;
    return b.name.localeCompare(a.name);
  });

  return files[0].fullPath;
}

async function runPsql(databaseUrl, inputFile) {
  await new Promise((resolve, reject) => {
    const child = spawn(
      "psql",
      ["-v", "ON_ERROR_STOP=1", "--single-transaction", "--file", inputFile, databaseUrl],
      {
        stdio: "inherit",
        shell: false,
        windowsHide: true
      }
    );

    child.on("error", (err) => {
      reject(new Error(`Falha ao iniciar psql: ${err.message}`));
    });

    child.on("exit", (code) => {
      if (code === 0) {
        resolve();
        return;
      }
      reject(new Error(`psql retornou codigo ${code}.`));
    });
  });
}

async function run() {
  const databaseUrl = env.database.url;
  if (!databaseUrl) {
    throw new Error("DATABASE_URL nao configurado.");
  }

  const manualBackup = resolveBackupFileFromArgs();
  const backupFile = manualBackup || findLatestBackup();

  // eslint-disable-next-line no-console
  console.log(`Restaurando backup: ${backupFile}`);
  await runPsql(databaseUrl, backupFile);
  // eslint-disable-next-line no-console
  console.log("Restore concluido com sucesso.");
}

run().catch((err) => {
  // eslint-disable-next-line no-console
  console.error("Falha no restore:", err.message);
  process.exit(1);
});
