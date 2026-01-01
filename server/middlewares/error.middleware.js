/**
 * Global error handling middleware
 * Catches all errors and returns consistent JSON responses
 * Must be registered LAST in the middleware chain
 */
export const errorMiddleware = (err, req, res, next) => {
  // Default error values
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal server error';

  // Handle JWT specific errors
  if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Invalid authentication token';
  } else if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Authentication token has expired';
  }

  // Handle MongoDB/Mongoose errors
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation error';
    // Optionally include validation details in development
    if (process.env.NODE_ENV !== 'production' && err.errors) {
      message += ': ' + Object.values(err.errors).map((e) => e.message).join(', ');
    }
  } else if (err.name === 'MongoServerError' || err.name === 'MongoError') {
    // Duplicate key error
    if (err.code === 11000) {
      statusCode = 409;
      const field = Object.keys(err.keyPattern || {})[0];
      message = `${field || 'Field'} already exists`;
    } else {
      statusCode = 500;
      message = 'Database error occurred';
    }
  } else if (err.name === 'CastError') {
    statusCode = 400;
    message = 'Invalid ID format';
  }

  // Log error in development or if it's a server error
  if (process.env.NODE_ENV !== 'production' || statusCode >= 500) {
    // eslint-disable-next-line no-console
    console.error('Error:', {
      message: err.message,
      stack: err.stack,
      statusCode,
      path: req.path,
      method: req.method,
    });
  }

  // Send error response
  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV !== 'production' && err.stack
      ? { stack: err.stack }
      : {}),
  });
};
 






