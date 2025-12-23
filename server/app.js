import express from 'express';
import authRoutes from './routes/auth.routes.js';
import applicationRoutes from './routes/application.routes.js';
import familyRoutes from './routes/family.routes.js';
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
app.use('/api/family', familyRoutes);

// Error middleware must be registered LAST
// It will catch all errors from routes and other middlewares
app.use(errorMiddleware);

export default app;

