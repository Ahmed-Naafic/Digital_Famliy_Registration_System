import { successResponse } from '../utils/response.util.js';
import {
  getDistricts,
  getSectorsByDistrict,
  getRegions,
} from '../services/location.service.js';

/**
 * Get all districts
 * GET /api/locations/districts?region=Banadir
 */
export const getDistrictsController = async (req, res, next) => {
  try {
    const { region } = req.query;
    const districts = await getDistricts(region || null);

    return successResponse(
      res,
      'Districts retrieved successfully',
      districts,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get sectors by district
 * GET /api/locations/sectors?district=Hodan&region=Banadir
 */
export const getSectorsController = async (req, res, next) => {
  try {
    const { district, region } = req.query;

    if (!district) {
      const error = new Error('District parameter is required');
      error.statusCode = 400;
      return next(error);
    }

    const sectors = await getSectorsByDistrict(district, region || null);

    return successResponse(
      res,
      'Sectors retrieved successfully',
      sectors,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get all regions
 * GET /api/locations/regions
 */
export const getRegionsController = async (req, res, next) => {
  try {
    const regions = await getRegions();

    return successResponse(
      res,
      'Regions retrieved successfully',
      regions,
    );
  } catch (error) {
    next(error);
  }
};

