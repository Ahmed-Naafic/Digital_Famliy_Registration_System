import dotenv from 'dotenv';
import { connectDB } from './config/db.js';
import app from './app.js';

// Load environment variables
dotenv.config();

const PORT = process.env.PORT || 4000;

// Connect to MongoDB
connectDB();

// Start server
app.listen(PORT, () => {
  console.log('========================================');
  console.log('🚀 NIRA Mock Server');
  console.log('========================================');
  console.log(`✓ Server running on port ${PORT}`);
  console.log(`✓ API endpoint: http://localhost:${PORT}/api/citizens/:nationalId`);
  console.log('========================================');
});

