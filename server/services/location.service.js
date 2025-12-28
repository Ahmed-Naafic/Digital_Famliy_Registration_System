import Location from '../models/Location.model.js';

/**
 * Get all distinct districts (optionally filtered by region)
 * @param {string} region - Optional region filter
 * @returns {Promise<Array<string>>} List of distinct district names
 */
export const getDistricts = async (region = null) => {
  const query = { isActive: true };
  
  if (region) {
    query.region = region;
  }

  const districts = await Location.distinct('district', query);
  return districts.sort(); // Return alphabetically sorted
};

/**
 * Get all sectors for a specific district
 * @param {string} district - District name
 * @param {string} region - Optional region filter
 * @returns {Promise<Array<string>>} List of sector names
 */
export const getSectorsByDistrict = async (district, region = null) => {
  const query = {
    district: district,
    isActive: true,
  };

  if (region) {
    query.region = region;
  }

  const locations = await Location.find(query)
    .select('sector')
    .sort({ sector: 1 })
    .lean();

  const sectors = locations.map((loc) => loc.sector);
  return [...new Set(sectors)]; // Remove duplicates and return sorted
};

/**
 * Get all regions
 * @returns {Promise<Array<string>>} List of distinct region names
 */
export const getRegions = async () => {
  const regions = await Location.distinct('region', { isActive: true });
  return regions.sort();
};

