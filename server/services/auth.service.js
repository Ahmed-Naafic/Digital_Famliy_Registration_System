import jwt from 'jsonwebtoken';
import User from '../models/User.model.js';
import { hashPassword, comparePassword } from '../utils/password.util.js';
import { fetchPersonByNationalId } from './nira.service.js';

const JWT_EXPIRES_IN = '7d';

const buildUserResponse = (user) => ({
  id: user._id,
  fullName: user.fullName,
  email: user.email,
  role: user.role,
});

export const registerUser = async ({ fullName, email, phoneNumber, password, nationalId }) => {
  // Validate required fields
  if (!nationalId || typeof nationalId !== 'string' || nationalId.trim().length === 0) {
    const error = new Error('National ID is required');
    error.statusCode = 400;
    throw error;
  }

  // Check for existing email
  const existingUserByEmail = await User.findOne({ email });
  if (existingUserByEmail) {
    const error = new Error('Email is already in use');
    error.statusCode = 409;
    throw error;
  }

  // Check for existing nationalId
  const existingUserByNationalId = await User.findOne({ nationalId: nationalId.trim() });
  if (existingUserByNationalId) {
    const error = new Error('National ID is already registered');
    error.statusCode = 409;
    throw error;
  }

  // Verify National ID via NIRA
  try {
    await fetchPersonByNationalId(nationalId.trim());
  } catch (error) {
    const niraError = new Error(`National ID verification failed: ${error.message}`);
    niraError.statusCode = error.statusCode || 400;
    throw niraError;
  }

  const passwordHash = await hashPassword(password);

  const user = await User.create({
    fullName,
    email,
    nationalId: nationalId.trim(),
    phoneNumber,
    passwordHash,
    role: 'citizen',
  });

  if (!process.env.JWT_SECRET) {
    const error = new Error('JWT_SECRET is not configured');
    error.statusCode = 500;
    throw error;
  }

  const token = jwt.sign(
    {
      sub: user._id.toString(),
      role: user.role,
      nationalId: user.nationalId,
    },
    process.env.JWT_SECRET,
    {
      expiresIn: JWT_EXPIRES_IN,
    },
  );

  return {
    token,
    user: buildUserResponse(user),
    role: user.role, // Explicitly include role at top level for frontend
  };
};

export const loginUser = async ({ email, password }) => {
  const user = await User.findOne({ email });

  if (!user) {
    const error = new Error('Invalid email or password');
    error.statusCode = 401;
    throw error;
  }

  const isMatch = await comparePassword(password, user.passwordHash);

  if (!isMatch) {
    const error = new Error('Invalid email or password');
    error.statusCode = 401;
    throw error;
  }

  if (!process.env.JWT_SECRET) {
    const error = new Error('JWT_SECRET is not configured');
    error.statusCode = 500;
    throw error;
  }

  const token = jwt.sign(
    {
      sub: user._id.toString(),
      role: user.role,
      nationalId: user.nationalId || null, // null for backward compatibility with old users
    },
    process.env.JWT_SECRET,
    {
      expiresIn: JWT_EXPIRES_IN,
    },
  );

  return {
    token,
    user: buildUserResponse(user),
    role: user.role, // Explicitly include role at top level for frontend
  };
};



