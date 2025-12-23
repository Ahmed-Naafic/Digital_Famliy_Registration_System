import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware.js';
import { uploadDocuments } from '../middlewares/upload.middleware.js';
import {
  createApplication,
  getMyApplications,
  getApplication,
} from '../controllers/application.controller.js';

const router = Router();

// All application routes require authentication
router.use(authMiddleware);

// Submit a new application (with file upload support)
router.post('/', uploadDocuments, createApplication);

// Get all applications for the logged-in user
router.get('/my', getMyApplications);

// Get application by ID (must belong to logged-in user)
router.get('/:id', getApplication);

export default router;

