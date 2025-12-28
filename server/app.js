import express from 'express';
import authRoutes from './routes/auth.routes.js';
import applicationRoutes from './routes/application.routes.js';
import adminRoutes from './routes/admin.routes.js';
import serviceRoutes from './routes/service.routes.js';
import certificateRoutes from './routes/certificate.routes.js';
import identityRoutes from './routes/identity.routes.js';
import locationRoutes from './routes/location.routes.js';
import { errorMiddleware } from './middlewares/error.middleware.js';

const app = express();

app.use(express.json());
app.use(
  express.urlencoded({
    extended: true,
  }),
);

app.get('/', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'Digital Family Registration System API is running',
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/applications', applicationRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/certificates', certificateRoutes);
app.use('/api/identity', identityRoutes);
app.use('/api/locations', locationRoutes);

// Error middleware must be registered LAST
// It will catch all errors from routes and other middlewares
app.use(errorMiddleware);

export default app;

