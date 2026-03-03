const QRCode = require("qrcode");
const env = require("../config/env");

function buildSubmissionAccessLink(submissionToken, sections = []) {
  const cleanBaseUrl = String(env.appBaseUrl || "http://localhost:3000").replace(/\/+$/, "");
  const firstSectionId = sections[0] && sections[0].id ? sections[0].id : null;
  if (firstSectionId) {
    return `${cleanBaseUrl}/form/${submissionToken}/section/${firstSectionId}`;
  }
  return `${cleanBaseUrl}/form/${submissionToken}/review`;
}

async function buildSubmissionQrPayload(submissionToken, sections = []) {
  const accessLink = buildSubmissionAccessLink(submissionToken, sections);
  const qrDataUrl = await QRCode.toDataURL(accessLink, {
    width: 220,
    margin: 1,
    color: {
      dark: "#0b3f73",
      light: "#ffffff"
    }
  });
  return { accessLink, qrDataUrl };
}

module.exports = {
  buildSubmissionAccessLink,
  buildSubmissionQrPayload
};
