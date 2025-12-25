import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from '../models/User.model.js';
import { hashPassword } from '../utils/password.util.js';

// Load environment variables
dotenv.config();

/**
 * Script to create an admin user
 * Usage: node server/scripts/create-admin.js <email> <password> <fullName>
 * Example: node server/scripts/create-admin.js admin@example.com admin123 "Admin User"
 */
async function createAdmin() {
  try {
    // Get command line arguments
    const args = process.argv.slice(2);
    
    if (args.length < 3) {
      console.error('Usage: node create-admin.js <email> <password> <fullName>');
      console.error('Example: node create-admin.js admin@example.com admin123 "Admin User"');
      process.exit(1);
    }

    const [email, password, fullName] = args;

    // Connect to MongoDB
    if (!process.env.MONGODB_URI) {
      console.error('Error: MONGODB_URI is not set in .env file');
      process.exit(1);
    }

    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Check if admin already exists
    const existingAdmin = await User.findOne({ email, role: 'admin' });
    if (existingAdmin) {
      console.log(`Admin user with email ${email} already exists.`);
      console.log('To update the password, delete the user first or use a different email.');
      await mongoose.disconnect();
      process.exit(0);
    }

    // Check if email is already in use (as citizen)
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      console.log(`User with email ${email} already exists with role: ${existingUser.role}`);
      console.log('Updating role to admin...');
      existingUser.role = 'admin';
      const passwordHash = await hashPassword(password);
      existingUser.passwordHash = passwordHash;
      existingUser.fullName = fullName;
      await existingUser.save();
      console.log('✅ Admin user updated successfully!');
      console.log(`Email: ${email}`);
      console.log(`Full Name: ${fullName}`);
      console.log(`Role: admin`);
      await mongoose.disconnect();
      process.exit(0);
    }

    // Create new admin user
    const passwordHash = await hashPassword(password);
    
    const adminUser = await User.create({
      fullName,
      email,
      passwordHash,
      role: 'admin',
      isVerified: true,
      status: 'active',
    });

    console.log('✅ Admin user created successfully!');
    console.log(`Email: ${email}`);
    console.log(`Full Name: ${fullName}`);
    console.log(`Role: admin`);
    console.log(`User ID: ${adminUser._id}`);

    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
    process.exit(0);
  } catch (error) {
    console.error('Error creating admin user:', error);
    await mongoose.disconnect();
    process.exit(1);
  }
}

createAdmin();



