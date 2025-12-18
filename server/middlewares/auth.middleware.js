import jwt from 'jsonwebtoken';
import User from '../models/User.model.js';

export const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ')
      ? authHeader.substring(7)
      : null;

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Authentication token missing',
      });
    }

    if (!process.env.JWT_SECRET) {
      return res.status(500).json({
        success: false,
        message: 'JWT_SECRET is not configured',
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const user = await User.findById(decoded.sub);

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid authentication token',
      });
    }

    req.user = {
      id: user._id,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
    };

    return next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Authentication failed',
    });
  }
};


