import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware.js';
import {
  getMyCertificates,
  getCertificateDownload,
} from '../controllers/certificate.controller.js';

const router = Router();

// All certificate routes require authentication
router.use(authMiddleware);

// Get all certificates for the logged-in citizen
router.get('/my', getMyCertificates);

// Get certificate download URL
router.get('/:id/download', getCertificateDownload);

export default router;


