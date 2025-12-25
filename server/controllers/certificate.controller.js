import { successResponse } from '../utils/response.util.js';
import {
  getCertificatesForCitizen,
  getCertificateForDownload,
} from '../services/certificate.service.js';
import { generateCertificatePDF } from '../services/pdf.service.js';

/**
 * Get all certificates for the logged-in citizen
 * GET /api/certificates/my
 */
export const getMyCertificates = async (req, res, next) => {
  try {
    const userId = req.user.id; // From auth middleware

    const certificates = await getCertificatesForCitizen(userId);

    return successResponse(
      res,
      'Certificates retrieved successfully',
      certificates,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Download certificate as PDF
 * GET /api/certificates/:id/download
 */
export const getCertificateDownload = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.id; // From auth middleware

    // Get certificate data (with access verification)
    const certificateData = await getCertificateForDownload(id, userId);

    // Generate PDF
    const pdfBuffer = await generateCertificatePDF(certificateData);

    // Set response headers for PDF download
    const fileName = `${certificateData.type}_${certificateData.certificateNumber}.pdf`;
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="${fileName}"`,
    );
    res.setHeader('Content-Length', pdfBuffer.length);

    // Send PDF buffer
    res.send(pdfBuffer);
  } catch (error) {
    next(error);
  }
};

