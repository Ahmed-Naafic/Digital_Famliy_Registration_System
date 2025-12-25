import Application from '../models/Application.model.js';
import FamilyMember from '../models/FamilyMember.model.js';
import Family from '../models/Family.model.js';
import { createCertificate } from './certificate.service.js';

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

/**
 * Get all pending applications (admin only)
 * @returns {Promise<Array>} List of pending applications
 */
export const getPendingApplications = async () => {
  const applications = await Application.find({ status: 'pending' })
    .populate('userId', 'fullName email')
    .populate('familyId', 'familyName')
    .sort({ createdAt: -1 }) // Newest first
    .lean();

  return applications;
};

/**
 * Get applications by status (admin only)
 * @param {string} status - Application status: 'pending', 'approved', or 'rejected'
 * @returns {Promise<Array>} List of applications with the specified status
 */
export const getApplicationsByStatus = async (status) => {
  if (!['pending', 'approved', 'rejected'].includes(status)) {
    const error = new Error('Invalid status. Must be pending, approved, or rejected');
    error.statusCode = 400;
    throw error;
  }

  const applications = await Application.find({ status })
    .populate('userId', 'fullName email')
    .populate('familyId', 'familyName')
    .populate('reviewedBy', 'fullName email')
    .sort({ createdAt: -1 }) // Newest first
    .lean();

  return applications;
};

/**
 * Approve an application and apply domain logic
 * @param {string} applicationId - Application ID
 * @param {string} adminId - Admin user ID
 * @returns {Promise<Object>} Updated application
 */
export const approveApplication = async (applicationId, adminId) => {
  const application = await Application.findById(applicationId)
    .populate('familyId')
    .lean();

  if (!application) {
    const error = new Error('Application not found');
    error.statusCode = 404;
    throw error;
  }

  if (application.status !== 'pending') {
    const error = new Error('Application is not pending');
    error.statusCode = 400;
    throw error;
  }

  const { type, payload, familyId } = application;

  // Validate familyId exists
  if (!familyId) {
    const error = new Error('Application does not have an associated family');
    error.statusCode = 400;
    throw error;
  }

  // Get familyId as ObjectId (handle both populated and non-populated cases)
  const familyIdObj = familyId._id || familyId;

  if (!familyIdObj) {
    const error = new Error('Invalid family ID in application');
    error.statusCode = 400;
    throw error;
  }

  // Apply domain logic based on application type
  if (type === 'birth') {
    await processBirthApproval(payload, familyIdObj, applicationId);
  } else if (type === 'marriage') {
    await processMarriageApproval(payload, familyIdObj);
  } else if (type === 'death') {
    await processDeathApproval(payload, familyIdObj);
  } else if (type === 'divorce') {
    await processDivorceApproval(payload, familyIdObj);
  }

  // Update application status to approved
  const updatedApplication = await Application.findByIdAndUpdate(
    applicationId,
    {
      status: 'approved',
      reviewedBy: adminId,
      reviewedAt: new Date(),
    },
    { new: true },
  )
    .populate('userId', 'fullName email')
    .populate('reviewedBy', 'fullName email')
    .lean();

  // Create certificate for approved application
  try {
    await createCertificate(applicationId, adminId);
  } catch (certError) {
    // Log error but don't fail the approval
    console.error('Error creating certificate:', certError);
  }

  return updatedApplication;
};

/**
 * Reject an application
 * @param {string} applicationId - Application ID
 * @param {string} adminId - Admin user ID
 * @param {string} reason - Rejection reason
 * @returns {Promise<Object>} Updated application
 */
export const rejectApplication = async (applicationId, adminId, reason) => {
  const application = await Application.findById(applicationId);

  if (!application) {
    const error = new Error('Application not found');
    error.statusCode = 404;
    throw error;
  }

  if (application.status !== 'pending') {
    const error = new Error('Application is not pending');
    error.statusCode = 400;
    throw error;
  }

  // Update application status to rejected
  const updatedApplication = await Application.findByIdAndUpdate(
    applicationId,
    {
      status: 'rejected',
      reviewedBy: adminId,
      reviewedAt: new Date(),
      adminComment: reason,
    },
    { new: true },
  )
    .populate('userId', 'fullName email')
    .populate('reviewedBy', 'fullName email')
    .lean();

  return updatedApplication;
};

/**
 * Process birth approval - create child FamilyMember
 */
const processBirthApproval = async (payload, familyId, applicationId) => {
  const { child, fatherId, motherId } = payload;

  if (!child || !fatherId || !motherId) {
    const error = new Error('Invalid birth payload: missing required fields');
    error.statusCode = 400;
    throw error;
  }

  // Parse child name (could be full name or first/last)
  let firstName, lastName;
  if (child.name) {
    const nameParts = child.name.trim().split(/\s+/);
    firstName = nameParts[0] || '';
    lastName = nameParts.slice(1).join(' ') || nameParts[0] || '';
  } else {
    const error = new Error('Child name is required');
    error.statusCode = 400;
    throw error;
  }

  // Normalize gender to lowercase (enum expects 'male' or 'female')
  const normalizedGender = child.gender
    ? child.gender.toString().toLowerCase()
    : null;

  // Validate gender is one of the allowed values
  if (normalizedGender && !['male', 'female'].includes(normalizedGender)) {
    const error = new Error(
      `Invalid gender value: ${child.gender}. Must be 'male' or 'female'`,
    );
    error.statusCode = 400;
    throw error;
  }

  // Create child FamilyMember
  const childMember = await FamilyMember.create({
    familyId: familyId,
    firstName: firstName,
    lastName: lastName,
    gender: normalizedGender,
    dateOfBirth: child.dateOfBirth ? new Date(child.dateOfBirth) : null,
    placeOfBirth: child.placeOfBirth,
    fatherId: fatherId,
    motherId: motherId,
    status: 'alive',
    createdFromApplicationId: applicationId,
  });

  return childMember;
};

/**
 * Process marriage approval - update both members' marital status and spouseId
 */
const processMarriageApproval = async (payload, familyId) => {
  const { husbandId, wifeId } = payload;

  if (!husbandId || !wifeId) {
    const error = new Error('Invalid marriage payload: missing husbandId or wifeId');
    error.statusCode = 400;
    throw error;
  }

  // Verify both members belong to the family
  const husband = await FamilyMember.findOne({
    _id: husbandId,
    familyId: familyId,
  });
  const wife = await FamilyMember.findOne({
    _id: wifeId,
    familyId: familyId,
  });

  if (!husband || !wife) {
    const error = new Error('Husband or wife not found in family');
    error.statusCode = 400;
    throw error;
  }

  // Update both members
  await FamilyMember.findByIdAndUpdate(husbandId, {
    maritalStatus: 'married',
    spouseId: wifeId,
  });

  await FamilyMember.findByIdAndUpdate(wifeId, {
    maritalStatus: 'married',
    spouseId: husbandId,
  });
};

/**
 * Process death approval - update member status to deceased
 */
const processDeathApproval = async (payload, familyId) => {
  const { deceasedId } = payload;

  if (!deceasedId) {
    const error = new Error('Invalid death payload: missing deceasedId');
    error.statusCode = 400;
    throw error;
  }

  // Verify member belongs to the family
  const deceased = await FamilyMember.findOne({
    _id: deceasedId,
    familyId: familyId,
  });

  if (!deceased) {
    const error = new Error('Deceased member not found in family');
    error.statusCode = 400;
    throw error;
  }

  // Update member status to deceased
  await FamilyMember.findByIdAndUpdate(deceasedId, {
    status: 'deceased',
  });
};

/**
 * Process divorce approval - update both members' marital status and clear spouseId
 */
const processDivorceApproval = async (payload, familyId) => {
  const { husbandId, wifeId } = payload;

  if (!husbandId || !wifeId) {
    const error = new Error('Invalid divorce payload: missing husbandId or wifeId');
    error.statusCode = 400;
    throw error;
  }

  // Verify both members belong to the family
  const husband = await FamilyMember.findOne({
    _id: husbandId,
    familyId: familyId,
  });
  const wife = await FamilyMember.findOne({
    _id: wifeId,
    familyId: familyId,
  });

  if (!husband || !wife) {
    const error = new Error('Husband or wife not found in family');
    error.statusCode = 400;
    throw error;
  }

  // Update both members
  await FamilyMember.findByIdAndUpdate(husbandId, {
    maritalStatus: 'divorced',
    spouseId: null,
  });

  await FamilyMember.findByIdAndUpdate(wifeId, {
    maritalStatus: 'divorced',
    spouseId: null,
  });
};

