import mongoose from 'mongoose';

const { Schema } = mongoose;

const CITIZEN_STATUS = ['ACTIVE', 'DECEASED'];

const citizenSchema = new Schema(
  {
    nationalId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },
    fullName: {
      type: String,
      required: true,
      trim: true,
    },
    dateOfBirth: {
      type: String,
      trim: true,
    },
    gender: {
      type: String,
      trim: true,
    },
    nationality: {
      type: String,
      trim: true,
      default: 'Somali',
    },
    status: {
      type: String,
      enum: CITIZEN_STATUS,
      default: 'ACTIVE',
    },
  },
  {
    timestamps: true,
  },
);

export default mongoose.model('Citizen', citizenSchema);

