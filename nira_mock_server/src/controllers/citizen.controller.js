/**
 * Get citizen by National ID
 * GET /api/citizens/:nationalId
 */
export const getCitizenByNationalId = async (req, res) => {
  try {
    const { nationalId } = req.params;

    if (!nationalId) {
      return res.status(400).json({
        success: false,
        message: 'National ID is required',
      });
    }

    const { findCitizenByNationalId } = await import('../services/citizen.service.js');
    const citizen = await findCitizenByNationalId(nationalId);

    if (!citizen) {
      return res.status(404).json({
        success: false,
        message: `Citizen with National ID ${nationalId} not found`,
      });
    }

    return res.status(200).json({
      success: true,
      data: {
        nationalId: citizen.nationalId,
        fullName: citizen.fullName,
        dateOfBirth: citizen.dateOfBirth,
        gender: citizen.gender,
        nationality: citizen.nationality,
        status: citizen.status,
      },
    });
  } catch (error) {
    console.error('Error fetching citizen:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message,
    });
  }
};

