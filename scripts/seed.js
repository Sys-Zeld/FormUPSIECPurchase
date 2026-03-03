const { migrate } = require("../src/db/migrate");
const { loadSchema } = require("../src/utils/schema");
const { createSubmission, saveAnswers } = require("../src/services/submissions");

async function run() {
  await migrate();

  const sections = loadSchema();
  const sample = await createSubmission();
  const allAnswers = {};

  sections.forEach((section) => {
    section.fields.forEach((field) => {
      if (field.type === "number") allAnswers[field.id] = "1";
      else if (field.type === "date") allAnswers[field.id] = "2026-03-03";
      else if (field.type === "select" || field.type === "radio") allAnswers[field.id] = (field.options && field.options[0]) || "";
      else if (field.type === "checkbox") allAnswers[field.id] = "false";
      else allAnswers[field.id] = "sample";
    });
  });

  await saveAnswers(sample.id, allAnswers);

  // eslint-disable-next-line no-console
  console.log(`Seed complete. Token: ${sample.token}`);
  process.exit(0);
}

run().catch((err) => {
  // eslint-disable-next-line no-console
  console.error("Seed failed:", err.message);
  process.exit(1);
});
