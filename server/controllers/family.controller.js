import { successResponse } from '../utils/response.util.js';
import {
  getMarriedCouples,
  checkUserHasFamily,
  getFamilyMembers,
  createFamilyMember,
  createFamily,
} from '../services/family.service.js';

/**
 * Get married couples for the logged-in user's family
 * GET /api/family/married-couples
 */
export const getMarriedCouplesController = async (req, res, next) => {
  try {
    const userId = req.user.id; // From auth middleware

    const couples = await getMarriedCouples(userId);

    return successResponse(
      res,
      'Married couples retrieved successfully',
      couples,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Check if the logged-in user has a family
 * GET /api/family/check
 */
export const checkFamilyController = async (req, res, next) => {
  try {
    const userId = req.user.id; // From auth middleware

    const result = await checkUserHasFamily(userId);

    return successResponse(
      res,
      'Family check completed',
      result,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get all family members for the logged-in user's family
 * GET /api/family/members
 * CRITICAL: Only returns members from the user's own family
 */
export const getFamilyMembersController = async (req, res, next) => {
  try {
    const userId = req.user.id; // From auth middleware

    const members = await getFamilyMembers(userId);

    return successResponse(
      res,
      'Family members retrieved successfully',
      members,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Create a new family member for the logged-in user's family
 * POST /api/family/members
 * CRITICAL: Ensures member is created in the user's family only
 */
export const createFamilyMemberController = async (req, res, next) => {
  try {
    const userId = req.user.id; // From auth middleware
    const memberData = req.body;

    const newMember = await createFamilyMember(userId, memberData);

    return successResponse(
      res,
      'Family member created successfully',
      newMember,
      201,
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Create a new family for the logged-in user
 * POST /api/family/create
 * CRITICAL: Creates family and links it to the user
 */
export const createFamilyController = async (req, res, next) => {
  try {
    const userId = req.user.id; // From auth middleware
    const familyData = req.body;

    const newFamily = await createFamily(userId, familyData);

    return successResponse(
      res,
      'Family created successfully',
      newFamily,
      201,
    );
  } catch (error) {
    next(error);
  }
};

