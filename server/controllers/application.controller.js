import { successResponse } from '../utils/response.util.js';
import {
  validateApplicationType,
  validatePayload,
  normalizePayload,
} from '../utils/validation.util.js';
import { normalizeDocuments } from '../utils/application.util.js';
import {
  submitApplication,
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

