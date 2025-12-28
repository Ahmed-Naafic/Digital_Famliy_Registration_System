import { Router } from 'express';
import { getCitizenByNationalId } from '../controllers/citizen.controller.js';

const router = Router();

// Get citizen by National ID
router.get('/:nationalId', getCitizenByNationalId);

export default router;

