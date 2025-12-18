import { registerUser, loginUser } from '../services/auth.service.js';
import { successResponse, errorResponse } from '../utils/response.util.js';

export const register = async (req, res) => {
  try {
    const { fullName, email, phoneNumber, password } = req.body;

    const user = await registerUser({
      fullName,
      email,
      phoneNumber,
      password,
    });

    return successResponse(res, 'Registration successful', { user }, 201);
  } catch (error) {
    const statusCode = error.statusCode || 400;
    return errorResponse(res, error.message || 'Registration failed', statusCode);
  }
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const result = await loginUser({
      email,
      password,
    });

    return successResponse(res, 'Login successful', result);
  } catch (error) {
    const statusCode = error.statusCode || 400;
    return errorResponse(res, error.message || 'Login failed', statusCode);
  }
};


