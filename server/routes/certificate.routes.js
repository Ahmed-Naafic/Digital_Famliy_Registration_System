import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware.js';
import {
  getMyCertificates,
  getCertificateDownload,
  generateBirthCertificateController,
  getCertificateByApplicationController,
} from '../controllers/certificate.controller.js';

const router = Router();

// All certificate routes require authentication
router.use(authMiddleware);

// Get all certificates for the logged-in citizen
router.get('/my', getMyCertificates);

// Get certificate by application ID
router.get('/by-application/:applicationId', getCertificateByApplicationController);

// Generate Birth Certificate from approved application
router.post('/birth', generateBirthCertificateController);

// Get certificate download URL
router.get('/:id/download', getCertificateDownload);

export default router;


