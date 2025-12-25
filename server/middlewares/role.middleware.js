/**
 * Role-based authorization middleware
 * Checks if the authenticated user has one of the allowed roles
 * 
 * @param {...string} allowedRoles - One or more allowed roles (e.g. 'admin', 'citizen')
 * @returns {Function} Express middleware function
 * 
 * @example
 * router.get('/admin', authMiddleware, roleMiddleware('admin'), adminController);
 * router.post('/data', authMiddleware, roleMiddleware('admin', 'citizen'), dataController);
 */
export const roleMiddleware = (...allowedRoles) => {
  return (req, res, next) => {
    try {
      if (!req.user || !req.user.role) {
        const error = new Error('User role not found');
        error.statusCode = 401;
        throw error;
      }

      if (!allowedRoles.includes(req.user.role)) {
        const error = new Error('Insufficient permissions');
        error.statusCode = 403;
        throw error;
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};






