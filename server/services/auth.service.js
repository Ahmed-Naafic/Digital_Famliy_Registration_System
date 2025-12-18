import jwt from 'jsonwebtoken';
import User from '../models/User.model.js';
import { hashPassword, comparePassword } from '../utils/password.util.js';

const JWT_EXPIRES_IN = '7d';

const buildUserResponse = (user) => ({
  id: user._id,
  fullName: user.fullName,
  email: user.email,
  role: user.role,
});

export const registerUser = async ({ fullName, email, phoneNumber, password }) => {
  const existingUser = await User.findOne({ email });

  if (existingUser) {
    const error = new Error('Email is already in use');
    error.statusCode = 409;
    throw error;
  }

  const passwordHash = await hashPassword(password);

  const user = await User.create({
    fullName,
    email,
    phoneNumber,
    passwordHash,
    role: 'citizen',
  });

  return buildUserResponse(user);
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
    },
    process.env.JWT_SECRET,
    {
      expiresIn: JWT_EXPIRES_IN,
    },
  );

  return {
    token,
    user: buildUserResponse(user),
  };
};


