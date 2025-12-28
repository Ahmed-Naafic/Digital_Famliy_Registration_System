/**
 * NIRA Integration Service
 * This is the ONLY place allowed to call NIRA API
 * Uses Node.js built-in fetch (Node 18+)
 * Integrates with Mock NIRA server at http://localhost:5500
 */

/**
 * Fetch person data from NIRA by National ID
 * @param {string} nationalId - National ID number
 * @returns {Promise<Object>} Normalized person data
 * @throws {Error} If NIRA API call fails or person not found
 */
export const fetchPersonByNationalId = async (nationalId) => {
  if (!nationalId || typeof nationalId !== 'string' || nationalId.trim().length === 0) {
    const error = new Error('National ID is required and must be a non-empty string');
    error.statusCode = 400;
    throw error;
  }

  const niraApiUrl = process.env.NIRA_API_URL;

  if (!niraApiUrl) {
    const error = new Error('NIRA API configuration missing. NIRA_API_URL must be set');
    error.statusCode = 500;
    throw error;
  }

  try {
    // Call Mock NIRA API: GET ${NIRA_API_URL}/${nationalId}
    // Example: GET http://localhost:5500/api/citizens/123456789
    const response = await fetch(`${niraApiUrl}/${nationalId}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      if (response.status === 404) {
        const error = new Error(`Citizen with National ID ${nationalId} not found in NIRA`);
        error.statusCode = 404;
        throw error;
      }
      const error = new Error(`NIRA API error: ${response.status} ${response.statusText}`);
      error.statusCode = response.status;
      throw error;
    }

    const responseData = await response.json();

    // Mock NIRA response format: { success: true, data: { ... } }
    const data = responseData.data || responseData;

    // Normalize and return data (only required fields)
    return {
      nationalId: data.nationalId || nationalId,
      fullName: data.fullName || data.name || '',
      dateOfBirth: data.dateOfBirth || data.dob || null,
      gender: data.gender || null,
      status: data.status || 'ACTIVE',
    };
  } catch (error) {
    // Re-throw if it's already our custom error
    if (error.statusCode) {
      throw error;
    }

    // Handle network errors
    const networkError = new Error(`Failed to connect to NIRA API: ${error.message}`);
    networkError.statusCode = 503;
    throw networkError;
  }
};

