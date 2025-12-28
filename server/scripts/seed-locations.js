import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Location from '../models/Location.model.js';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load environment variables
dotenv.config({ path: join(__dirname, '../.env') });

/**
 * Seed Somalia location data
 * Region: Banadir (Mogadishu)
 */
const banadirLocations = [
  // Hodan District
  { region: 'Banadir', district: 'Hodan', sector: 'Taleex' },
  { region: 'Banadir', district: 'Hodan', sector: 'Tarabuunka' },
  
  // Wadajir District
  { region: 'Banadir', district: 'Wadajir', sector: 'Medina' },
  { region: 'Banadir', district: 'Wadajir', sector: 'Buulo xubey' },
  
  // Yaqshid District
  { region: 'Banadir', district: 'Yaqshid', sector: 'Juungal' },
  { region: 'Banadir', district: 'Yaqshid', sector: 'Suuq bacaad' },
  
  // Dharkenley District
  { region: 'Banadir', district: 'Dharkenley', sector: 'Xoosh' },
  { region: 'Banadir', district: 'Dharkenley', sector: 'Barwaaqo' },
  
  // Heliwaa District
  { region: 'Banadir', district: 'Heliwaa', sector: 'Suuqa xoolaha' },
  { region: 'Banadir', district: 'Heliwaa', sector: 'Al cadaala' },
];

async function seedLocations() {
  try {
    // Connect to MongoDB
    const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/digital_family_system';
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');

    // Clear existing locations (optional - comment out if you want to keep existing data)
    // await Location.deleteMany({});
    // console.log('✅ Cleared existing locations');

    // Insert locations
    let inserted = 0;
    let skipped = 0;

    for (const location of banadirLocations) {
      const existing = await Location.findOne({
        region: location.region,
        district: location.district,
        sector: location.sector,
      });

      if (!existing) {
        await Location.create({
          ...location,
          isActive: true,
        });
        inserted++;
        console.log(`✅ Inserted: ${location.region} → ${location.district} → ${location.sector}`);
      } else {
        skipped++;
        console.log(`⏭️  Skipped (exists): ${location.region} → ${location.district} → ${location.sector}`);
      }
    }

    console.log('\n📊 Summary:');
    console.log(`   Inserted: ${inserted}`);
    console.log(`   Skipped: ${skipped}`);
    console.log(`   Total: ${banadirLocations.length}`);

    await mongoose.connection.close();
    console.log('\n✅ Seeding completed successfully');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding locations:', error);
    await mongoose.connection.close();
    process.exit(1);
  }
}

// Run seed
seedLocations();

