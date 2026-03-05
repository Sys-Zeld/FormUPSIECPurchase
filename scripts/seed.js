const { migrate } = require("../src/db/migrate");
const { seedAnnexDFields } = require("../src/services/fieldSeed");
const { createEquipment } = require("../src/services/equipments");

async function run() {
  await migrate();
  const seeded = await seedAnnexDFields({ overwrite: true });
  const sample = await createEquipment({
    purchaser: "Cliente Exemplo",
    purchaserContact: "contato@empresa.com"
  });

  // eslint-disable-next-line no-console
  console.log(`Seed complete. Fields: ${seeded.total}. Sample equipment token: ${sample.token}`);
  process.exit(0);
}

run().catch((err) => {
  // eslint-disable-next-line no-console
  console.error("Seed failed:", err.message);
  process.exit(1);
});
