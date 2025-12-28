# NIRA Mock Server

A standalone mock server that simulates Somalia's National Identification and Registration Authority (NIRA) for development and testing purposes.

## Overview

This server provides identity verification services that can be consumed by CRVS (Civil Registration and Vital Statistics) systems. It is a **separate, independent backend** that runs on its own port and database.

## Tech Stack

- **Node.js** - Runtime environment
- **Express** - Web framework
- **MongoDB** - Database (via Mongoose)
- **dotenv** - Environment variable management

## Installation

1. Install dependencies:
```bash
npm install
```

2. Set up environment variables:
   - Copy `.env` file (already created)
   - Update `MONGO_URI` if needed (default: `mongodb://localhost:27017/nira_mock`)

3. Start the server:
```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

The server will run on **port 4000** by default.

## API Endpoints

### Get Citizen by National ID

**GET** `/api/citizens/:nationalId`

**Example:**
```bash
GET http://localhost:4000/api/citizens/123456789
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "nationalId": "123456789",
    "fullName": "Ahmed Mohamed Ali",
    "dateOfBirth": "1985-06-20",
    "gender": "MALE",
    "nationality": "Somali",
    "status": "ACTIVE"
  }
}
```

**Not Found Response (404):**
```json
{
  "success": false,
  "message": "Citizen with National ID 123456789 not found"
}
```

## Setting Up Test Data

### Option 1: Using MongoDB Shell

1. Connect to MongoDB:
```bash
mongosh mongodb://localhost:27017/nira_mock
```

2. Insert test citizens:
```javascript
db.citizens.insertMany([
  {
    nationalId: "123456789",
    fullName: "Ahmed Mohamed Ali",
    dateOfBirth: "1985-06-20",
    gender: "MALE",
    nationality: "Somali",
    status: "ACTIVE"
  },
  {
    nationalId: "987654321",
    fullName: "Amina Yusuf Hassan",
    dateOfBirth: "1990-09-12",
    gender: "FEMALE",
    nationality: "Somali",
    status: "ACTIVE"
  },
  {
    nationalId: "555555555",
    fullName: "Hassan Abdi Mohamed",
    dateOfBirth: "1978-03-15",
    gender: "MALE",
    nationality: "Somali",
    status: "ACTIVE"
  },
  {
    nationalId: "111111111",
    fullName: "Fatima Ali Ibrahim",
    dateOfBirth: "1992-11-08",
    gender: "FEMALE",
    nationality: "Somali",
    status: "ACTIVE"
  }
]);
```

### Option 2: Using MongoDB Compass

1. Open MongoDB Compass
2. Connect to `mongodb://localhost:27017`
3. Select database `nira_mock`
4. Create collection `citizens`
5. Insert documents using the JSON examples above

### Option 3: Using a Script (Optional)

You can create a script file `scripts/seed.js`:

```javascript
import dotenv from 'dotenv';
import { connectDB } from '../src/config/db.js';
import Citizen from '../src/models/Citizen.model.js';

dotenv.config();

const seedCitizens = async () => {
  try {
    await connectDB();
    
    const citizens = [
      {
        nationalId: "123456789",
        fullName: "Ahmed Mohamed Ali",
        dateOfBirth: "1985-06-20",
        gender: "MALE",
        nationality: "Somali",
        status: "ACTIVE"
      },
      {
        nationalId: "987654321",
        fullName: "Amina Yusuf Hassan",
        dateOfBirth: "1990-09-12",
        gender: "FEMALE",
        nationality: "Somali",
        status: "ACTIVE"
      }
    ];

    await Citizen.insertMany(citizens);
    console.log('✓ Test citizens inserted successfully');
    process.exit(0);
  } catch (error) {
    console.error('✗ Error seeding data:', error);
    process.exit(1);
  }
};

seedCitizens();
```

Then run:
```bash
node scripts/seed.js
```

## Integration with CRVS Backend

To use this NIRA mock server with your CRVS backend:

1. Update CRVS `.env` file:
```env
NIRA_API_URL=http://localhost:4000
NIRA_API_TOKEN=optional_token_if_needed
```

2. The CRVS backend's `nira.service.js` will call:
   - `GET http://localhost:4000/api/citizens/:nationalId`

## Project Structure

```
nira_mock_server/
├── src/
│   ├── models/
│   │   └── Citizen.model.js          # Citizen schema
│   ├── controllers/
│   │   └── citizen.controller.js    # Request handlers
│   ├── routes/
│   │   └── citizen.routes.js        # API routes
│   ├── services/
│   │   └── citizen.service.js       # Business logic
│   ├── config/
│   │   └── db.js                    # Database connection
│   ├── app.js                       # Express app setup
│   └── server.js                    # Server entry point
├── .env                             # Environment variables
├── package.json                     # Dependencies
└── README.md                        # This file
```

## Notes

- This is a **mock server** for development/testing only
- No authentication is implemented (can be added if needed)
- The server runs independently from CRVS backend
- Uses a separate MongoDB database (`nira_mock`)
- Simulates real NIRA API behavior for integration testing

## License

ISC

