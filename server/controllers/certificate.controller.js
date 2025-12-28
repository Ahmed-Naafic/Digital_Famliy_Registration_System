import { successResponse } from '../utils/response.util.js';
import {
  getCertificatesForCitizen,
  getCertificateForDownload,
  generateBirthCertificate,
  getCertificateByApplicationId,
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
 * Generate Birth Certificate from approved application
 * POST /api/certificates/birth
 */
export const generateBirthCertificateController = async (req, res, next) => {
  try {
    const { applicationId } = req.body;
    const userId = req.user.id; // From auth middleware

    if (!applicationId) {
      const error = new Error('Application ID is required');
      error.statusCode = 400;
      return next(error);
    }

    // Generate certificate (auto-issued, no admin approval)
    const certificate = await generateBirthCertificate(applicationId, userId);

    return successResponse(
      res,
      'Birth certificate generated successfully',
      certificate,
      201,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get certificate by application ID
 * GET /api/certificates/by-application/:applicationId
 */
export const getCertificateByApplicationController = async (req, res, next) => {
  try {
    const { applicationId } = req.params;
    const userId = req.user.id; // From auth middleware

    if (!applicationId) {
      const error = new Error('Application ID is required');
      error.statusCode = 400;
      return next(error);
    }

    const certificate = await getCertificateByApplicationId(applicationId, userId);

    if (!certificate) {
      return res.status(404).json({
        success: false,
        message: 'Certificate not found for this application',
      });
    }

    return successResponse(
      res,
      'Certificate retrieved successfully',
      certificate,
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

