import { Router } from 'express';
import {
  getDistrictsController,
  getSectorsController,
  getRegionsController,
} from '../controllers/location.controller.js';

const router = Router();

// Public routes - no authentication required (read-only master data)
router.get('/districts', getDistrictsController);
router.get('/sectors', getSectorsController);
router.get('/regions', getRegionsController);

export default router;


