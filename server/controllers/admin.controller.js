import { successResponse } from '../utils/response.util.js';
import {
  getPendingApplications,
  getApplicationsByStatus,
  approveApplication,
  rejectApplication,
} from '../services/application.service.js';
import { getAdminStatistics, getAllCitizens, getAllFamilies, getFamilyMembersByFamilyId, getServiceStatistics, updateServiceStatus } from '../services/admin.service.js';
// CRVS model: Family functions return empty data
import { getAllCertificates } from '../services/certificate.service.js';
import Application from '../models/Application.model.js';

/**
 * Get all citizens (admin only)
 * GET /api/admin/citizens?page=1&limit=50&search=query
 */
export const getAllCitizensController = async (req, res, next) => {
  try {
    const { page, limit, search } = req.query;
    
    const options = {
      page: page ? parseInt(page, 10) : 1,
      limit: limit ? parseInt(limit, 10) : 50,
      search: search || '',
    };

    const result = await getAllCitizens(options);

    return successResponse(
      res,
      'Citizens retrieved successfully',
      result,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get all families (admin only)
 * GET /api/admin/families?page=1&limit=50&search=query
 */
export const getAllFamiliesController = async (req, res, next) => {
  try {
    const { page, limit, search } = req.query;
    
    const options = {
      page: page ? parseInt(page, 10) : 1,
      limit: limit ? parseInt(limit, 10) : 50,
      search: search || '',
    };

    const result = await getAllFamilies(options);

    return successResponse(
      res,
      'Families retrieved successfully',
      result,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get family members by family ID (admin only)
 * GET /api/admin/families/:familyId/members
 */
export const getFamilyMembersController = async (req, res, next) => {
  try {
    const { familyId } = req.params;

    if (!familyId) {
      const error = new Error('Family ID is required');
      error.statusCode = 400;
      throw error;
    }

    const members = await getFamilyMembersByFamilyId(familyId);

    return successResponse(
      res,
      'Family members retrieved successfully',
      members,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get all certificates (admin only)
 * GET /api/admin/certificates?page=1&limit=50&search=query
 */
export const getAllCertificatesController = async (req, res, next) => {
  try {
    const { page, limit, search } = req.query;
    
    const options = {
      page: page ? parseInt(page, 10) : 1,
      limit: limit ? parseInt(limit, 10) : 50,
      search: search || '',
    };

    const result = await getAllCertificates(options);

    return successResponse(
      res,
      'Certificates retrieved successfully',
      result,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get service-specific statistics (admin only)
 * GET /api/admin/services/statistics
 */
export const getServiceStatisticsController = async (req, res, next) => {
  try {
    const statistics = await getServiceStatistics();

    return successResponse(
      res,
      'Service statistics retrieved successfully',
      statistics,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Update service status (admin only)
 * PUT /api/admin/services/:serviceType
 */
export const updateServiceStatusController = async (req, res, next) => {
  try {
    const { serviceType } = req.params;
    const { enabled } = req.body;

    if (typeof enabled !== 'boolean') {
      const error = new Error('enabled must be a boolean');
      error.statusCode = 400;
      throw error;
    }

    const config = await updateServiceStatus(serviceType, enabled);

    return successResponse(
      res,
      `Service ${enabled ? 'enabled' : 'disabled'} successfully`,
      config,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get admin dashboard statistics
 * GET /api/admin/statistics
 */
export const getAdminStatisticsController = async (req, res, next) => {
  try {
    const statistics = await getAdminStatistics();

    return successResponse(
      res,
      'Statistics retrieved successfully',
      statistics,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get all pending applications (admin only)
 * GET /api/admin/applications/pending
 */
export const getPendingApplicationsController = async (req, res, next) => {
  try {
    const applications = await getPendingApplications();

    return successResponse(
      res,
      'Pending applications retrieved successfully',
      applications,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get applications by status (admin only)
 * GET /api/admin/applications?status=pending|approved|rejected
 */
export const getApplicationsByStatusController = async (req, res, next) => {
  try {
    const { status } = req.query;

    if (!status) {
      const error = new Error('Status query parameter is required');
      error.statusCode = 400;
      throw error;
    }

    const applications = await getApplicationsByStatus(status);

    return successResponse(
      res,
      'Applications retrieved successfully',
      applications,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get application by ID (admin can view any application)
 * GET /api/admin/applications/:id
 */
/**
 * Get application by ID (admin can view any application)
 * GET /api/admin/applications/:id
 */
export const getAdminApplicationController = async (req, res, next) => {
  try {
    const { id } = req.params;

    // Admin can view any application, so we don't check userId
    const application = await Application.findById(id)
      .populate('userId', 'fullName email')
      .populate('reviewedBy', 'fullName email')
      .lean();

    if (!application) {
      const error = new Error('Application not found');
      error.statusCode = 404;
      throw error;
    }

    return successResponse(res, 'Application retrieved successfully', application);
  } catch (error) {
    next(error);
  }
};

/**
 * Approve an application (admin only)
 * POST /api/admin/applications/:id/approve
 */
export const approveApplicationController = async (req, res, next) => {
  try {
    const { id } = req.params;
    const adminId = req.user.id; // From auth middleware

    const application = await approveApplication(id, adminId);

    return successResponse(
      res,
      'Application approved successfully',
      application,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Reject an application (admin only)
 * POST /api/admin/applications/:id/reject
 */
export const rejectApplicationController = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const adminId = req.user.id; // From auth middleware

    if (!reason || reason.trim().length === 0) {
      const error = new Error('Rejection reason is required');
      error.statusCode = 400;
      throw error;
    }

    const application = await rejectApplication(id, adminId, reason.trim());

    return successResponse(
      res,
      'Application rejected successfully',
      application,
    );
  } catch (error) {
    next(error);
  }
};

