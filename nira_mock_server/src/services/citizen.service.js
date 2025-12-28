import Citizen from '../models/Citizen.model.js';

/**
 * Find citizen by National ID
 * @param {string} nationalId - National ID number
 * @returns {Promise<Object|null>} Citizen document or null if not found
 */
export const findCitizenByNationalId = async (nationalId) => {
  if (!nationalId || typeof nationalId !== 'string' || nationalId.trim().length === 0) {
    return null;
  }

  const citizen = await Citizen.findOne({
    nationalId: nationalId.trim(),
  }).lean();

  return citizen;
};

