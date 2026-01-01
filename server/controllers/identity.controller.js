import { successResponse } from '../utils/response.util.js';
import { fetchPersonByNationalId } from '../services/nira.service.js';

/**
 * Get person identity from NIRA by National ID
 * GET /api/identity/nira/:nationalId
 */
export const getPersonByIdentity = async (req, res, next) => {
  try {
    const { nationalId } = req.params;

    if (!nationalId) {
      const error = new Error('National ID is required');
      error.statusCode = 400;
      return next(error);
    }

    // Fetch identity from NIRA via service
    const identityData = await fetchPersonByNationalId(nationalId);

    return successResponse(
      res,
      'Identity retrieved successfully',
      identityData,
    );
  } catch (error) {
    next(error);
  }
};


