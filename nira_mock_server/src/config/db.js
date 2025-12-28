import mongoose from 'mongoose';

/**
 * Connect to MongoDB
 * @returns {Promise<void>}
 */
export const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGO_URI;

    if (!mongoUri) {
      throw new Error('MONGO_URI environment variable is not set');
    }

    await mongoose.connect(mongoUri);

    console.log('✓ MongoDB connected successfully');
    console.log(`  Database: ${mongoose.connection.name}`);
  } catch (error) {
    console.error('✗ MongoDB connection error:', error.message);
    process.exit(1);
  }
};

