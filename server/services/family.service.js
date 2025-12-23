import FamilyMember from '../models/FamilyMember.model.js';
import Family from '../models/Family.model.js';
import User from '../models/User.model.js';

/**
 * Get married couples for a user's family
 * Returns couples where both members are married and have spouseId set
 * @param {string} userId - User ID
 * @returns {Promise<Array>} List of married couples
 */
export const getMarriedCouples = async (userId) => {
  // Find user's family by linkedUsers
  const family = await Family.findOne({
    linkedUsers: userId,
    status: 'active',
  });

  if (!family) {
    return [];
  }

  // Find all married members in the family
  const marriedMembers = await FamilyMember.find({
    familyId: family._id,
    maritalStatus: 'married',
    spouseId: { $ne: null },
    status: 'alive', // Only alive members
  }).populate('spouseId', 'firstName lastName gender');

  // Build couples array, avoiding duplicates
  const couplesMap = new Map();
  const processedIds = new Set();

  for (const member of marriedMembers) {
    // Skip if already processed as a spouse
    if (processedIds.has(member._id.toString())) {
      continue;
    }

    const spouseId = member.spouseId;
    if (!spouseId) {
      continue;
    }

    // Ensure spouse is also in the same family and married
    const spouseMember = await FamilyMember.findOne({
      _id: spouseId._id || spouseId,
      familyId: family._id,
      maritalStatus: 'married',
      status: 'alive',
    });

    if (!spouseMember) {
      continue;
    }

    // Determine husband and wife based on gender
    let husband, wife;
    if (member.gender === 'male') {
      husband = member;
      wife = spouseMember;
    } else {
      husband = spouseMember;
      wife = member;
    }

    // Create unique couple key (sorted IDs to avoid duplicates)
    const coupleKey = [
      husband._id.toString(),
      wife._id.toString(),
    ]
      .sort()
      .join('-');

    if (!couplesMap.has(coupleKey)) {
      couplesMap.set(coupleKey, {
        husbandId: husband._id.toString(),
        husbandName: `${husband.firstName} ${husband.lastName}`,
        wifeId: wife._id.toString(),
        wifeName: `${wife.firstName} ${wife.lastName}`,
      });

      // Mark both as processed
      processedIds.add(husband._id.toString());
      processedIds.add(wife._id.toString());
    }
  }

  return Array.from(couplesMap.values());
};

/**
 * Check if a user has an active family
 * @param {string} userId - User ID
 * @returns {Promise<{hasFamily: boolean, familyId?: string}>}
 */
export const checkUserHasFamily = async (userId) => {
  const family = await Family.findOne({
    linkedUsers: userId,
    status: 'active',
  });

  if (!family) {
    return { hasFamily: false };
  }

  return {
    hasFamily: true,
    familyId: family._id.toString(),
  };
};

/**
 * Create a new family for a user
 * CRITICAL: Links family to user and marks as active
 * @param {string} userId - User ID
 * @param {Object} familyData - Family data (familyName, address, etc.)
 * @returns {Promise<Object>} Created family
 */
export const createFamily = async (userId, familyData) => {
  // Check if user already has an active family
  const existingFamily = await Family.findOne({
    linkedUsers: userId,
    status: 'active',
  });

  if (existingFamily) {
    const error = new Error('User already has an active family');
    error.statusCode = 400;
    throw error;
  }

  // Verify user exists
  const user = await User.findById(userId);
  if (!user) {
    const error = new Error('User not found');
    error.statusCode = 404;
    throw error;
  }

  // Validate required fields
  if (!familyData.familyName || familyData.familyName.trim().length === 0) {
    const error = new Error('Family name is required');
    error.statusCode = 400;
    throw error;
  }

  // Create family with user linked
  const newFamily = await Family.create({
    familyName: familyData.familyName.trim(),
    address: familyData.address?.trim(),
    linkedUsers: [userId], // Link to user
    status: 'active', // Mark as active
  });

  return {
    id: newFamily._id.toString(),
    familyName: newFamily.familyName,
    address: newFamily.address,
    status: newFamily.status,
    linkedUsers: newFamily.linkedUsers.map((id) => id.toString()),
    createdAt: newFamily.createdAt,
    updatedAt: newFamily.updatedAt,
  };
};

/**
 * Get all family members for a user's family
 * CRITICAL: Only returns members belonging to the user's family
 * @param {string} userId - User ID
 * @returns {Promise<Array>} List of family members
 */
export const getFamilyMembers = async (userId) => {
  // Find user's family by linkedUsers
  const family = await Family.findOne({
    linkedUsers: userId,
    status: 'active',
  });

  if (!family) {
    return [];
  }

  // CRITICAL: Only return members from this user's family
  const members = await FamilyMember.find({
    familyId: family._id,
  })
    .populate('fatherId', 'firstName lastName')
    .populate('motherId', 'firstName lastName')
    .populate('spouseId', 'firstName lastName')
    .sort({ createdAt: -1 });

  return members.map((member) => ({
    id: member._id.toString(),
    firstName: member.firstName,
    lastName: member.lastName,
    fullName: `${member.firstName} ${member.lastName}`,
    gender: member.gender,
    dateOfBirth: member.dateOfBirth,
    placeOfBirth: member.placeOfBirth,
    nationalIdNumber: member.nationalIdNumber,
    maritalStatus: member.maritalStatus,
    status: member.status,
    fatherId: member.fatherId?._id?.toString(),
    motherId: member.motherId?._id?.toString(),
    spouseId: member.spouseId?._id?.toString(),
    spouseName: member.spouseId
      ? `${member.spouseId.firstName} ${member.spouseId.lastName}`
      : null,
    createdAt: member.createdAt,
    updatedAt: member.updatedAt,
  }));
};

/**
 * Create a new family member for a user's family
 * CRITICAL: Ensures familyId is always set to the user's family
 * @param {string} userId - User ID
 * @param {Object} memberData - Family member data
 * @returns {Promise<Object>} Created family member
 */
export const createFamilyMember = async (userId, memberData) => {
  // Find user's family - REQUIRED
  const family = await Family.findOne({
    linkedUsers: userId,
    status: 'active',
  });

  if (!family) {
    const error = new Error('User does not have an active family');
    error.statusCode = 400;
    throw error;
  }

  // CRITICAL: Always set familyId to user's family
  const memberToCreate = {
    ...memberData,
    familyId: family._id, // Enforce family ownership
    status: memberData.status || 'alive',
  };

  // Validate required fields
  if (!memberToCreate.firstName || !memberToCreate.lastName) {
    const error = new Error('First name and last name are required');
    error.statusCode = 400;
    throw error;
  }

  // If fatherId or motherId are provided, verify they belong to the same family
  if (memberToCreate.fatherId) {
    const father = await FamilyMember.findOne({
      _id: memberToCreate.fatherId,
      familyId: family._id,
    });
    if (!father) {
      const error = new Error('Father must belong to the same family');
      error.statusCode = 400;
      throw error;
    }
  }

  if (memberToCreate.motherId) {
    const mother = await FamilyMember.findOne({
      _id: memberToCreate.motherId,
      familyId: family._id,
    });
    if (!mother) {
      const error = new Error('Mother must belong to the same family');
      error.statusCode = 400;
      throw error;
    }
  }

  // Create the family member
  const newMember = await FamilyMember.create(memberToCreate);

  // Populate relationships for response
  await newMember.populate('fatherId', 'firstName lastName');
  await newMember.populate('motherId', 'firstName lastName');
  await newMember.populate('spouseId', 'firstName lastName');

  return {
    id: newMember._id.toString(),
    firstName: newMember.firstName,
    lastName: newMember.lastName,
    fullName: `${newMember.firstName} ${newMember.lastName}`,
    gender: newMember.gender,
    dateOfBirth: newMember.dateOfBirth,
    placeOfBirth: newMember.placeOfBirth,
    nationalIdNumber: newMember.nationalIdNumber,
    maritalStatus: newMember.maritalStatus,
    status: newMember.status,
    fatherId: newMember.fatherId?._id?.toString(),
    motherId: newMember.motherId?._id?.toString(),
    spouseId: newMember.spouseId?._id?.toString(),
    createdAt: newMember.createdAt,
    updatedAt: newMember.updatedAt,
  };
};

