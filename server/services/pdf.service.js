import PDFDocument from 'pdfkit';

/**
 * Generate PDF certificate for a certificate data object
 * @param {Object} certificateData - Certificate data from getCertificatesForCitizen
 * @returns {Promise<Buffer>} PDF buffer
 */
export const generateCertificatePDF = async (certificateData) => {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({
        size: 'A4',
        margin: 50,
        info: {
          Title: `${certificateData.type.toUpperCase()} Certificate`,
          Author: 'Digital Family Registration System',
          Subject: 'Official Certificate',
        },
      });

      const chunks = [];
      doc.on('data', (chunk) => chunks.push(chunk));
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      doc.on('error', reject);

      const { type, details, certificateNumber, issueDate, issuedBy } = certificateData;
      const issueDateObj = new Date(issueDate);

      // Header with gradient effect (simulated with colored boxes)
      const headerColor = getCertificateColor(type).primary;
      doc.rect(0, 0, 595, 150).fill(headerColor);

      // White text on colored header
      doc.fillColor('white')
        .fontSize(24)
        .font('Helvetica-Bold')
        .text('Digital Family Registration System', 50, 30, { align: 'center', width: 495 });

      doc.fontSize(18)
        .text(`${type.toUpperCase()} CERTIFICATE`, 50, 70, { align: 'center', width: 495 });

      doc.fontSize(12)
        .text(`Certificate No: ${certificateNumber}`, 50, 110, { align: 'center', width: 495 });

      // Reset to black for body
      doc.fillColor('black');

      // Main content area
      let yPosition = 180;

      // Certificate details based on type
      if (type === 'birth') {
        yPosition = addBirthCertificateContent(doc, details, yPosition);
      } else if (type === 'marriage') {
        yPosition = addMarriageCertificateContent(doc, details, yPosition);
      } else if (type === 'death') {
        yPosition = addDeathCertificateContent(doc, details, yPosition);
      } else if (type === 'divorce') {
        yPosition = addDivorceCertificateContent(doc, details, yPosition);
      }

      // Footer
      const footerY = 750;
      doc.strokeColor('#cccccc')
        .moveTo(50, footerY)
        .lineTo(545, footerY)
        .stroke();

      doc.fontSize(10)
        .fillColor('#666666')
        .text(`Issued on: ${formatDate(issueDateObj)}`, 50, footerY + 10)
        .text(`Approved by: ${issuedBy}`, 50, footerY + 25)
        .text('Digitally Generated – No Physical Signature Required', 50, footerY + 40, {
          align: 'center',
          width: 495,
          font: 'Helvetica-Oblique',
        });

      // QR Code placeholder (text representation)
      doc.fontSize(8)
        .fillColor('#999999')
        .text('QR Code: Verification Available', 50, footerY + 60, { align: 'center', width: 495 });

      doc.end();
    } catch (error) {
      reject(error);
    }
  });
};

/**
 * Add birth certificate content
 */
function addBirthCertificateContent(doc, details, yPos) {
  doc.fontSize(16)
    .font('Helvetica-Bold')
    .fillColor('#14B8A6')
    .text(details.childName || 'Unknown', 50, yPos, { align: 'center', width: 495 });

  yPos += 40;

  doc.fontSize(12)
    .font('Helvetica')
    .fillColor('black');

  const fields = [
    { label: 'Date of Birth', value: details.dateOfBirth ? formatDate(new Date(details.dateOfBirth)) : 'N/A' },
    { label: 'Place of Birth', value: details.placeOfBirth || 'N/A' },
    { label: 'Gender', value: details.gender ? details.gender.charAt(0).toUpperCase() + details.gender.slice(1) : 'N/A' },
    { label: 'Nationality', value: details.nationality || 'Somalia' },
  ];

  fields.forEach((field) => {
    doc.text(`${field.label}:`, 100, yPos, { width: 150, continued: false });
    doc.font('Helvetica-Bold').text(field.value, 250, yPos, { width: 245 });
    doc.font('Helvetica');
    yPos += 25;
  });

  // Parents section
  yPos += 20;
  doc.font('Helvetica-Bold').fontSize(14).text('Parents', 50, yPos);
  yPos += 25;

  doc.font('Helvetica').fontSize(12);
  doc.text(`Father: ${details.fatherName || 'Unknown'}`, 100, yPos);
  yPos += 20;
  doc.text(`Mother: ${details.motherName || 'Unknown'}`, 100, yPos);

  return yPos + 30;
}

/**
 * Add marriage certificate content
 */
function addMarriageCertificateContent(doc, details, yPos) {
  doc.fontSize(16)
    .font('Helvetica-Bold')
    .fillColor('#059669')
    .text('Marriage Certificate', 50, yPos, { align: 'center', width: 495 });

  yPos += 40;

  doc.fontSize(12)
    .font('Helvetica')
    .fillColor('black');

  doc.font('Helvetica-Bold').text('Husband:', 100, yPos);
  doc.font('Helvetica').text(details.husbandName || 'Unknown', 200, yPos);
  yPos += 25;

  doc.font('Helvetica-Bold').text('Wife:', 100, yPos);
  doc.font('Helvetica').text(details.wifeName || 'Unknown', 200, yPos);
  yPos += 30;

  const fields = [
    { label: 'Date of Marriage', value: details.dateOfMarriage ? formatDate(new Date(details.dateOfMarriage)) : 'N/A' },
    { label: 'Place of Marriage', value: details.placeOfMarriage || 'N/A' },
    { label: 'Marriage Type', value: details.marriageType || 'Civil' },
  ];

  fields.forEach((field) => {
    doc.text(`${field.label}:`, 100, yPos, { width: 150, continued: false });
    doc.font('Helvetica-Bold').text(field.value, 250, yPos, { width: 245 });
    doc.font('Helvetica');
    yPos += 25;
  });

  return yPos + 20;
}

/**
 * Add death certificate content
 */
function addDeathCertificateContent(doc, details, yPos) {
  doc.fontSize(16)
    .font('Helvetica-Bold')
    .fillColor('#475569')
    .text('Death Certificate', 50, yPos, { align: 'center', width: 495 });

  yPos += 40;

  doc.fontSize(14)
    .font('Helvetica-Bold')
    .fillColor('black')
    .text(`Deceased: ${details.deceasedName || 'Unknown'}`, 50, yPos, { align: 'center', width: 495 });

  yPos += 30;

  doc.fontSize(12).font('Helvetica');

  const fields = [
    { label: 'National ID', value: details.nationalId || 'N/A' },
    { label: 'Date of Birth', value: details.dateOfBirth ? formatDate(new Date(details.dateOfBirth)) : 'N/A' },
    { label: 'Date of Death', value: details.dateOfDeath ? formatDate(new Date(details.dateOfDeath)) : 'N/A' },
    { label: 'Place of Death', value: details.placeOfDeath || 'N/A' },
  ];

  if (details.causeOfDeath) {
    fields.push({ label: 'Cause of Death', value: details.causeOfDeath });
  }

  fields.forEach((field) => {
    doc.text(`${field.label}:`, 100, yPos, { width: 150, continued: false });
    doc.font('Helvetica-Bold').text(field.value, 250, yPos, { width: 245 });
    doc.font('Helvetica');
    yPos += 25;
  });

  return yPos + 20;
}

/**
 * Add divorce certificate content
 */
function addDivorceCertificateContent(doc, details, yPos) {
  doc.fontSize(16)
    .font('Helvetica-Bold')
    .fillColor('#991B1B')
    .text('Divorce Certificate', 50, yPos, { align: 'center', width: 495 });

  yPos += 40;

  doc.fontSize(12)
    .font('Helvetica')
    .fillColor('black');

  doc.font('Helvetica-Bold').text('Former Husband:', 100, yPos);
  doc.font('Helvetica').text(details.husbandName || 'Unknown', 200, yPos);
  yPos += 25;

  doc.font('Helvetica-Bold').text('Former Wife:', 100, yPos);
  doc.font('Helvetica').text(details.wifeName || 'Unknown', 200, yPos);
  yPos += 30;

  const fields = [
    { label: 'Divorce Date', value: details.divorceDate ? formatDate(new Date(details.divorceDate)) : 'N/A' },
    { label: 'Court / Authority', value: details.court || 'Family Court' },
  ];

  if (details.reasonCode) {
    fields.push({ label: 'Reason Code', value: details.reasonCode });
  }

  fields.forEach((field) => {
    doc.text(`${field.label}:`, 100, yPos, { width: 150, continued: false });
    doc.font('Helvetica-Bold').text(field.value, 250, yPos, { width: 245 });
    doc.font('Helvetica');
    yPos += 25;
  });

  yPos += 20;
  doc.font('Helvetica-Bold').fontSize(12).text('This marriage is legally dissolved.', 50, yPos, {
    align: 'center',
    width: 495,
  });

  return yPos + 30;
}

/**
 * Get certificate color based on type
 */
function getCertificateColor(type) {
  const colors = {
    birth: { primary: '#14B8A6', accent: '#06B6D4' },
    marriage: { primary: '#059669', accent: '#D97706' },
    death: { primary: '#475569', accent: '#1E293B' },
    divorce: { primary: '#991B1B', accent: '#7F1D1D' },
  };
  return colors[type] || { primary: '#333333', accent: '#666666' };
}

/**
 * Format date to readable string
 */
function formatDate(date) {
  if (!date || isNaN(date.getTime())) {
    return 'N/A';
  }
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return `${months[date.getMonth()]} ${date.getDate()}, ${date.getFullYear()}`;
}

