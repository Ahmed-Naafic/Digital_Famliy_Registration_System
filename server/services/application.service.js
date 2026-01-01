import Application from '../models/Application.model.js';
import { fetchPersonByNationalId } from './nira.service.js';

/**
 * Create a Birth application (CRVS)
 * Applicant, father, and mother are verified via NIRA using National IDs
 * @param {Object} params - Application data
 * @param {string} params.userId - User ID from token
 * @param {string} params.applicantNationalId - Applicant's National ID
 * @param {Object} params.child - Child information
 * @param {string} params.fatherNationalId - Father's National ID
 * @param {string} params.motherNationalId - Mother's National ID
 * @param {Object} params.fatherResidence - Father's administrative location
 * @param {string} params.fatherResidence.district - Father's district
 * @param {string} params.fatherResidence.sector - Father's sector
 * @param {Object} params.motherResidence - Mother's administrative location
 * @param {string} params.motherResidence.district - Mother's district
 * @param {string} params.motherResidence.sector - Mother's sector
 * @param {Array} params.documents - Document metadata array
 * @returns {Promise<Object>} Created application
 */
export const createBirthApplication = async ({
  userId,
  applicantNationalId,
  child,
  fatherNationalId,
  motherNationalId,
  fatherResidence,
  motherResidence,
  documents = [],
}) => {
  // Validate required fields
  if (!applicantNationalId || typeof applicantNationalId !== 'string' || applicantNationalId.trim().length === 0) {
    const error = new Error('Applicant National ID is required');
    error.statusCode = 400;
    throw error;
  }

  if (!child || typeof child !== 'object') {
    const error = new Error('Child information is required');
    error.statusCode = 400;
    throw error;
  }

  if (!fatherNationalId || typeof fatherNationalId !== 'string' || fatherNationalId.trim().length === 0) {
    const error = new Error('Father National ID is required');
    error.statusCode = 400;
    throw error;
  }

  if (!motherNationalId || typeof motherNationalId !== 'string' || motherNationalId.trim().length === 0) {
    const error = new Error('Mother National ID is required');
    error.statusCode = 400;
    throw error;
  }

  // Validate parent residence
  if (!fatherResidence || typeof fatherResidence !== 'object') {
    const error = new Error('Father residence (district, sector) is required');
    error.statusCode = 400;
    throw error;
  }

  if (!fatherResidence.district || typeof fatherResidence.district !== 'string' || fatherResidence.district.trim().length === 0) {
    const error = new Error('Father district is required');
    error.statusCode = 400;
    throw error;
  }

  if (!fatherResidence.sector || typeof fatherResidence.sector !== 'string' || fatherResidence.sector.trim().length === 0) {
    const error = new Error('Father sector is required');
    error.statusCode = 400;
    throw error;
  }

  if (!motherResidence || typeof motherResidence !== 'object') {
    const error = new Error('Mother residence (district, sector) is required');
    error.statusCode = 400;
    throw error;
  }

  if (!motherResidence.district || typeof motherResidence.district !== 'string' || motherResidence.district.trim().length === 0) {
    const error = new Error('Mother district is required');
    error.statusCode = 400;
    throw error;
  }

  if (!motherResidence.sector || typeof motherResidence.sector !== 'string' || motherResidence.sector.trim().length === 0) {
    const error = new Error('Mother sector is required');
    error.statusCode = 400;
    throw error;
  }

  // Validate documents array
  if (documents && documents.length > 0) {
    for (const doc of documents) {
      if (!doc.fileName || !doc.filePath) {
        const error = new Error('Invalid document metadata. fileName and filePath are required');
        error.statusCode = 400;
        throw error;
      }
    }
  }

  // Verify applicant via NIRA
  let applicantSnapshot;
  try {
    const applicantData = await fetchPersonByNationalId(applicantNationalId.trim());
    applicantSnapshot = {
      nationalId: applicantData.nationalId,
      fullName: applicantData.fullName,
      dateOfBirth: applicantData.dateOfBirth,
      gender: applicantData.gender,
    };
  } catch (error) {
    const niraError = new Error(`Failed to verify applicant: ${error.message}`);
    niraError.statusCode = error.statusCode || 400;
    throw niraError;
  }

  // Verify father via NIRA
  let fatherSnapshot;
  try {
    const fatherData = await fetchPersonByNationalId(fatherNationalId.trim());
    fatherSnapshot = {
      nationalId: fatherData.nationalId,
      fullName: fatherData.fullName,
      dateOfBirth: fatherData.dateOfBirth,
      gender: fatherData.gender,
      status: fatherData.status,
    };
  } catch (error) {
    const niraError = new Error(`Failed to verify father: ${error.message}`);
    niraError.statusCode = error.statusCode || 400;
    throw niraError;
  }

  // Verify mother via NIRA
  let motherSnapshot;
  try {
    const motherData = await fetchPersonByNationalId(motherNationalId.trim());
    motherSnapshot = {
      nationalId: motherData.nationalId,
      fullName: motherData.fullName,
      dateOfBirth: motherData.dateOfBirth,
      gender: motherData.gender,
      status: motherData.status,
    };
  } catch (error) {
    const niraError = new Error(`Failed to verify mother: ${error.message}`);
    niraError.statusCode = error.statusCode || 400;
    throw niraError;
  }

  // Create application payload with Birth structure
  const payload = {
    birth: {
      applicant: {
        nationalId: applicantNationalId.trim(),
        snapshot: applicantSnapshot,
      },
      child: {
        name: child.name || '',
        dateOfBirth: child.dateOfBirth || null,
        placeOfBirth: child.placeOfBirth || '',
        gender: child.gender || null,
        nationality: child.nationality || '',
      },
      fatherNationalId: fatherNationalId.trim(),
      motherNationalId: motherNationalId.trim(),
      fatherSnapshot: fatherSnapshot,
      motherSnapshot: motherSnapshot,
      fatherResidence: {
        district: fatherResidence.district.trim(),
        sector: fatherResidence.sector.trim(),
      },
      motherResidence: {
        district: motherResidence.district.trim(),
        sector: motherResidence.sector.trim(),
      },
    },
  };

  // Create application with status 'pending'
  const application = await Application.create({
    userId,
    applicationType: 'BIRTH',
    type: 'birth',
    payload,
    documents: documents && documents.length > 0 ? documents : [],
    status: 'pending',
  });

  // Populate userId to return user info
  await application.populate('userId', 'fullName email');

  return application;
};

/**
 * Create a Marriage application (CRVS - Islamic Law)
 * All parties verified via NIRA using National IDs
 * Enforces Islamic marriage rules:
 * - Groom limited to 4 wives
 * - Bride strictly monogamous
 * - Wali must be male
 * - Two male witnesses required
 * - Sheikh must be male
 * @param {Object} params - Application data
 * @param {string} params.userId - User ID from token
 * @param {string} params.applicantNationalId - Applicant's National ID
 * @param {string} params.groomNationalId - Groom's National ID
 * @param {string} params.brideNationalId - Bride's National ID
 * @param {Object} params.wali - Wali information
 * @param {string} params.wali.nationalId - Wali's National ID
 * @param {string} params.wali.relationship - Relationship to bride (father, brother, etc.)
 * @param {Array} params.witnesses - Array of 2 witness objects
 * @param {string} params.witnesses[].nationalId - Witness National ID
 * @param {Object} params.sheikh - Sheikh information
 * @param {string} params.sheikh.nationalId - Sheikh's National ID
 * @param {Object} params.meher - Meher information
 * @param {string} params.meher.type - "CASH" or "ASSET"
 * @param {number} params.meher.value - Meher value
 * @param {string} params.meher.currency - Currency (if CASH)
 * @param {boolean} params.meher.deferred - Whether meher is deferred
 * @param {Object} params.marriageDetails - Marriage details
 * @param {string} params.marriageDetails.date - Marriage date
 * @param {string} params.marriageDetails.district - District
 * @param {string} params.marriageDetails.sector - Sector
 * @param {string} params.marriageDetails.place - Place of marriage
 * @param {Array} params.documents - Document metadata array
 * @returns {Promise<Object>} Created application
 */
export const createMarriageApplication = async ({
  userId,
  applicantNationalId,
  groomNationalId,
  brideNationalId,
  wali,
  witnesses,
  sheikh,
  meher,
  marriageDetails,
  documents = [],
}) => {
  // Validate required fields
  if (!applicantNationalId || typeof applicantNationalId !== 'string' || applicantNationalId.trim().length === 0) {
    const error = new Error('Applicant National ID is required');
    error.statusCode = 400;
    throw error;
  }

  if (!groomNationalId || typeof groomNationalId !== 'string' || groomNationalId.trim().length === 0) {
    const error = new Error('Groom National ID is required');
    error.statusCode = 400;
    throw error;
  }

  if (!brideNationalId || typeof brideNationalId !== 'string' || brideNationalId.trim().length === 0) {
    const error = new Error('Bride National ID is required');
    error.statusCode = 400;
    throw error;
  }

  if (!wali || typeof wali !== 'object' || !wali.nationalId || !wali.relationship) {
    const error = new Error('Wali information (nationalId, relationship) is required');
    error.statusCode = 400;
    throw error;
  }

  if (!Array.isArray(witnesses) || witnesses.length !== 2) {
    const error = new Error('Exactly two witnesses are required');
    error.statusCode = 400;
    throw error;
  }

  if (!witnesses[0]?.nationalId || !witnesses[1]?.nationalId) {
    const error = new Error('Both witnesses must have National IDs');
    error.statusCode = 400;
    throw error;
  }

  if (!sheikh || typeof sheikh !== 'object' || !sheikh.nationalId) {
    const error = new Error('Sheikh information (nationalId) is required');
    error.statusCode = 400;
    throw error;
  }

  if (!meher || typeof meher !== 'object' || !meher.type || !meher.value) {
    const error = new Error('Meher information (type, value) is required');
    error.statusCode = 400;
    throw error;
  }

  if (!['CASH', 'ASSET'].includes(meher.type)) {
    const error = new Error('Meher type must be CASH or ASSET');
    error.statusCode = 400;
    throw error;
  }

  if (meher.type === 'CASH' && !meher.currency) {
    const error = new Error('Currency is required for CASH meher');
    error.statusCode = 400;
    throw error;
  }

  if (!marriageDetails || typeof marriageDetails !== 'object') {
    const error = new Error('Marriage details are required');
    error.statusCode = 400;
    throw error;
  }

  if (!marriageDetails.date || !marriageDetails.district || !marriageDetails.sector) {
    const error = new Error('Marriage details (date, district, sector) are required');
    error.statusCode = 400;
    throw error;
  }

  // Validate documents array
  if (documents && documents.length > 0) {
    for (const doc of documents) {
      if (!doc.fileName || !doc.filePath) {
        const error = new Error('Invalid document metadata. fileName and filePath are required');
        error.statusCode = 400;
        throw error;
      }
    }
  }

  // Verify applicant via NIRA
  let applicantSnapshot;
  try {
    const applicantData = await fetchPersonByNationalId(applicantNationalId.trim());
    applicantSnapshot = {
      nationalId: applicantData.nationalId,
      fullName: applicantData.fullName,
      dateOfBirth: applicantData.dateOfBirth,
      gender: applicantData.gender,
    };
  } catch (error) {
    const niraError = new Error(`Failed to verify applicant: ${error.message}`);
    niraError.statusCode = error.statusCode || 400;
    throw niraError;
  }

  // Verify groom via NIRA
  let groomSnapshot;
  try {
    const groomData = await fetchPersonByNationalId(groomNationalId.trim());
    groomSnapshot = {
      nationalId: groomData.nationalId,
      fullName: groomData.fullName,
      dateOfBirth: groomData.dateOfBirth,
      gender: groomData.gender,
      status: groomData.status,
    };
  } catch (error) {
    const niraError = new Error(`Failed to verify groom: ${error.message}`);
    niraError.statusCode = error.statusCode || 400;
    throw niraError;
  }

  // Validate groom gender (must be MALE)
  const groomGender = (groomSnapshot.gender || '').toUpperCase();
  if (groomGender !== 'MALE') {
    const error = new Error('Groom must be male according to Islamic law');
    error.statusCode = 400;
    throw error;
  }

  // Check groom's existing approved marriages (limit to 4)
  // Exclude divorced marriages
  const groomApprovedMarriages = await Application.countDocuments({
    type: 'marriage',
    status: 'approved',
    'payload.marriage.groom.nationalId': groomNationalId.trim(),
    $or: [
      { 'payload.marriage.isDivorced': { $ne: true } },
      { 'payload.marriage.isDivorced': { $exists: false } },
    ],
  });

  if (groomApprovedMarriages >= 4) {
    const error = new Error('Groom already has four wives. Islamic law does not permit more.');
    error.statusCode = 400;
    throw error;
  }

  // Verify bride via NIRA
  let brideSnapshot;
  try {
    const brideData = await fetchPersonByNationalId(brideNationalId.trim());
    brideSnapshot = {
      nationalId: brideData.nationalId,
      fullName: brideData.fullName,
      dateOfBirth: brideData.dateOfBirth,
      gender: brideData.gender,
      status: brideData.status,
    };
  } catch (error) {
    const niraError = new Error(`Failed to verify bride: ${error.message}`);
    niraError.statusCode = error.statusCode || 400;
    throw niraError;
  }

  // Validate bride gender (must be FEMALE)
  const brideGender = (brideSnapshot.gender || '').toUpperCase();
  if (brideGender !== 'FEMALE') {
    const error = new Error('Bride must be female according to Islamic law');
    error.statusCode = 400;
    throw error;
  }

  // Check if bride is already in an approved marriage (strictly monogamous)
  // Exclude divorced marriages
  const brideExistingMarriage = await Application.findOne({
    type: 'marriage',
    status: 'approved',
    $and: [
      {
        $or: [
          { 'payload.marriage.bride.nationalId': brideNationalId.trim() },
          { 'payload.marriage.groom.nationalId': brideNationalId.trim() }, // In case of data inconsistency
        ],
      },
      {
        $or: [
          { 'payload.marriage.isDivorced': { $ne: true } },
          { 'payload.marriage.isDivorced': { $exists: false } },
        ],
      },
    ],
  }).lean();

  if (brideExistingMarriage) {
    const error = new Error('Bride is already married and cannot enter another marriage.');
    error.statusCode = 400;
    throw error;
  }

  // Verify wali via NIRA
  let waliSnapshot;
  try {
    const waliData = await fetchPersonByNationalId(wali.nationalId.trim());
    waliSnapshot = {
      nationalId: waliData.nationalId,
      fullName: waliData.fullName,
      dateOfBirth: waliData.dateOfBirth,
      gender: waliData.gender,
      status: waliData.status,
    };
  } catch (error) {
    const niraError = new Error(`Failed to verify wali: ${error.message}`);
    niraError.statusCode = error.statusCode || 400;
    throw niraError;
  }

  // Validate wali gender (must be MALE)
  const waliGender = (waliSnapshot.gender || '').toUpperCase();
  if (waliGender !== 'MALE') {
    const error = new Error('Wali must be male according to Islamic law.');
    error.statusCode = 400;
    throw error;
  }

  // Validate wali relationship (allowed relationships)
  const allowedRelationships = ['father', 'brother', 'uncle', 'grandfather', 'son'];
  const waliRelationship = (wali.relationship || '').toLowerCase();
  if (!allowedRelationships.includes(waliRelationship)) {
    const error = new Error(`Invalid wali relationship. Allowed: ${allowedRelationships.join(', ')}`);
    error.statusCode = 400;
    throw error;
  }

  // Verify witnesses via NIRA
  const witnessSnapshots = [];
  const witnessNationalIds = new Set();
  
  for (let i = 0; i < witnesses.length; i++) {
    const witness = witnesses[i];
    try {
      const witnessData = await fetchPersonByNationalId(witness.nationalId.trim());
      const witnessSnapshot = {
        nationalId: witnessData.nationalId,
        fullName: witnessData.fullName,
        dateOfBirth: witnessData.dateOfBirth,
        gender: witnessData.gender,
        status: witnessData.status,
      };
      witnessSnapshots.push(witnessSnapshot);
      witnessNationalIds.add(witnessData.nationalId);
    } catch (error) {
      const niraError = new Error(`Failed to verify witness ${i + 1}: ${error.message}`);
      niraError.statusCode = error.statusCode || 400;
      throw niraError;
    }
  }

  // Validate witnesses are all MALE
  for (let i = 0; i < witnessSnapshots.length; i++) {
    const witnessGender = (witnessSnapshots[i].gender || '').toUpperCase();
    if (witnessGender !== 'MALE') {
      const error = new Error('Marriage witnesses must be male.');
      error.statusCode = 400;
      throw error;
    }
  }

  // Validate witnesses are not groom, bride, wali, or sheikh
  const prohibitedIds = new Set([
    groomNationalId.trim(),
    brideNationalId.trim(),
    wali.nationalId.trim(),
    sheikh.nationalId.trim(),
  ]);

  for (const witnessId of witnessNationalIds) {
    if (prohibitedIds.has(witnessId)) {
      const error = new Error('Witnesses cannot be the groom, bride, wali, or sheikh');
      error.statusCode = 400;
      throw error;
    }
  }

  // Verify sheikh via NIRA
  let sheikhSnapshot;
  try {
    const sheikhData = await fetchPersonByNationalId(sheikh.nationalId.trim());
    sheikhSnapshot = {
      nationalId: sheikhData.nationalId,
      fullName: sheikhData.fullName,
      dateOfBirth: sheikhData.dateOfBirth,
      gender: sheikhData.gender,
      status: sheikhData.status,
    };
  } catch (error) {
    const niraError = new Error(`Failed to verify sheikh: ${error.message}`);
    niraError.statusCode = error.statusCode || 400;
    throw niraError;
  }

  // Validate sheikh gender (must be MALE)
  const sheikhGender = (sheikhSnapshot.gender || '').toUpperCase();
  if (sheikhGender !== 'MALE') {
    const error = new Error('Sheikh must be male according to Islamic law');
    error.statusCode = 400;
    throw error;
  }

  // Create application payload with Marriage structure
  const payload = {
    marriage: {
      applicant: {
        nationalId: applicantNationalId.trim(),
        snapshot: applicantSnapshot,
      },
      groom: {
        nationalId: groomNationalId.trim(),
        snapshot: groomSnapshot,
      },
      bride: {
        nationalId: brideNationalId.trim(),
        snapshot: brideSnapshot,
      },
      wali: {
        nationalId: wali.nationalId.trim(),
        relationship: wali.relationship.trim(),
        snapshot: waliSnapshot,
      },
      witnesses: witnessSnapshots.map((snapshot) => ({
        nationalId: snapshot.nationalId,
        snapshot: snapshot,
      })),
      sheikh: {
        nationalId: sheikh.nationalId.trim(),
        snapshot: sheikhSnapshot,
      },
      meher: {
        type: meher.type,
        value: meher.value,
        currency: meher.currency || null,
        deferred: meher.deferred || false,
      },
      marriageDetails: {
        date: marriageDetails.date,
        district: marriageDetails.district.trim(),
        sector: marriageDetails.sector.trim(),
        place: marriageDetails.place || '',
      },
    },
  };

  // Create application with status 'pending'
  const application = await Application.create({
    userId,
    applicationType: 'MARRIAGE',
    type: 'marriage',
    payload,
    documents: documents && documents.length > 0 ? documents : [],
    status: 'pending',
  });

  // Populate userId to return user info
  await application.populate('userId', 'fullName email');

  return application;
};

/**
 * Create a Divorce application (CRVS - Islamic Law)
 * Supports TALAQ (husband initiated) and KHUL (wife initiated)
 * @param {Object} params - Application data
 * @param {string} params.userId - User ID from token
 * @param {string} params.marriageApplicationId - Marriage application ID to divorce
 * @param {string} params.divorceType - "TALAQ" or "KHUL"
 * @param {string} params.applicantNationalId - Applicant's National ID
 * @param {Object} params.meherSettlement - Meher settlement details (required for KHUL)
 * @param {boolean} params.meherSettlement.required - Whether meher settlement is required
 * @param {number} params.meherSettlement.amountReturned - Amount returned (for KHUL)
 * @param {string} params.meherSettlement.currency - Currency (for KHUL)
 * @param {string} params.reason - Divorce reason (optional)
 * @param {Object} params.divorceDetails - Divorce details
 * @param {string} params.divorceDetails.date - Divorce date
 * @param {string} params.divorceDetails.district - District
 * @param {string} params.divorceDetails.sector - Sector
 * @param {Array} params.documents - Document metadata array
 * @returns {Promise<Object>} Created application
 */
export const createDivorceApplication = async ({
  userId,
  userNationalId, // From req.user.nationalId
  marriageApplicationId,
  divorceType,
  witnesses,
  meherStatus,
  reason,
  divorceDetails,
}) => {
  // Validate required fields
  if (!userNationalId || typeof userNationalId !== 'string' || userNationalId.trim().length === 0) {
    const error = new Error('User National ID is required');
    error.statusCode = 400;
    throw error;
  }

  if (!marriageApplicationId || typeof marriageApplicationId !== 'string' || marriageApplicationId.trim().length === 0) {
    const error = new Error('Marriage application ID is required');
    error.statusCode = 400;
    throw error;
  }

  if (!divorceType || typeof divorceType !== 'string') {
    const error = new Error('Divorce type is required');
    error.statusCode = 400;
    throw error;
  }

  const normalizedDivorceType = divorceType.toUpperCase();
  if (!['TALAQ', 'KHUL'].includes(normalizedDivorceType)) {
    const error = new Error('Invalid divorce type. Must be TALAQ or KHUL');
    error.statusCode = 400;
    throw error;
  }

  if (!witnesses || !Array.isArray(witnesses) || witnesses.length !== 2) {
    const error = new Error('Exactly two witnesses are required');
    error.statusCode = 400;
    throw error;
  }

  if (!meherStatus || typeof meherStatus !== 'object') {
    const error = new Error('Meher status is required');
    error.statusCode = 400;
    throw error;
  }

  if (typeof meherStatus.wasGiven !== 'boolean') {
    const error = new Error('Meher status wasGiven must be provided (true or false)');
    error.statusCode = 400;
    throw error;
  }

  if (meherStatus.wasGiven === true) {
    if (meherStatus.amount === undefined || meherStatus.amount === null) {
      const error = new Error('Meher amount is required when wasGiven is true');
      error.statusCode = 400;
      throw error;
    }

    if (typeof meherStatus.amount !== 'number' || meherStatus.amount < 0) {
      const error = new Error('Meher amount must be a non-negative number');
      error.statusCode = 400;
      throw error;
    }

    if (!meherStatus.currency || typeof meherStatus.currency !== 'string' || meherStatus.currency.trim().length === 0) {
      const error = new Error('Meher currency is required when wasGiven is true');
      error.statusCode = 400;
      throw error;
    }
  }

  if (normalizedDivorceType === 'KHUL' && meherStatus.wasGiven !== true) {
    const error = new Error('Meher must be returned for Khul divorce.');
    error.statusCode = 400;
    throw error;
  }

  if (!divorceDetails || typeof divorceDetails !== 'object') {
    const error = new Error('Divorce details are required');
    error.statusCode = 400;
    throw error;
  }

  if (!divorceDetails.date || !divorceDetails.district || !divorceDetails.sector) {
    const error = new Error('Divorce details (date, district, sector) are required');
    error.statusCode = 400;
    throw error;
  }

  // STEP 1: Fetch marriage by marriageApplicationId
  const marriage = await Application.findById(marriageApplicationId).lean();

  if (!marriage) {
    const error = new Error('Marriage not found');
    error.statusCode = 404;
    throw error;
  }

  // STEP 2: Marriage MUST exist and be APPROVED
  if (marriage.status !== 'approved') {
    const error = new Error('Divorce is only allowed for approved marriages.');
    error.statusCode = 400;
    throw error;
  }

  if (marriage.type !== 'marriage' || !marriage.payload?.marriage) {
    const error = new Error('Invalid marriage application');
    error.statusCode = 400;
    throw error;
  }

  // STEP 3: Marriage MUST NOT already be divorced
  const existingDivorce = await Application.findOne({
    type: 'divorce',
    status: 'approved',
    'payload.divorce.marriageApplicationId': marriageApplicationId,
  }).lean();

  if (existingDivorce) {
    const error = new Error('This marriage is already divorced.');
    error.statusCode = 400;
    throw error;
  }

  const marriagePayload = marriage.payload.marriage;
  const husbandNationalId = marriagePayload.groom?.nationalId;
  const wifeNationalId = marriagePayload.bride?.nationalId;

  if (!husbandNationalId || !wifeNationalId) {
    const error = new Error('Invalid marriage data: husband or wife National ID missing');
    error.statusCode = 400;
    throw error;
  }

  // STEP 2: Verify logged-in user MUST equal marriage.groom.nationalId
  if (userNationalId.trim() !== husbandNationalId.trim()) {
    const error = new Error('Only the husband can initiate divorce.');
    error.statusCode = 403;
    throw error;
  }

  // Verify husband (logged-in user) via NIRA
  let husbandSnapshot;
  try {
    const husbandData = await fetchPersonByNationalId(userNationalId.trim());
    husbandSnapshot = {
      nationalId: husbandData.nationalId,
      fullName: husbandData.fullName,
      dateOfBirth: husbandData.dateOfBirth,
      gender: husbandData.gender,
    };
  } catch (error) {
    const niraError = new Error(`Failed to verify husband: ${error.message}`);
    niraError.statusCode = error.statusCode || 400;
    throw niraError;
  }

  // Validate husband gender (must be MALE)
  const husbandGender = (husbandSnapshot.gender || '').toUpperCase();
  if (husbandGender !== 'MALE') {
    const error = new Error('Husband must be male');
    error.statusCode = 400;
    throw error;
  }

  // Verify wife via NIRA
  let wifeSnapshot;
  try {
    const wifeData = await fetchPersonByNationalId(wifeNationalId.trim());
    wifeSnapshot = {
      nationalId: wifeData.nationalId,
      fullName: wifeData.fullName,
      dateOfBirth: wifeData.dateOfBirth,
      gender: wifeData.gender,
    };
  } catch (error) {
    const niraError = new Error(`Failed to verify wife: ${error.message}`);
    niraError.statusCode = error.statusCode || 400;
    throw niraError;
  }

  // Validate wife gender (must be FEMALE)
  const wifeGender = (wifeSnapshot.gender || '').toUpperCase();
  if (wifeGender !== 'FEMALE') {
    const error = new Error('Wife must be female');
    error.statusCode = 400;
    throw error;
  }

  // STEP 4: Verify witnesses (exactly 2, both MALE, not husband or wife)
  const witnessSnapshots = [];
  const witnessNationalIds = new Set();
  const prohibitedIds = new Set([
    userNationalId.trim(), // husband
    wifeNationalId.trim(), // wife
  ]);

  for (let i = 0; i < witnesses.length; i++) {
    const witness = witnesses[i];
    if (!witness.nationalId || typeof witness.nationalId !== 'string' || witness.nationalId.trim().length === 0) {
      const error = new Error(`Witness ${i + 1} National ID is required`);
      error.statusCode = 400;
      throw error;
    }

    const witnessId = witness.nationalId.trim();

    // Check for duplicates
    if (witnessNationalIds.has(witnessId)) {
      const error = new Error('Witnesses must have different National IDs');
      error.statusCode = 400;
      throw error;
    }

    // Check witnesses are not husband or wife
    if (prohibitedIds.has(witnessId)) {
      const error = new Error('Witnesses cannot be the husband or wife');
      error.statusCode = 400;
      throw error;
    }

    // Use snapshot from frontend if provided, otherwise fetch from NIRA
    let witnessSnapshot;
    if (witness.snapshot && typeof witness.snapshot === 'object') {
      // Use snapshot from frontend
      witnessSnapshot = {
        nationalId: witness.snapshot.nationalId || witnessId,
        fullName: witness.snapshot.fullName || '',
        dateOfBirth: witness.snapshot.dateOfBirth || null,
        gender: witness.snapshot.gender || null,
        status: witness.snapshot.status || null,
      };
    } else {
      // Fetch from NIRA if snapshot not provided
      try {
        const witnessData = await fetchPersonByNationalId(witnessId);
        witnessSnapshot = {
          nationalId: witnessData.nationalId,
          fullName: witnessData.fullName,
          dateOfBirth: witnessData.dateOfBirth,
          gender: witnessData.gender,
          status: witnessData.status,
        };
      } catch (error) {
        const niraError = new Error(`Failed to verify witness ${i + 1}: ${error.message}`);
        niraError.statusCode = error.statusCode || 400;
        throw niraError;
      }
    }

    // Validate witness gender (must be MALE)
    const witnessGender = (witnessSnapshot.gender || '').toUpperCase();
    if (witnessGender !== 'MALE') {
      const error = new Error('Divorce requires two male witnesses.');
      error.statusCode = 400;
      throw error;
    }

    witnessSnapshots.push(witnessSnapshot);
    witnessNationalIds.add(witnessId);
  }

  // Create application payload with Divorce structure
  const payload = {
    divorce: {
      marriageApplicationId: marriageApplicationId.trim(),
      divorceType: normalizedDivorceType,
      applicant: {
        nationalId: userNationalId.trim(),
        snapshot: husbandSnapshot,
      },
      husband: {
        nationalId: husbandNationalId.trim(),
        snapshot: husbandSnapshot,
      },
      wife: {
        nationalId: wifeNationalId.trim(),
        snapshot: wifeSnapshot,
      },
      witnesses: witnessSnapshots.map((snapshot) => ({
        nationalId: snapshot.nationalId,
        snapshot: snapshot,
      })),
      meherStatus: {
        wasGiven: meherStatus.wasGiven,
        amount: meherStatus.wasGiven ? meherStatus.amount : null,
        currency: meherStatus.wasGiven ? meherStatus.currency.trim() : null,
      },
      reason: reason || null,
      divorceDetails: {
        date: divorceDetails.date,
        district: divorceDetails.district.trim(),
        sector: divorceDetails.sector.trim(),
      },
    },
  };

  // Create application with status 'pending' (no documents)
  const application = await Application.create({
    userId,
    applicationType: 'DIVORCE',
    type: 'divorce',
    payload,
    documents: [], // No document uploads for divorce
    status: 'pending',
  });

  // Populate userId to return user info
  await application.populate('userId', 'fullName email');

  return application;
};

/**
 * Get all applications for a specific user
 * @param {string} userId - User ID
 * @returns {Promise<Array>} List of user's applications, sorted by newest first
 */
export const getUserApplications = async (userId) => {
  const applications = await Application.find({ userId })
    .populate('userId', 'fullName email')
    .sort({ createdAt: -1 }) // Newest first
    .lean();

  return applications;
};

/**
 * Get application by ID, ensuring it belongs to the user
 * @param {string} applicationId - Application ID
 * @param {string} userId - User ID (to verify ownership)
 * @returns {Promise<Object>} Application details
 */
export const getApplicationById = async (applicationId, userId) => {
  const application = await Application.findById(applicationId)
    .populate('userId', 'fullName email')
    .populate('reviewedBy', 'fullName email')
    .lean();

  if (!application) {
    const error = new Error('Application not found');
    error.statusCode = 404;
    throw error;
  }

  // Ensure application belongs to the user
  if (application.userId._id.toString() !== userId.toString()) {
    const error = new Error('Access denied. This application does not belong to you');
    error.statusCode = 403;
    throw error;
  }

  return application;
};

/**
 * Get all pending applications (admin only)
 * @returns {Promise<Array>} List of pending applications
 */
export const getPendingApplications = async () => {
  const applications = await Application.find({ status: 'pending' })
    .populate('userId', 'fullName email')
    .sort({ createdAt: -1 }) // Newest first
    .lean();

  return applications;
};

/**
 * Get applications by status (admin only)
 * @param {string} status - Application status: 'pending', 'approved', or 'rejected'
 * @returns {Promise<Array>} List of applications with the specified status
 */
export const getApplicationsByStatus = async (status) => {
  if (!['pending', 'approved', 'rejected'].includes(status)) {
    const error = new Error('Invalid status. Must be pending, approved, or rejected');
    error.statusCode = 400;
    throw error;
  }

  const applications = await Application.find({ status })
    .populate('userId', 'fullName email')
    .populate('reviewedBy', 'fullName email')
    .sort({ createdAt: -1 }) // Newest first
    .lean();

  return applications;
};

/**
 * Approve an application and apply domain logic
 * @param {string} applicationId - Application ID
 * @param {string} adminId - Admin user ID
 * @returns {Promise<Object>} Updated application
 */
export const approveApplication = async (applicationId, adminId) => {
  const application = await Application.findById(applicationId).lean();

  if (!application) {
    const error = new Error('Application not found');
    error.statusCode = 404;
    throw error;
  }

  if (application.status !== 'pending') {
    const error = new Error('Application is not pending');
    error.statusCode = 400;
    throw error;
  }

  const { type } = application;

  // Apply domain logic based on application type
  if (type === 'birth') {
    // Birth approval logic - certificate will be generated by user request only
    // No automatic certificate creation - user must request it via Generate Certificate
    // No FamilyMember creation needed in CRVS model
  } else if (type === 'marriage') {
    // Marriage approval logic - certificate will be generated by user request only
    // No automatic certificate creation - user must request it via Generate Certificate
    // No FamilyMember creation needed in CRVS model
    // Islamic validation already done during application creation
  } else if (type === 'divorce') {
    // Divorce approval logic
    const divorcePayload = application.payload?.divorce;
    if (divorcePayload && divorcePayload.marriageApplicationId) {
      // Mark related marriage as DIVORCED (logical flag)
      await Application.findByIdAndUpdate(
        divorcePayload.marriageApplicationId,
        {
          $set: {
            'payload.marriage.isDivorced': true,
            'payload.marriage.divorcedAt': new Date(),
            'payload.marriage.divorceApplicationId': applicationId,
          },
        },
        { new: false },
      );

      // Bride becomes eligible for new marriage (handled by checking isDivorced flag)
      // Groom wife-count decreases by 1 (handled by checking isDivorced flag in marriage validation)
    }
  }

  // Update application status to approved
  const updatedApplication = await Application.findByIdAndUpdate(
    applicationId,
    {
      status: 'approved',
      reviewedBy: adminId,
      reviewedAt: new Date(),
    },
    { new: true },
  )
    .populate('userId', 'fullName email')
    .populate('reviewedBy', 'fullName email')
    .lean();

  // Certificate is NOT created automatically
  // User must explicitly request certificate generation via POST /api/certificates/birth

  return updatedApplication;
};

/**
 * Reject an application
 * @param {string} applicationId - Application ID
 * @param {string} adminId - Admin user ID
 * @param {string} reason - Rejection reason
 * @returns {Promise<Object>} Updated application
 */
export const rejectApplication = async (applicationId, adminId, reason) => {
  const application = await Application.findById(applicationId);

  if (!application) {
    const error = new Error('Application not found');
    error.statusCode = 404;
    throw error;
  }

  if (application.status !== 'pending') {
    const error = new Error('Application is not pending');
    error.statusCode = 400;
    throw error;
  }

  // Update application status to rejected
  const updatedApplication = await Application.findByIdAndUpdate(
    applicationId,
    {
      status: 'rejected',
      reviewedBy: adminId,
      reviewedAt: new Date(),
      adminComment: reason,
    },
    { new: true },
  )
    .populate('userId', 'fullName email')
    .populate('reviewedBy', 'fullName email')
    .lean();

  return updatedApplication;
};
