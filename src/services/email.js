const nodemailer = require("nodemailer");
const env = require("../config/env");
const { createTranslator } = require("../i18n");

function buildSummaryHtml(sections, answersMap, lang) {
  const t = createTranslator(lang);
  const blocks = sections
    .map((section) => {
      const rows = (section.fields || [])
        .map((field) => {
          const value = answersMap[field.id] || "-";
          const unit = field.unit || "-";
          return `<tr><td style="padding:6px;border:1px solid #ddd;">${field.label}</td><td style="padding:6px;border:1px solid #ddd;">${value}</td><td style="padding:6px;border:1px solid #ddd;">${unit}</td></tr>`;
        })
        .join("");
      return `<h3>${section.title}</h3><table style="width:100%;border-collapse:collapse;margin-bottom:18px;"><thead><tr><th style="text-align:left;padding:6px;border:1px solid #ddd;">${t("email.tableField")}</th><th style="text-align:left;padding:6px;border:1px solid #ddd;">${t("email.tableValue")}</th><th style="text-align:left;padding:6px;border:1px solid #ddd;">${t("email.tableUnit")}</th></tr></thead><tbody>${rows}</tbody></table>`;
    })
    .join("");
  return `<!doctype html><html><body><h2>${t("email.summaryTitle")}</h2>${blocks}</body></html>`;
}

async function sendSubmissionEmail({ to, submission, sections, answersMap, pdfBuffer, lang }) {
  const t = createTranslator(lang);
  const transporter = nodemailer.createTransport({
    host: env.smtp.host,
    port: env.smtp.port,
    secure: false,
    auth: env.smtp.user
      ? {
          user: env.smtp.user,
          pass: env.smtp.pass
        }
      : undefined
  });

  const html = buildSummaryHtml(sections, answersMap, lang);

  return transporter.sendMail({
    from: env.smtp.from,
    to,
    subject: t("email.subject", { token: submission.token }),
    html,
    attachments: [
      {
        filename: `annexD-${submission.token}.pdf`,
        content: pdfBuffer
      }
    ]
  });
}

module.exports = {
  sendSubmissionEmail,
  buildSummaryHtml
};
