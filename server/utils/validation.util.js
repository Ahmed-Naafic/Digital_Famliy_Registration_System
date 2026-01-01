/**
 * Validation utilities for application payloads
 */

const APPLICATION_TYPES = ['birth', 'marriage', 'divorce', 'death'];

/**
 * Validate application type
 * @param {string} type - Application type
 * @throws {Error} If type is invalid
 */
export const validateApplicationType = (type) => {
  if (!type || typeof type !== 'string') {
    const error = new Error('Application type is required');
    error.statusCode = 400;
    throw error;
  }

  if (!APPLICATION_TYPES.includes(type.toLowerCase())) {
    const error = new Error(
      `Invalid application type. Must be one of: ${APPLICATION_TYPES.join(', ')}`,
    );
    error.statusCode = 400;
    throw error;
  }

  return type.toLowerCase();
};

/**
 * Validate payload object
 * @param {any} payload - Payload to validate
 * @throws {Error} If payload is invalid
 */
export const validatePayload = (payload) => {
  if (!payload || typeof payload !== 'object') {
    const error = new Error('Payload is required and must be an object');
    error.statusCode = 400;
    throw error;
  }

  if (Array.isArray(payload)) {
    const error = new Error('Payload must be an object, not an array');
    error.statusCode = 400;
    throw error;
  }

  if (Object.keys(payload).length === 0) {
    const error = new Error('Payload must not be empty');
    error.statusCode = 400;
    throw error;
  }

  return payload;
};

/**
 * Normalize payload (parse JSON string if needed)
 * @param {any} payload - Payload to normalize
 * @returns {Object} Normalized payload object
 */
export const normalizePayload = (payload) => {
  if (typeof payload === 'string') {
    try {
      return JSON.parse(payload);
    } catch (parseError) {
      const error = new Error('Invalid payload format. Must be valid JSON');
      error.statusCode = 400;
      throw error;
    }
  }

  return payload;
};




