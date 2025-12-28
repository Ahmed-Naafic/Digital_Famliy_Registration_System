import { successResponse } from '../utils/response.util.js';
import {
  validateApplicationType,
  validatePayload,
  normalizePayload,
} from '../utils/validation.util.js';
import { normalizeDocuments } from '../utils/application.util.js';
import {
  createBirthApplication,
  createMarriageApplication,
  getUserApplications,
  getApplicationById,
} from '../services/application.service.js';

/**
 * Submit a new application
 * POST /api/applications
 * Accepts multipart/form-data with files
 */
export const createApplication = async (req, res, next) => {
  try {
    const { type, payload } = req.body;
    const userId = req.user.id; // From auth middleware
    const files = req.files || []; // Files from multer

    // Validate and normalize application type
    const normalizedType = validateApplicationType(type);

    // Normalize payload (parse JSON string if needed)
    const normalizedPayload = normalizePayload(payload);

    // Validate payload structure
    validatePayload(normalizedPayload);

    // Normalize document metadata from uploaded files
    const documents = normalizeDocuments(files);

    // Submit application via service
    const application = await submitApplication({
      userId,
      type: normalizedType,
      payload: normalizedPayload,
      documents,
    });

    return successResponse(
      res,
      'Application submitted successfully',
      application,
      201,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get all applications for the logged-in user
 * GET /api/applications/my
 */
export const getMyApplications = async (req, res, next) => {
  try {
    const userId = req.user.id; // From auth middleware

    const applications = await getUserApplications(userId);

    return successResponse(res, 'Applications retrieved successfully', applications);
  } catch (error) {
    next(error);
  }
};

/**
 * Get application by ID (must belong to logged-in user)
 * GET /api/applications/:id
 */
export const getApplication = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.id; // From auth middleware

    const application = await getApplicationById(id, userId);

    return successResponse(res, 'Application retrieved successfully', application);
  } catch (error) {
    next(error);
  }
};

/**
 * Create a Birth application (CRVS)
 * POST /api/applications/birth
 * Accepts multipart/form-data with files
 */
export const createBirthApplicationController = async (req, res, next) => {
  try {
    const {
      applicantNationalId,
      child,
      fatherNationalId,
      motherNationalId,
      fatherResidence,
      motherResidence,
    } = req.body;
    const userId = req.user.id; // From auth middleware
    const files = req.files || []; // Files from multer

    // Validate required fields
    if (!applicantNationalId) {
      const error = new Error('Applicant National ID is required');
      error.statusCode = 400;
      return next(error);
    }

    if (!child) {
      const error = new Error('Child information is required');
      error.statusCode = 400;
      return next(error);
    }

    if (!fatherNationalId) {
      const error = new Error('Father National ID is required');
      error.statusCode = 400;
      return next(error);
    }

    if (!motherNationalId) {
      const error = new Error('Mother National ID is required');
      error.statusCode = 400;
      return next(error);
    }

    if (!fatherResidence) {
      const error = new Error('Father residence (district, sector) is required');
      error.statusCode = 400;
      return next(error);
    }

    if (!motherResidence) {
      const error = new Error('Mother residence (district, sector) is required');
      error.statusCode = 400;
      return next(error);
    }

    // Parse JSON strings if needed
    let childData = child;
    if (typeof child === 'string') {
      try {
        childData = JSON.parse(child);
      } catch (e) {
        const error = new Error('Invalid child data format');
        error.statusCode = 400;
        return next(error);
      }
    }

    let fatherResidenceData = fatherResidence;
    if (typeof fatherResidence === 'string') {
      try {
        fatherResidenceData = JSON.parse(fatherResidence);
      } catch (e) {
        const error = new Error('Invalid father residence data format');
        error.statusCode = 400;
        return next(error);
      }
    }

    let motherResidenceData = motherResidence;
    if (typeof motherResidence === 'string') {
      try {
        motherResidenceData = JSON.parse(motherResidence);
      } catch (e) {
        const error = new Error('Invalid mother residence data format');
        error.statusCode = 400;
        return next(error);
      }
    }

    // Normalize document metadata from uploaded files
    const documents = normalizeDocuments(files);

    // Create birth application via service (NIRA verification happens inside)
    const application = await createBirthApplication({
      userId,
      applicantNationalId,
      child: childData,
      fatherNationalId,
      motherNationalId,
      fatherResidence: fatherResidenceData,
      motherResidence: motherResidenceData,
      documents,
    });

    return successResponse(
      res,
      'Birth application submitted successfully',
      application,
      201,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Create a Marriage application (CRVS - Islamic Law)
 * POST /api/applications/marriage
 * Accepts multipart/form-data with files
 */
export const createMarriageApplicationController = async (req, res, next) => {
  try {
    const {
      applicantNationalId,
      groomNationalId,
      brideNationalId,
      wali,
      witnesses,
      sheikh,
      meher,
      marriageDetails,
    } = req.body;
    const userId = req.user.id; // From auth middleware
    const files = req.files || []; // Files from multer

    // Validate required fields
    if (!applicantNationalId) {
      const error = new Error('Applicant National ID is required');
      error.statusCode = 400;
      return next(error);
    }

    if (!groomNationalId) {
      const error = new Error('Groom National ID is required');
      error.statusCode = 400;
      return next(error);
    }

    if (!brideNationalId) {
      const error = new Error('Bride National ID is required');
      error.statusCode = 400;
      return next(error);
    }

    if (!wali) {
      const error = new Error('Wali information is required');
      error.statusCode = 400;
      return next(error);
    }

    if (!witnesses) {
      const error = new Error('Witnesses are required');
      error.statusCode = 400;
      return next(error);
    }

    if (!sheikh) {
      const error = new Error('Sheikh information is required');
      error.statusCode = 400;
      return next(error);
    }

    if (!meher) {
      const error = new Error('Meher information is required');
      error.statusCode = 400;
      return next(error);
    }

    if (!marriageDetails) {
      const error = new Error('Marriage details are required');
      error.statusCode = 400;
      return next(error);
    }

    // Parse JSON strings if needed
    let waliData = wali;
    if (typeof wali === 'string') {
      try {
        waliData = JSON.parse(wali);
      } catch (e) {
        const error = new Error('Invalid wali data format');
        error.statusCode = 400;
        return next(error);
      }
    }

    let witnessesData = witnesses;
    if (typeof witnesses === 'string') {
      try {
        witnessesData = JSON.parse(witnesses);
      } catch (e) {
        const error = new Error('Invalid witnesses data format');
        error.statusCode = 400;
        return next(error);
      }
    }

    let sheikhData = sheikh;
    if (typeof sheikh === 'string') {
      try {
        sheikhData = JSON.parse(sheikh);
      } catch (e) {
        const error = new Error('Invalid sheikh data format');
        error.statusCode = 400;
        return next(error);
      }
    }

    let meherData = meher;
    if (typeof meher === 'string') {
      try {
        meherData = JSON.parse(meher);
      } catch (e) {
        const error = new Error('Invalid meher data format');
        error.statusCode = 400;
        return next(error);
      }
    }

    let marriageDetailsData = marriageDetails;
    if (typeof marriageDetails === 'string') {
      try {
        marriageDetailsData = JSON.parse(marriageDetails);
      } catch (e) {
        const error = new Error('Invalid marriage details data format');
        error.statusCode = 400;
        return next(error);
      }
    }

    // Normalize document metadata from uploaded files
    const documents = normalizeDocuments(files);

    // Create marriage application via service (NIRA verification and Islamic validation happens inside)
    const application = await createMarriageApplication({
      userId,
      applicantNationalId,
      groomNationalId,
      brideNationalId,
      wali: waliData,
      witnesses: witnessesData,
      sheikh: sheikhData,
      meher: meherData,
      marriageDetails: marriageDetailsData,
      documents,
    });

    return successResponse(
      res,
      'Marriage application submitted successfully',
      application,
      201,
    );
  } catch (error) {
    next(error);
  }
};

