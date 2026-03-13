const { migrate } = require("../src/db/migrate");
const { seedAnnexDFields } = require("../src/services/fieldSeed");

async function run() {
  await migrate();
  const seeded = await seedAnnexDFields({ overwrite: true });

  // eslint-disable-next-line no-console
  console.log(`Seed de campos concluido. Total de campos: ${seeded.total}.`);
  process.exit(0);
}

run().catch((err) => {
  // eslint-disable-next-line no-console
  console.error("Seed failed:", err.message);
  process.exit(1);
});
