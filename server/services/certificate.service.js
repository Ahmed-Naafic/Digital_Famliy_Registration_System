import Certificate from '../models/Certificate.model.js';
import Application from '../models/Application.model.js';
import { generateCertificatePDF } from './pdf.service.js';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * Generate a unique certificate number
 * Format: TYPE-YYYY-XXXXX (e.g., BC-2025-00451, MC-2025-00123)
 */
const generateCertificateNumber = (type) => {
  const prefixMap = {
    birth: 'BC',
    marriage: 'MC',
    divorce: 'DC',
    death: 'DTC',
  };
  const prefix = prefixMap[type] || type.toUpperCase().substring(0, 2);
  const year = new Date().getFullYear();
  const random = Math.floor(Math.random() * 100000).toString().padStart(5, '0');
  return `${prefix}-${year}-${random}`;
};

/**
 * Create a certificate for an approved application
 * @param {string} applicationId - Application ID
 * @param {string} adminId - Admin user ID who approved
 * @returns {Promise<Object>} Created certificate
 */
export const createCertificate = async (applicationId, adminId) => {
  const application = await Application.findById(applicationId)
    .populate('userId', 'fullName email')
    .lean();

  if (!application) {
    const error = new Error('Application not found');
    error.statusCode = 404;
    throw error;
  }

  if (application.status !== 'approved') {
    const error = new Error('Application must be approved before creating certificate');
    error.statusCode = 400;
    throw error;
  }

  // Check if certificate already exists
  const existingCertificate = await Certificate.findOne({ applicationId });
  if (existingCertificate) {
    return existingCertificate;
  }

  const { type } = application;

  // Create certificate (CRVS model - no FamilyMember references)
  const certificate = await Certificate.create({
    applicationId,
    certificateNumber: generateCertificateNumber(type),
    type,
    issuedTo: [], // Empty in CRVS model - certificates are linked to applications only
    issueDate: new Date(),
    issuedBy: adminId,
    status: 'valid',
  });

  // Link certificate to application
  await Application.findByIdAndUpdate(applicationId, {
    certificateId: certificate._id,
  });

  return certificate;
};

/**
 * Get all certificates for a citizen
 * @param {string} userId - User ID
 * @returns {Promise<Array>} List of certificates
 */
export const getCertificatesForCitizen = async (userId) => {
  // Get all applications submitted by this user
  const userApplications = await Application.find({ userId }).select('_id').lean();
  const userApplicationIds = userApplications.map((app) => app._id.toString());

  // Find certificates for applications submitted by this user (CRVS model)
  const certificates = await Certificate.find({
    applicationId: { $in: userApplicationIds },
    status: 'valid',
  })
    .populate('applicationId', 'type payload userId')
    .populate('issuedBy', 'fullName')
    .sort({ issueDate: -1 })
    .lean();

  // Build detailed certificate data for each certificate
  const detailedCertificates = await Promise.all(
    certificates.map(async (cert) => {
      const application = cert.applicationId;
      
      // Skip if application is missing
      if (!application) {
        console.warn(`Certificate ${cert._id} has no associated application`);
        return null;
      }
      
      const payload = application.payload || {};
      const type = cert.type;

      // Build type-specific details
      let details = {};

      if (type === 'birth' && payload.birth?.child) {
        // CRVS model: use payload data directly (no FamilyMember)
        const childData = payload.birth.child;
        const childName = childData.name || 'Unknown';

        // Date of Birth
        let dateOfBirthStr = null;
        if (childData.dateOfBirth) {
          dateOfBirthStr = childData.dateOfBirth instanceof Date
            ? childData.dateOfBirth.toISOString()
            : new Date(childData.dateOfBirth).toISOString();
        }

        // Place of Birth
        const placeOfBirth = childData.placeOfBirth || '';

        // Gender (normalize to lowercase)
        let gender = '';
        if (childData.gender) {
          gender = childData.gender.toString().toLowerCase();
        }

        // Nationality
        const nationality = childData.nationality || 'Somalia';

        // Parent names from snapshots (verified via NIRA)
        const fatherName = payload.birth.fatherSnapshot?.fullName || 'Unknown';
        const motherName = payload.birth.motherSnapshot?.fullName || 'Unknown';

        details = {
          citizenName: childName,
          childName: childName,
          dateOfBirth: dateOfBirthStr,
          placeOfBirth: placeOfBirth,
          gender: gender,
          nationality: nationality,
          fatherName: fatherName,
          motherName: motherName,
          weight: childData.weight,
          height: childData.height,
        };
      } else if (type === 'marriage') {
        // CRVS model: use payload.marriage data directly
        const marriageData = payload.marriage || {};
        const groomName = marriageData.groom?.snapshot?.fullName || 'Unknown';
        const brideName = marriageData.bride?.snapshot?.fullName || 'Unknown';

        // Ensure dateOfMarriage is converted to string
        let dateOfMarriageStr = application?.createdAt
          ? (application.createdAt instanceof Date
              ? application.createdAt.toISOString()
              : new Date(application.createdAt).toISOString())
          : new Date().toISOString();
        if (marriageData.marriageDetails?.date) {
          dateOfMarriageStr = marriageData.marriageDetails.date instanceof Date
            ? marriageData.marriageDetails.date.toISOString()
            : new Date(marriageData.marriageDetails.date).toISOString();
        }

        details = {
          citizenName: `${groomName} & ${brideName}`,
          husbandName: groomName,
          wifeName: brideName,
          dateOfMarriage: dateOfMarriageStr,
          placeOfMarriage: marriageData.marriageDetails?.place || '',
          marriageType: 'Islamic',
        };
      } else if (type === 'death') {
        // CRVS model: death not supported yet
        details = {};

        // Ensure dates are converted to strings
        let dateOfBirthStr = null;
        if (deceased?.dateOfBirth) {
          dateOfBirthStr = deceased.dateOfBirth instanceof Date
            ? deceased.dateOfBirth.toISOString()
            : new Date(deceased.dateOfBirth).toISOString();
        } else if (payload.dateOfBirth) {
          dateOfBirthStr = payload.dateOfBirth instanceof Date
            ? payload.dateOfBirth.toISOString()
            : new Date(payload.dateOfBirth).toISOString();
        }

        let dateOfDeathStr = application?.createdAt
          ? (application.createdAt instanceof Date
              ? application.createdAt.toISOString()
              : new Date(application.createdAt).toISOString())
          : new Date().toISOString();
        if (payload.dateOfDeath) {
          dateOfDeathStr = payload.dateOfDeath instanceof Date
            ? payload.dateOfDeath.toISOString()
            : new Date(payload.dateOfDeath).toISOString();
        }

        const deceasedName = deceased
          ? `${deceased.firstName} ${deceased.lastName}`
          : payload.deceasedName || 'Unknown';

        details = {
          citizenName: deceasedName,
          deceasedName: deceasedName,
          nationalId: deceased?.nationalIdNumber || payload.nationalId || '',
          dateOfBirth: dateOfBirthStr,
          dateOfDeath: dateOfDeathStr,
          placeOfDeath: payload.placeOfDeath || '',
          causeOfDeath: payload.causeOfDeath,
        };
      } else if (type === 'divorce') {
        // CRVS model: divorce not supported yet
        details = {};

        // Ensure divorceDate is converted to string
        let divorceDateStr = application?.createdAt
          ? (application.createdAt instanceof Date
              ? application.createdAt.toISOString()
              : new Date(application.createdAt).toISOString())
          : new Date().toISOString();
        if (payload.divorceDate) {
          divorceDateStr = payload.divorceDate instanceof Date
            ? payload.divorceDate.toISOString()
            : new Date(payload.divorceDate).toISOString();
        }

        const husbandName = husband
          ? `${husband.firstName} ${husband.lastName}`
          : payload.husbandName || 'Unknown';
        const wifeName = wife
          ? `${wife.firstName} ${wife.lastName}`
          : payload.wifeName || 'Unknown';

        details = {
          citizenName: `${husbandName} & ${wifeName}`,
          husbandName: husbandName,
          wifeName: wifeName,
          divorceDate: divorceDateStr,
          court: payload.court || 'Family Court',
          reasonCode: payload.reasonCode,
        };
      }

      // Ensure issueDate is converted to string
      let issueDateStr = new Date().toISOString();
      if (cert.issueDate) {
        issueDateStr = cert.issueDate instanceof Date
          ? cert.issueDate.toISOString()
          : new Date(cert.issueDate).toISOString();
      }

      return {
        id: cert._id.toString(),
        applicationId: application._id?.toString(),
        certificateNumber: cert.certificateNumber,
        type: cert.type,
        issueDate: issueDateStr,
        issuedBy: cert.issuedBy?.fullName || 'System',
        filePath: cert.filePath,
        status: cert.status,
        details: details,
        qrCodeUrl: cert.filePath
          ? `/api/certificates/${cert._id}/qr`
          : null,
        digitalSignatureHash: cert._id.toString(), // Simplified for now
      };
    }),
  );

  // Filter out any null entries (certificates with missing applications)
  return detailedCertificates.filter((cert) => cert !== null);
};

/**
 * Get all certificates (admin only)
 * @param {Object} options - Query options (page, limit, search)
 * @returns {Promise<Object>} Certificates list with pagination
 */
export const getAllCertificates = async (options = {}) => {
  const { page = 1, limit = 50, search = '' } = options;
  const skip = (page - 1) * limit;

  const query = { status: 'valid' };

  if (search && search.trim()) {
    query.$or = [
      { certificateNumber: { $regex: search.trim(), $options: 'i' } },
      { type: { $regex: search.trim(), $options: 'i' } },
    ];
  }

  const [certificates, total] = await Promise.all([
    Certificate.find(query)
      .populate('applicationId', 'type userId')
      .populate('applicationId.userId', 'fullName email')
      .populate('issuedBy', 'fullName')
      .sort({ issueDate: -1 })
      .skip(skip)
      .limit(limit)
      .lean(),
    Certificate.countDocuments(query),
  ]);

  const certificatesWithDetails = certificates.map((cert) => ({
    id: cert._id.toString(),
    applicationId: cert.applicationId?._id?.toString(),
    certificateNumber: cert.certificateNumber,
    type: cert.type,
    issueDate: cert.issueDate,
    issuedBy: cert.issuedBy?.fullName || 'System',
    citizenName: cert.applicationId?.userId?.fullName || 'Unknown',
    citizenEmail: cert.applicationId?.userId?.email || '',
    filePath: cert.filePath,
    status: cert.status,
  }));

  return {
    certificates: certificatesWithDetails,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
};

/**
 * Get certificate data for PDF generation
 * @param {string} certificateId - Certificate ID
 * @param {string} userId - User ID (for access verification)
 * @returns {Promise<Object>} Certificate data
 */
export const getCertificateForDownload = async (certificateId, userId) => {
  // Convert userId to string for consistent comparison
  const userIdStr = userId?.toString();

  // Find certificate directly and verify ownership through application
  const certificate = await Certificate.findById(certificateId)
    .populate('applicationId', 'userId type payload')
    .lean();

  if (!certificate) {
    const error = new Error('Certificate not found');
    error.statusCode = 404;
    throw error;
  }

  // Verify ownership through application
  const application = certificate.applicationId;
  if (!application) {
    const error = new Error('Certificate has no associated application');
    error.statusCode = 400;
    throw error;
  }

  // Check if application belongs to user
  let applicationUserId;
  if (application.userId && typeof application.userId === 'object' && application.userId._id) {
    applicationUserId = application.userId._id.toString();
  } else if (application.userId) {
    applicationUserId = application.userId.toString();
  } else {
    const error = new Error('Application has no associated user');
    error.statusCode = 400;
    throw error;
  }

  if (applicationUserId !== userIdStr) {
    const error = new Error('Access denied: Certificate does not belong to you');
    error.statusCode = 403;
    throw error;
  }

  // Build certificate data for PDF generation using existing certificate
  const payload = application.payload || {};
  const birthData = payload.birth || {};
  const childData = birthData.child || {};

  const details = {
    citizenName: childData.name || 'Unknown',
    childName: childData.name || 'Unknown',
    dateOfBirth: childData.dateOfBirth ? (childData.dateOfBirth instanceof Date ? childData.dateOfBirth.toISOString() : new Date(childData.dateOfBirth).toISOString()) : null,
    placeOfBirth: childData.placeOfBirth || '',
    gender: childData.gender || '',
    nationality: childData.nationality || 'Somalia',
    fatherName: birthData.fatherSnapshot?.fullName || 'Unknown',
    motherName: birthData.motherSnapshot?.fullName || 'Unknown',
    fatherDistrict: birthData.fatherResidence?.district || '',
    fatherSector: birthData.fatherResidence?.sector || '',
    motherDistrict: birthData.motherResidence?.district || '',
    motherSector: birthData.motherResidence?.sector || '',
  };

  return {
    type: certificate.type || 'birth',
    certificateNumber: certificate.certificateNumber,
    details,
    issueDate: certificate.issueDate || new Date(),
    issuedBy: 'System (Auto-issued)',
  };
};

/**
 * Generate Birth Certificate from approved Birth application
 * Auto-issues certificate without admin approval
 * @param {string} applicationId - Application ID
 * @param {string} userId - User ID requesting the certificate
 * @returns {Promise<Object>} Certificate info with download URL
 */
export const generateBirthCertificate = async (applicationId, userId) => {
  // Convert userId to string for consistent comparison
  const userIdStr = userId?.toString();

  // Find the application
  const application = await Application.findById(applicationId)
    .populate('userId', 'fullName email')
    .lean();

  if (!application) {
    const error = new Error('Application not found');
    error.statusCode = 404;
    throw error;
  }

  // Verify application belongs to user
  // Handle both populated and non-populated userId
  let applicationUserId;
  if (application.userId && typeof application.userId === 'object' && application.userId._id) {
    // userId is populated (object with _id)
    applicationUserId = application.userId._id.toString();
  } else if (application.userId) {
    // userId is not populated (just ObjectId)
    applicationUserId = application.userId.toString();
  } else {
    const error = new Error('Application has no associated user');
    error.statusCode = 400;
    throw error;
  }

  // Compare user IDs (both as strings)
  if (applicationUserId !== userIdStr) {
    console.error('User ID mismatch:', {
      applicationUserId,
      userIdStr,
      applicationId: applicationId.toString(),
    });
    const error = new Error('Access denied: Application does not belong to you');
    error.statusCode = 403;
    throw error;
  }

  // Validate application type and status
  if (application.applicationType !== 'BIRTH' && application.type !== 'birth') {
    const error = new Error('Application is not a Birth application');
    error.statusCode = 400;
    throw error;
  }

  if (application.status !== 'approved') {
    const error = new Error('Application must be approved before generating certificate');
    error.statusCode = 400;
    throw error;
  }

  // Check if certificate already exists
  let certificate = await Certificate.findOne({ applicationId }).lean();

  if (certificate) {
    // Certificate already exists, return it
    return {
      certificateId: certificate._id.toString(),
      certificateNumber: certificate.certificateNumber,
      filePath: certificate.filePath,
      downloadUrl: `/api/certificates/${certificate._id}/download`,
      issueDate: certificate.issueDate instanceof Date
        ? certificate.issueDate.toISOString()
        : new Date(certificate.issueDate).toISOString(),
    };
  }

  // Build certificate data for PDF generation
  const certificateData = await buildCertificateDataForApplication(application);

  // Generate PDF
  const pdfBuffer = await generateCertificatePDF(certificateData);

  // Ensure certificates directory exists
  const certificatesDir = path.join(__dirname, '../uploads/certificates');
  await fs.mkdir(certificatesDir, { recursive: true });

  // Save PDF file
  const fileName = `birth_${certificateData.certificateNumber}_${Date.now()}.pdf`;
  const filePath = path.join(certificatesDir, fileName);
  await fs.writeFile(filePath, pdfBuffer);

  // Create certificate record
  certificate = await Certificate.create({
    applicationId,
    certificateNumber: certificateData.certificateNumber,
    type: 'birth',
    issuedTo: [],
    issueDate: new Date(),
    issuedBy: null, // Auto-issued, no admin
    filePath: `/uploads/certificates/${fileName}`,
    status: 'valid',
  });

  // Link certificate to application
  await Application.findByIdAndUpdate(applicationId, {
    certificateId: certificate._id,
  });

  return {
    certificateId: certificate._id.toString(),
    certificateNumber: certificate.certificateNumber,
    filePath: certificate.filePath,
    downloadUrl: `/api/certificates/${certificate._id}/download`,
    issueDate: certificate.issueDate instanceof Date
      ? certificate.issueDate.toISOString()
      : new Date(certificate.issueDate).toISOString(),
  };
};

/**
 * Get certificate by application ID
 * @param {string} applicationId - Application ID
 * @param {string} userId - User ID (for access verification)
 * @returns {Promise<Object|null>} Certificate info or null if not found
 */
export const getCertificateByApplicationId = async (applicationId, userId) => {
  // Convert userId to string for consistent comparison
  const userIdStr = userId?.toString();

  // Find application first to verify ownership
  const application = await Application.findById(applicationId)
    .populate('userId', 'fullName email')
    .lean();

  if (!application) {
    const error = new Error('Application not found');
    error.statusCode = 404;
    throw error;
  }

  // Verify application belongs to user
  let applicationUserId;
  if (application.userId && typeof application.userId === 'object' && application.userId._id) {
    applicationUserId = application.userId._id.toString();
  } else if (application.userId) {
    applicationUserId = application.userId.toString();
  } else {
    const error = new Error('Application has no associated user');
    error.statusCode = 400;
    throw error;
  }

  if (applicationUserId !== userIdStr) {
    const error = new Error('Access denied: Application does not belong to you');
    error.statusCode = 403;
    throw error;
  }

  // Find certificate for this application
  const certificate = await Certificate.findOne({ applicationId }).lean();

  if (!certificate) {
    return null; // No certificate found
  }

  return {
    certificateId: certificate._id.toString(),
    applicationId: applicationId.toString(),
    certificateNumber: certificate.certificateNumber,
    filePath: certificate.filePath,
    downloadUrl: `/api/certificates/${certificate._id}/download`,
    issueDate: certificate.issueDate instanceof Date
      ? certificate.issueDate.toISOString()
      : new Date(certificate.issueDate).toISOString(),
    type: certificate.type,
    status: certificate.status,
  };
};

/**
 * Build certificate data structure for PDF generation from application
 * @param {Object} application - Application document
 * @returns {Promise<Object>} Certificate data
 */
async function buildCertificateDataForApplication(application) {
  const payload = application.payload || {};
  const birthData = payload.birth || {};

  // Build birth certificate details
  const childData = birthData.child || {};
  const childName = childData.name || 'Unknown';

  // Date of Birth
  let dateOfBirthStr = null;
  if (childData.dateOfBirth) {
    dateOfBirthStr = childData.dateOfBirth instanceof Date
      ? childData.dateOfBirth.toISOString()
      : new Date(childData.dateOfBirth).toISOString();
  }

  // Parent names from snapshots (verified via NIRA)
  const fatherName = birthData.fatherSnapshot?.fullName || 'Unknown';
  const motherName = birthData.motherSnapshot?.fullName || 'Unknown';

  // Residence information
  const fatherDistrict = birthData.fatherResidence?.district || '';
  const fatherSector = birthData.fatherResidence?.sector || '';
  const motherDistrict = birthData.motherResidence?.district || '';
  const motherSector = birthData.motherResidence?.sector || '';

  const details = {
    citizenName: childName,
    childName: childName,
    dateOfBirth: dateOfBirthStr,
    placeOfBirth: childData.placeOfBirth || '',
    gender: childData.gender || '',
    nationality: childData.nationality || 'Somalia',
    fatherName: fatherName,
    motherName: motherName,
    fatherDistrict: fatherDistrict,
    fatherSector: fatherSector,
    motherDistrict: motherDistrict,
    motherSector: motherSector,
  };

  // Generate certificate number
  const certificateNumber = generateCertificateNumber('birth');

  return {
    type: 'birth',
    certificateNumber,
    details,
    issueDate: new Date(),
    issuedBy: 'System (Auto-issued)',
  };
}

/**
 * Build certificate data from existing certificate
 * @param {Object} cert - Certificate document
 * @param {Object} application - Application document
 * @returns {Promise<Object>} Certificate data
 */
async function buildCertificateData(cert, application) {
  const payload = application.payload || {};
  const birthData = payload.birth || {};
  const childData = birthData.child || {};

  const details = {
    citizenName: childData.name || 'Unknown',
    childName: childData.name || 'Unknown',
    dateOfBirth: childData.dateOfBirth ? (childData.dateOfBirth instanceof Date ? childData.dateOfBirth.toISOString() : new Date(childData.dateOfBirth).toISOString()) : null,
    placeOfBirth: childData.placeOfBirth || '',
    gender: childData.gender || '',
    nationality: childData.nationality || 'Somalia',
    fatherName: birthData.fatherSnapshot?.fullName || 'Unknown',
    motherName: birthData.motherSnapshot?.fullName || 'Unknown',
    fatherDistrict: birthData.fatherResidence?.district || '',
    fatherSector: birthData.fatherResidence?.sector || '',
    motherDistrict: birthData.motherResidence?.district || '',
    motherSector: birthData.motherResidence?.sector || '',
  };

  return {
    type: 'birth',
    certificateNumber: cert.certificateNumber,
    details,
    issueDate: cert.issueDate || new Date(),
    issuedBy: 'System (Auto-issued)',
  };
}

