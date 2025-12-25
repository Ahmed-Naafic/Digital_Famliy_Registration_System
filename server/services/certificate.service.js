import Certificate from '../models/Certificate.model.js';
import Application from '../models/Application.model.js';
import FamilyMember from '../models/FamilyMember.model.js';
import Family from '../models/Family.model.js';

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
    .populate('familyId')
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

  const { type, payload, userId, familyId } = application;

  // Extract member IDs based on application type
  let issuedTo = [];
  if (type === 'birth' && payload.child) {
    // For birth, find the child member created from this application
    const childMember = await FamilyMember.findOne({
      createdFromApplicationId: applicationId,
    });
    if (childMember) {
      issuedTo = [childMember._id];
    }
  } else if (type === 'marriage' && payload.husbandId && payload.wifeId) {
    // For marriage, both spouses
    const husband = await FamilyMember.findById(payload.husbandId);
    const wife = await FamilyMember.findById(payload.wifeId);
    if (husband && wife) {
      issuedTo = [husband._id, wife._id];
    }
  } else if (type === 'divorce' && payload.husbandId && payload.wifeId) {
    // For divorce, both parties
    const husband = await FamilyMember.findById(payload.husbandId);
    const wife = await FamilyMember.findById(payload.wifeId);
    if (husband && wife) {
      issuedTo = [husband._id, wife._id];
    }
  } else if (type === 'death' && payload.deceasedId) {
    // For death, the deceased member
    const deceased = await FamilyMember.findById(payload.deceasedId);
    if (deceased) {
      issuedTo = [deceased._id];
    }
  }

  // Create certificate
  const certificate = await Certificate.create({
    applicationId,
    certificateNumber: generateCertificateNumber(type),
    type,
    issuedTo,
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
  // Find user's family
  const family = await Family.findOne({
    linkedUsers: userId,
    status: 'active',
  });

  if (!family) {
    return [];
  }

  // Get all family members
  const familyMembers = await FamilyMember.find({ familyId: family._id }).lean();
  const memberIds = familyMembers.map((m) => m._id);

  // Get all applications submitted by this user
  const userApplications = await Application.find({ userId }).select('_id').lean();
  const userApplicationIds = userApplications.map((app) => app._id.toString());

  // Find certificates:
  // 1. Issued to any of the user's family members, OR
  // 2. For applications submitted by this user
  const certificates = await Certificate.find({
    $or: [
      { issuedTo: { $in: memberIds }, status: 'valid' },
      { applicationId: { $in: userApplicationIds }, status: 'valid' },
    ],
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

      if (type === 'birth' && payload.child) {
        // Get child member created from this application
        const childMember = await FamilyMember.findOne({
          createdFromApplicationId: application._id,
        })
          .populate('fatherId', 'firstName lastName')
          .populate('motherId', 'firstName lastName')
          .lean();

        // Use childMember data if available, otherwise fall back to payload
        const childName = childMember
          ? `${childMember.firstName} ${childMember.lastName}`
          : payload.child.name || 'Unknown';

        // Date of Birth: prefer childMember, fallback to payload
        let dateOfBirthStr = null;
        if (childMember?.dateOfBirth) {
          dateOfBirthStr = childMember.dateOfBirth instanceof Date
            ? childMember.dateOfBirth.toISOString()
            : new Date(childMember.dateOfBirth).toISOString();
        } else if (payload.child.dateOfBirth) {
          dateOfBirthStr = payload.child.dateOfBirth instanceof Date
            ? payload.child.dateOfBirth.toISOString()
            : new Date(payload.child.dateOfBirth).toISOString();
        }

        // Place of Birth: prefer childMember, fallback to payload
        const placeOfBirth = childMember?.placeOfBirth || payload.child.placeOfBirth || '';

        // Gender: prefer childMember, fallback to payload (normalize to lowercase)
        let gender = '';
        if (childMember?.gender) {
          gender = childMember.gender;
        } else if (payload.child.gender) {
          gender = payload.child.gender.toString().toLowerCase();
        }

        // Nationality: always 'Somalia' for birth certificates
        const nationality = 'Somalia';

        // Parent names: prefer populated childMember, fallback to payload
        let fatherName = 'Unknown';
        if (childMember?.fatherId) {
          fatherName = `${childMember.fatherId.firstName} ${childMember.fatherId.lastName}`;
        } else if (payload.fatherName) {
          fatherName = payload.fatherName;
        } else if (payload.fatherId) {
          // Try to fetch father if we have the ID
          const father = await FamilyMember.findById(payload.fatherId).lean();
          if (father) {
            fatherName = `${father.firstName} ${father.lastName}`;
          }
        }

        let motherName = 'Unknown';
        if (childMember?.motherId) {
          motherName = `${childMember.motherId.firstName} ${childMember.motherId.lastName}`;
        } else if (payload.motherName) {
          motherName = payload.motherName;
        } else if (payload.motherId) {
          // Try to fetch mother if we have the ID
          const mother = await FamilyMember.findById(payload.motherId).lean();
          if (mother) {
            motherName = `${mother.firstName} ${mother.lastName}`;
          }
        }

        details = {
          citizenName: childName,
          childName: childName,
          dateOfBirth: dateOfBirthStr,
          placeOfBirth: placeOfBirth,
          gender: gender,
          nationality: nationality,
          fatherName: fatherName,
          motherName: motherName,
          weight: payload.child?.weight,
          height: payload.child?.height,
        };
      } else if (type === 'marriage') {
        const husband = await FamilyMember.findById(payload.husbandId)
          .lean();
        const wife = await FamilyMember.findById(payload.wifeId).lean();

        // Ensure dateOfMarriage is converted to string
        let dateOfMarriageStr = application?.createdAt
          ? (application.createdAt instanceof Date
              ? application.createdAt.toISOString()
              : new Date(application.createdAt).toISOString())
          : new Date().toISOString();
        if (payload.dateOfMarriage) {
          dateOfMarriageStr = payload.dateOfMarriage instanceof Date
            ? payload.dateOfMarriage.toISOString()
            : new Date(payload.dateOfMarriage).toISOString();
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
          dateOfMarriage: dateOfMarriageStr,
          placeOfMarriage: payload.placeOfMarriage || '',
          marriageType: payload.marriageType || 'Civil',
        };
      } else if (type === 'death') {
        const deceased = await FamilyMember.findById(payload.deceasedId).lean();

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
        const husband = await FamilyMember.findById(payload.husbandId)
          .lean();
        const wife = await FamilyMember.findById(payload.wifeId).lean();

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
  // Get user's certificates to verify access
  const certificates = await getCertificatesForCitizen(userId);
  const certificate = certificates.find((cert) => cert.id === certificateId);

  if (!certificate) {
    const error = new Error('Certificate not found or access denied');
    error.statusCode = 404;
    throw error;
  }

  return certificate;
};

