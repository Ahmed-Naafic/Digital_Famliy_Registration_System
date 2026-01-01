/**
 * Admin middleware
 * Ensures the logged-in user has admin role
 * Must be used after authMiddleware
 */
export const adminMiddleware = (req, res, next) => {
  if (!req.user) {
    const error = new Error('Authentication required');
    error.statusCode = 401;
    return next(error);
  }

  if (req.user.role !== 'admin') {
    const error = new Error('Admin access required');
    error.statusCode = 403;
    return next(error);
  }

  next();
};




