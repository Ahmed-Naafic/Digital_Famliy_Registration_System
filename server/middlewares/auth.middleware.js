import jwt from 'jsonwebtoken';
import User from '../models/User.model.js';

/**
 * Authentication middleware
 * Verifies JWT token from Authorization header and attaches user to req.user
 * Throws errors that should be handled by error middleware
 */
export const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ')
      ? authHeader.substring(7)
      : null;

    if (!token) {
      const error = new Error('Authentication token missing');
      error.statusCode = 401;
      throw error;
    }

    if (!process.env.JWT_SECRET) {
      const error = new Error('JWT_SECRET is not configured');
      error.statusCode = 500;
      throw error;
    }

    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (jwtError) {
      const error = new Error('Invalid or expired authentication token');
      error.statusCode = 401;
      throw error;
    }

    const user = await User.findById(decoded.sub);

    if (!user) {
      const error = new Error('Invalid authentication token');
      error.statusCode = 401;
      throw error;
    }

    req.user = {
      id: user._id,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
    };

    next();
  } catch (error) {
    next(error);
  }
};




