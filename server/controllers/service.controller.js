import { successResponse } from '../utils/response.util.js';
import { getEnabledServices } from '../services/admin.service.js';

/**
 * Get enabled services (public/citizen endpoint)
 * GET /api/services/enabled
 */
export const getEnabledServicesController = async (req, res, next) => {
  try {
    const enabledServices = await getEnabledServices();

    return successResponse(
      res,
      'Enabled services retrieved successfully',
      enabledServices,
    );
  } catch (error) {
    next(error);
  }
};



