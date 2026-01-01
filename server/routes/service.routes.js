import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware.js';
import { getEnabledServicesController } from '../controllers/service.controller.js';

const router = Router();

// Get enabled services (requires authentication)
router.get('/enabled', authMiddleware, getEnabledServicesController);

export default router;



