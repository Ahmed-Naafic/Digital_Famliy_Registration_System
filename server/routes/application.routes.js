import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware.js';
import { uploadDocuments } from '../middlewares/upload.middleware.js';
import {
  createBirthApplicationController,
  createMarriageApplicationController,
  createDivorceApplicationController,
  getMyApplications,
  getApplication,
} from '../controllers/application.controller.js';

const router = Router();

// All application routes require authentication
router.use(authMiddleware);

// Create a Birth application (CRVS) - with file upload support
router.post('/birth', uploadDocuments, createBirthApplicationController);

// Create a Marriage application (CRVS - Islamic Law) - with file upload support
router.post('/marriage', uploadDocuments, createMarriageApplicationController);

// Create a Divorce application (CRVS - Islamic Law) - no file uploads
router.post('/divorce', createDivorceApplicationController);

// Get all applications for the logged-in user
router.get('/my', getMyApplications);

// Get application by ID (must belong to logged-in user)
router.get('/:id', getApplication);

export default router;

