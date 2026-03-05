const QRCode = require("qrcode");
const env = require("../config/env");

function buildSubmissionAccessLink(submissionToken, sections = []) {
  const cleanBaseUrl = String(env.appBaseUrl || "http://localhost:3000").replace(/\/+$/, "");
  return `${cleanBaseUrl}/form/${submissionToken}/specification`;
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
