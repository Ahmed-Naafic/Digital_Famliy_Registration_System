import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware.js';
import { adminMiddleware } from '../middlewares/admin.middleware.js';
import {
  getAdminStatisticsController,
  getServiceStatisticsController,
  updateServiceStatusController,
  getAllCitizensController,
  getAllFamiliesController,
  getFamilyMembersController,
  getAllCertificatesController,
  getPendingApplicationsController,
  getApplicationsByStatusController,
  getAdminApplicationController,
  approveApplicationController,
  rejectApplicationController,
} from '../controllers/admin.controller.js';

const router = Router();

// All admin routes require authentication and admin role
router.use(authMiddleware);
router.use(adminMiddleware);

// Get admin dashboard statistics
router.get('/statistics', getAdminStatisticsController);

// Get service-specific statistics
router.get('/services/statistics', getServiceStatisticsController);

// Update service status
router.put('/services/:serviceType', updateServiceStatusController);

// Get all citizens
router.get('/citizens', getAllCitizensController);

// Get all families
router.get('/families', getAllFamiliesController);

// Get family members by family ID
router.get('/families/:familyId/members', getFamilyMembersController);

// Get all certificates
router.get('/certificates', getAllCertificatesController);

// Get all pending applications
router.get('/applications/pending', getPendingApplicationsController);

// Get applications by status (pending, approved, rejected)
router.get('/applications', getApplicationsByStatusController);

// Get application by ID (admin can view any)
router.get('/applications/:id', getAdminApplicationController);

// Approve an application
router.post('/applications/:id/approve', approveApplicationController);

// Reject an application
router.post('/applications/:id/reject', rejectApplicationController);

export default router;


