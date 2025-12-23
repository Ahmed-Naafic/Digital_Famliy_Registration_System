import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware.js';
import {
  getMarriedCouplesController,
  checkFamilyController,
  getFamilyMembersController,
  createFamilyMemberController,
  createFamilyController,
} from '../controllers/family.controller.js';

const router = Router();

// All family routes require authentication
router.use(authMiddleware);

// Create a new family for the logged-in user
router.post('/create', createFamilyController);

// Check if user has a family
router.get('/check', checkFamilyController);

// Get married couples for the logged-in user's family
router.get('/married-couples', getMarriedCouplesController);

// Get all family members for the logged-in user's family
router.get('/members', getFamilyMembersController);

// Create a new family member for the logged-in user's family
router.post('/members', createFamilyMemberController);

export default router;

