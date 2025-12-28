import express from 'express';
import citizenRoutes from './routes/citizen.routes.js';

const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'NIRA Mock Server is running',
    version: '1.0.0',
  });
});

// API Routes
app.use('/api/citizens', citizenRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

export default app;

