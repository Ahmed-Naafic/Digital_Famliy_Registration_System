import User from '../models/User.model.js';
import Application from '../models/Application.model.js';
import Certificate from '../models/Certificate.model.js';
import ServiceConfig from '../models/ServiceConfig.model.js';

/**
 * Get admin dashboard statistics
 * @returns {Promise<Object>} Statistics object
 */
export const getAdminStatistics = async () => {
  try {
    // Count total citizens (users with role 'citizen')
    const totalCitizens = await User.countDocuments({ role: 'citizen', status: 'active' });

    // Count applications by status
    const pendingApplications = await Application.countDocuments({ status: 'pending' });
    const approvedApplications = await Application.countDocuments({ status: 'approved' });
    const rejectedApplications = await Application.countDocuments({ status: 'rejected' });

    // Count total certificates issued
    const totalCertificates = await Certificate.countDocuments({ status: 'valid' });

    return {
      totalCitizens,
      totalFamilies: 0, // CRVS model: no families
      pendingApplications,
      approvedApplications,
      rejectedApplications,
      totalCertificates,
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Get all citizens (users with role 'citizen')
 * @param {Object} options - Query options (page, limit, search)
 * @returns {Promise<Object>} Citizens list with pagination info
 */
export const getAllCitizens = async (options = {}) => {
  try {
    const { page = 1, limit = 50, search = '' } = options;
    const skip = (page - 1) * limit;

    // Build query
    const query = { role: 'citizen' };
    
    if (search && search.trim()) {
      query.$or = [
        { fullName: { $regex: search.trim(), $options: 'i' } },
        { email: { $regex: search.trim(), $options: 'i' } },
      ];
    }

    // Get citizens with pagination
    const [citizens, total] = await Promise.all([
      User.find(query)
        .select('-passwordHash') // Exclude password hash
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      User.countDocuments(query),
    ]);

    // CRVS model: no family info
    return {
      citizens: citizens.map((citizen) => ({
        ...citizen,
        hasFamily: false,
        familyId: null,
        familyName: null,
        familyMembersCount: 0,
      })),
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Get service-specific statistics (by application type)
 * @returns {Promise<Object>} Statistics by service type
 */
export const getServiceStatistics = async () => {
  try {
    const serviceTypes = ['birth', 'marriage', 'divorce', 'death'];
    const serviceStats = {};

    // Get all service configs
    const configs = await ServiceConfig.find().lean();
    const configMap = {};
    configs.forEach((config) => {
      configMap[config.serviceType] = config.enabled;
    });

    // Get statistics for each service type
    for (const type of serviceTypes) {
      const [total, pending, approved, rejected] = await Promise.all([
        Application.countDocuments({ type }),
        Application.countDocuments({ type, status: 'pending' }),
        Application.countDocuments({ type, status: 'approved' }),
        Application.countDocuments({ type, status: 'rejected' }),
      ]);

      serviceStats[type] = {
        total,
        pending,
        approved,
        rejected,
        enabled: configMap[type] !== undefined ? configMap[type] : true, // Default to enabled if not configured
      };
    }

    return serviceStats;
  } catch (error) {
    throw error;
  }
};

/**
 * Update service enabled/disabled status
 * @param {string} serviceType - Service type (birth, marriage, divorce, death)
 * @param {boolean} enabled - Whether service is enabled
 * @returns {Promise<Object>} Updated service config
 */
export const updateServiceStatus = async (serviceType, enabled) => {
  try {
    if (!['birth', 'marriage', 'divorce', 'death'].includes(serviceType)) {
      const error = new Error('Invalid service type');
      error.statusCode = 400;
      throw error;
    }

    const config = await ServiceConfig.findOneAndUpdate(
      { serviceType },
      { enabled, serviceType },
      { upsert: true, new: true },
    );

    return config;
  } catch (error) {
    throw error;
  }
};

/**
 * Get all families with pagination and search
 * CRVS model: Families not supported - returns empty
 */
export const getAllFamilies = async (options = {}) => {
  return {
    families: [],
    total: 0,
    page: 1,
    limit: 50,
    totalPages: 0,
  };
};

/**
 * Get family members by family ID (admin only)
 * CRVS model: Family members not supported - returns empty
 */
export const getFamilyMembersByFamilyId = async (familyId) => {
  return [];
};

/**
 * Get enabled services (for citizens)
 * @returns {Promise<Array>} List of enabled service types
 */
export const getEnabledServices = async () => {
  try {
    const serviceTypes = ['birth', 'marriage', 'divorce', 'death'];
    
    // Get all service configs
    const configs = await ServiceConfig.find().lean();
    const configMap = {};
    configs.forEach((config) => {
      configMap[config.serviceType] = config.enabled;
    });

    console.log('Service configs from DB:', configMap);

    // Filter to only return enabled services
    // If a service has no config, it's enabled by default
    const enabledTypes = serviceTypes.filter((type) => {
      const isEnabled = configMap[type] !== undefined ? configMap[type] === true : true;
      console.log(`Service ${type}: enabled=${isEnabled} (config: ${configMap[type]})`);
      return isEnabled;
    });

    console.log('Enabled services to return:', enabledTypes);
    return enabledTypes;
  } catch (error) {
    console.error('Error in getEnabledServices:', error);
    throw error;
  }
};

