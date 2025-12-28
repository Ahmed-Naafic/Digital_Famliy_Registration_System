import dotenv from 'dotenv';
import { connectDB } from '../src/config/db.js';
import Citizen from '../src/models/Citizen.model.js';

// Load environment variables
dotenv.config();

const seedCitizens = async () => {
  try {
    console.log('Connecting to database...');
    await connectDB();

    // Clear existing citizens (optional - comment out if you want to keep existing data)
    // await Citizen.deleteMany({});
    // console.log('✓ Cleared existing citizens');

    // Check if citizens already exist
    const existingCount = await Citizen.countDocuments();
    if (existingCount > 0) {
      console.log(`⚠ Found ${existingCount} existing citizens. Skipping seed.`);
      console.log('   To re-seed, delete existing citizens first.');
      process.exit(0);
    }

    const citizens = [
      {
        nationalId: '123456789',
        fullName: 'Ahmed Mohamed Ali',
        dateOfBirth: '1985-06-20',
        gender: 'MALE',
        nationality: 'Somali',
        status: 'ACTIVE',
      },
      {
        nationalId: '987654321',
        fullName: 'Amina Yusuf Hassan',
        dateOfBirth: '1990-09-12',
        gender: 'FEMALE',
        nationality: 'Somali',
        status: 'ACTIVE',
      },
      {
        nationalId: '555555555',
        fullName: 'Hassan Abdi Mohamed',
        dateOfBirth: '1978-03-15',
        gender: 'MALE',
        nationality: 'Somali',
        status: 'ACTIVE',
      },
      {
        nationalId: '111111111',
        fullName: 'Fatima Ali Ibrahim',
        dateOfBirth: '1992-11-08',
        gender: 'FEMALE',
        nationality: 'Somali',
        status: 'ACTIVE',
      },
      {
        nationalId: '222222222',
        fullName: 'Omar Abdullahi Warsame',
        dateOfBirth: '1988-07-25',
        gender: 'MALE',
        nationality: 'Somali',
        status: 'ACTIVE',
      },
      {
        nationalId: '333333333',
        fullName: 'Khadija Mohamed Farah',
        dateOfBirth: '1995-02-14',
        gender: 'FEMALE',
        nationality: 'Somali',
        status: 'ACTIVE',
      },
         {
        nationalId: '62770634773',
        fullName: 'Mahmood Ahmed Hassan',
        dateOfBirth: '1959-05-05',
        gender: 'MALE',
        nationality: 'Somali',
        status: 'ACTIVE',
      },
    ];

    await Citizen.insertMany(citizens);
    console.log(`✓ Successfully inserted ${citizens.length} test citizens`);
    console.log('\nTest National IDs:');
    citizens.forEach((citizen) => {
      console.log(`  - ${citizen.nationalId}: ${citizen.fullName}`);
    });
    process.exit(0);
  } catch (error) {
    console.error('✗ Error seeding data:', error);
    process.exit(1);
  }
};

seedCitizens();

