import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Application from '../models/Application.model.js';
import Certificate from '../models/Certificate.model.js';
import User from '../models/User.model.js';
import Family from '../models/Family.model.js';
import FamilyMember from '../models/FamilyMember.model.js';
import { createCertificate } from '../services/certificate.service.js';

// Load environment variables
dotenv.config();

/**
 * Script to create missing certificates for approved applications
 * This will find all approved applications that don't have certificates
 * and create certificates for them
 */
const createMissingCertificates = async () => {
  try {
    // Connect to MongoDB
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/digital_family_system';
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');

    // Find all approved applications
    const approvedApplications = await Application.find({
      status: 'approved',
    })
      .populate('reviewedBy', '_id')
      .lean();

    console.log(`\n📋 Found ${approvedApplications.length} approved applications`);

    // Find all existing certificates
    const existingCertificates = await Certificate.find({}).select('applicationId').lean();
    const existingApplicationIds = new Set(
      existingCertificates.map((cert) => cert.applicationId.toString())
    );

    // Filter applications without certificates
    const applicationsWithoutCertificates = approvedApplications.filter(
      (app) => !existingApplicationIds.has(app._id.toString())
    );

    console.log(
      `\n🔍 Found ${applicationsWithoutCertificates.length} approved applications without certificates\n`,
    );

    if (applicationsWithoutCertificates.length === 0) {
      console.log('✅ All approved applications already have certificates!');
      await mongoose.disconnect();
      return;
    }

    // Create certificates for each application
    let successCount = 0;
    let errorCount = 0;

    for (const app of applicationsWithoutCertificates) {
      try {
        const adminId = app.reviewedBy?._id || app.reviewedBy || null;

        if (!adminId) {
          console.log(
            `⚠️  Skipping application ${app._id} (${app.type}): No admin ID found`,
          );
          errorCount++;
          continue;
        }

        console.log(
          `Creating certificate for application ${app._id} (${app.type})...`,
        );

        const certificate = await createCertificate(app._id.toString(), adminId.toString());
        console.log(
          `✅ Created certificate ${certificate.certificateNumber} for ${app.type} application`,
        );
        successCount++;
      } catch (error) {
        console.error(
          `❌ Error creating certificate for application ${app._id} (${app.type}):`,
          error.message,
        );
        errorCount++;
      }
    }

    console.log('\n📊 Summary:');
    console.log(`✅ Successfully created: ${successCount} certificates`);
    console.log(`❌ Errors: ${errorCount} certificates`);
    console.log(`📋 Total processed: ${applicationsWithoutCertificates.length} applications\n`);

    await mongoose.disconnect();
    console.log('✅ Disconnected from MongoDB');
  } catch (error) {
    console.error('❌ Fatal error:', error);
    process.exit(1);
  }
};

// Run the script
createMissingCertificates();

