import User from '../models/User.model.js';
import Family from '../models/Family.model.js';
import Application from '../models/Application.model.js';
import Certificate from '../models/Certificate.model.js';
import FamilyMember from '../models/FamilyMember.model.js';
import ServiceConfig from '../models/ServiceConfig.model.js';

/**
 * Get admin dashboard statistics
 * @returns {Promise<Object>} Statistics object
 */
export const getAdminStatistics = async () => {
  try {
    // Count total citizens (users with role 'citizen')
    const totalCitizens = await User.countDocuments({ role: 'citizen', status: 'active' });

    // Count total families (active families)
    const totalFamilies = await Family.countDocuments({ status: 'active' });

    // Count applications by status
    const pendingApplications = await Application.countDocuments({ status: 'pending' });
    const approvedApplications = await Application.countDocuments({ status: 'approved' });
    const rejectedApplications = await Application.countDocuments({ status: 'rejected' });

    // Count total certificates issued
    const totalCertificates = await Certificate.countDocuments({ status: 'valid' });

    return {
      totalCitizens,
      totalFamilies,
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

    // Get family info for each citizen
    const citizensWithFamily = await Promise.all(
      citizens.map(async (citizen) => {
        const family = await Family.findOne({
          linkedUsers: citizen._id,
          status: 'active',
        }).lean();

        const familyMembersCount = family
          ? await FamilyMember.countDocuments({ familyId: family._id })
          : 0;

        return {
          ...citizen,
          hasFamily: !!family,
          familyId: family?._id?.toString(),
          familyName: family?.familyName,
          familyMembersCount,
        };
      }),
    );

    return {
      citizens: citizensWithFamily,
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
 * @param {Object} options - Pagination and search options
 * @param {number} options.page - Current page number
 * @param {number} options.limit - Number of items per page
 * @param {string} options.search - Search query for familyName or familyNumber
 * @returns {Promise<Object>} Paginated list of families
 */
export const getAllFamilies = async (options = {}) => {
  try {
    const { page = 1, limit = 50, search = '' } = options;
    const skip = (page - 1) * limit;

    // Build query
    const query = { status: 'active' };

    if (search && search.trim()) {
      query.$or = [
        { familyName: { $regex: search.trim(), $options: 'i' } },
        { familyNumber: { $regex: search.trim(), $options: 'i' } },
      ];
    }

    // Get families with pagination
    const [families, total] = await Promise.all([
      Family.find(query)
        .populate('linkedUsers', 'fullName email')
        .populate('headOfFamilyId', 'firstName lastName')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      Family.countDocuments(query),
    ]);

    // Get member count and linked users info for each family
    const familiesWithDetails = await Promise.all(
      families.map(async (family) => {
        const memberCount = await FamilyMember.countDocuments({
          familyId: family._id,
        });

        const linkedUsersInfo = family.linkedUsers
          ? family.linkedUsers.map((user) => ({
              id: user._id?.toString(),
              name: user.fullName,
              email: user.email,
            }))
          : [];

        return {
          _id: family._id?.toString(),
          familyName: family.familyName,
          familyNumber: family.familyNumber,
          address: family.address,
          status: family.status,
          memberCount: memberCount,
          linkedUsersCount: linkedUsersInfo.length,
          linkedUsers: linkedUsersInfo,
          headOfFamily: family.headOfFamilyId
            ? {
                id: family.headOfFamilyId._id?.toString(),
                name: `${family.headOfFamilyId.firstName} ${family.headOfFamilyId.lastName}`,
              }
            : null,
          createdAt: family.createdAt,
          updatedAt: family.updatedAt,
        };
      }),
    );

    return {
      families: familiesWithDetails,
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
 * Get family members by family ID (admin only)
 * @param {string} familyId - Family ID
 * @returns {Promise<Array>} List of family members
 */
export const getFamilyMembersByFamilyId = async (familyId) => {
  try {
    const family = await Family.findById(familyId).lean();

    if (!family) {
      const error = new Error('Family not found');
      error.statusCode = 404;
      throw error;
    }

    const members = await FamilyMember.find({ familyId })
      .populate('fatherId', 'firstName lastName')
      .populate('motherId', 'firstName lastName')
      .populate('spouseId', 'firstName lastName')
      .sort({ createdAt: -1 })
      .lean();

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
      fatherName: member.fatherId
        ? `${member.fatherId.firstName} ${member.fatherId.lastName}`
        : null,
      motherId: member.motherId?._id?.toString(),
      motherName: member.motherId
        ? `${member.motherId.firstName} ${member.motherId.lastName}`
        : null,
      spouseId: member.spouseId?._id?.toString(),
      spouseName: member.spouseId
        ? `${member.spouseId.firstName} ${member.spouseId.lastName}`
        : null,
      createdAt: member.createdAt,
      updatedAt: member.updatedAt,
    }));
  } catch (error) {
    throw error;
  }
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

