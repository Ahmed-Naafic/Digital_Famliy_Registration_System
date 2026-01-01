import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

import authRoutes from './routes/auth.routes.js';
import applicationRoutes from './routes/application.routes.js';
import adminRoutes from './routes/admin.routes.js';
import serviceRoutes from './routes/service.routes.js';
import certificateRoutes from './routes/certificate.routes.js';
import identityRoutes from './routes/identity.routes.js';
import locationRoutes from './routes/location.routes.js';

import { errorMiddleware } from './middlewares/error.middleware.js';

const app = express();

/* ===== Global Middlewares ===== */
app.use(helmet());

app.use(
  cors({
    origin: ['http://localhost:3000', 'https://your-frontend-domain.com'],
    credentials: true,
  }),
);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (process.env.NODE_ENV !== 'production') {
  app.use(morgan('dev'));
}

/* ===== Health Check ===== */
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'Digital Family Registration System API is running',
  });
});

/* ===== Routes ===== */
app.use('/api/auth', authRoutes);
app.use('/api/applications', applicationRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/certificates', certificateRoutes);
app.use('/api/identity', identityRoutes);
app.use('/api/locations', locationRoutes);

/* ===== 404 Handler ===== */
app.use((req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Route not found',
  });
});

/* ===== Error Handler ===== */
app.use(errorMiddleware);

export default app;
