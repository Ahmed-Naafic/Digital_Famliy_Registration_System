import Application from '../models/Application.model.js';
import FamilyMember from '../models/FamilyMember.model.js';
import Family from '../models/Family.model.js';

const APPLICATION_TYPES = ['birth', 'marriage', 'divorce', 'death'];

/**
 * Submit a new application
 * @param {Object} params - Application data
 * @param {string} params.userId - User ID from token
 * @param {string} params.type - Application type (birth, marriage, divorce, death)
 * @param {Object} params.payload - Form data
 * @param {Array} params.documents - Document metadata array
 * @returns {Promise<Object>} Created application
 */
export const submitApplication = async ({ userId, type, payload, documents = [] }) => {
  // Validate application type
  if (!APPLICATION_TYPES.includes(type)) {
    const error = new Error(`Invalid application type. Must be one of: ${APPLICATION_TYPES.join(', ')}`);
    error.statusCode = 400;
    throw error;
  }

  // Validate required fields
  if (!payload || typeof payload !== 'object' || Object.keys(payload).length === 0) {
    const error = new Error('Payload is required and must be a non-empty object');
    error.statusCode = 400;
    throw error;
  }

  // Validate documents array - must contain valid metadata objects only
  if (documents && documents.length > 0) {
    for (const doc of documents) {
      if (!doc.fileName || !doc.filePath) {
        const error = new Error('Invalid document metadata. fileName and filePath are required');
        error.statusCode = 400;
        throw error;
      }
    }
  }

  // Get user's family for validation
  const family = await Family.findOne({
    linkedUsers: userId,
    status: 'active',
  });

  if (!family) {
    const error = new Error('User does not have an active family');
    error.statusCode = 400;
    throw error;
  }

  // Validate application-specific requirements
  await validateApplicationPayload(type, payload, family._id);

  // Create application with status 'pending'
  const application = await Application.create({
    userId,
    familyId: family._id,
    type,
    payload,
    documents: documents && documents.length > 0 ? documents : [],
    status: 'pending',
  });

  // Populate userId to return user info if needed
  await application.populate('userId', 'fullName email');

  return application;
};

/**
 * Validate application payload based on type
 * Ensures IDs are provided and belong to user's family
 * @param {string} type - Application type
 * @param {Object} payload - Payload to validate
 * @param {ObjectId} familyId - User's family ID
 * @throws {Error} If validation fails
 */
const validateApplicationPayload = async (type, payload, familyId) => {
  if (type === 'birth') {
    // Birth requires fatherId and motherId
    if (!payload.fatherId || !payload.motherId) {
      const error = new Error('Birth registration requires fatherId and motherId');
      error.statusCode = 400;
      throw error;
    }

    // Validate father belongs to family
    const father = await FamilyMember.findOne({
      _id: payload.fatherId,
      familyId: familyId,
    });
    if (!father) {
      const error = new Error('Father must belong to your family');
      error.statusCode = 400;
      throw error;
    }

    // Validate mother belongs to family
    const mother = await FamilyMember.findOne({
      _id: payload.motherId,
      familyId: familyId,
    });
    if (!mother) {
      const error = new Error('Mother must belong to your family');
      error.statusCode = 400;
      throw error;
    }
  } else if (type === 'marriage') {
    // Marriage requires husbandId and wifeId
    if (!payload.husbandId || !payload.wifeId) {
      const error = new Error('Marriage registration requires husbandId and wifeId');
      error.statusCode = 400;
      throw error;
    }

    // Validate husband belongs to family
    const husband = await FamilyMember.findOne({
      _id: payload.husbandId,
      familyId: familyId,
    });
    if (!husband) {
      const error = new Error('Husband must belong to your family');
      error.statusCode = 400;
      throw error;
    }

    // Validate wife belongs to family
    const wife = await FamilyMember.findOne({
      _id: payload.wifeId,
      familyId: familyId,
    });
    if (!wife) {
      const error = new Error('Wife must belong to your family');
      error.statusCode = 400;
      throw error;
    }
  } else if (type === 'death') {
    // Death requires deceasedId
    if (!payload.deceasedId) {
      const error = new Error('Death registration requires deceasedId');
      error.statusCode = 400;
      throw error;
    }

    // Validate deceased belongs to family
    const deceased = await FamilyMember.findOne({
      _id: payload.deceasedId,
      familyId: familyId,
    });
    if (!deceased) {
      const error = new Error('Deceased must belong to your family');
      error.statusCode = 400;
      throw error;
    }
  } else if (type === 'divorce') {
    // Divorce requires husbandId and wifeId (already validated in divorce flow)
    if (!payload.husbandId || !payload.wifeId) {
      const error = new Error('Divorce registration requires husbandId and wifeId');
      error.statusCode = 400;
      throw error;
    }

    // Validate husband belongs to family
    const husband = await FamilyMember.findOne({
      _id: payload.husbandId,
      familyId: familyId,
    });
    if (!husband) {
      const error = new Error('Husband must belong to your family');
      error.statusCode = 400;
      throw error;
    }

    // Validate wife belongs to family
    const wife = await FamilyMember.findOne({
      _id: payload.wifeId,
      familyId: familyId,
    });
    if (!wife) {
      const error = new Error('Wife must belong to your family');
      error.statusCode = 400;
      throw error;
    }
  }
};

/**
 * Get all applications for a specific user
 * @param {string} userId - User ID
 * @returns {Promise<Array>} List of user's applications, sorted by newest first
 */
export const getUserApplications = async (userId) => {
  const applications = await Application.find({ userId })
    .populate('userId', 'fullName email')
    .sort({ createdAt: -1 }) // Newest first
    .lean();

  return applications;
};

/**
 * Get application by ID, ensuring it belongs to the user
 * @param {string} applicationId - Application ID
 * @param {string} userId - User ID (to verify ownership)
 * @returns {Promise<Object>} Application details
 */
export const getApplicationById = async (applicationId, userId) => {
  const application = await Application.findById(applicationId)
    .populate('userId', 'fullName email')
    .populate('reviewedBy', 'fullName email')
    .lean();

  if (!application) {
    const error = new Error('Application not found');
    error.statusCode = 404;
    throw error;
  }

  // Ensure application belongs to the user
  if (application.userId._id.toString() !== userId.toString()) {
    const error = new Error('Access denied. This application does not belong to you');
    error.statusCode = 403;
    throw error;
  }

  return application;
};

