import express from 'express';
import authRoutes from './routes/auth.routes.js';

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

export default app;

