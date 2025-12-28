import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware.js';
import { getPersonByIdentity } from '../controllers/identity.controller.js';

const router = Router();

// All identity routes require authentication
router.use(authMiddleware);

// Get person identity from NIRA by National ID
router.get('/nira/:nationalId', getPersonByIdentity);

export default router;

