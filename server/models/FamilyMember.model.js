import mongoose from 'mongoose';

const { Schema } = mongoose;

const GENDERS = ['male', 'female'];
const MARITAL_STATUSES = ['single', 'married', 'divorced'];
const LIFE_STATUS = ['alive', 'deceased'];

const familyMemberSchema = new Schema(
  {
    familyId: {
      type: Schema.Types.ObjectId,
      ref: 'Family',
      required: true,
    },
    firstName: {
      type: String,
      required: true,
      trim: true,
    },
    lastName: {
      type: String,
      required: true,
      trim: true,
    },
    gender: {
      type: String,
      enum: GENDERS,
    },
    dateOfBirth: {
      type: Date,
    },
    placeOfBirth: {
      type: String,
      trim: true,
    },
    fatherId: {
      type: Schema.Types.ObjectId,
      ref: 'FamilyMember',
    },
    motherId: {
      type: Schema.Types.ObjectId,
      ref: 'FamilyMember',
    },
    maritalStatus: {
      type: String,
      enum: MARITAL_STATUSES,
    },
    spouseId: {
      type: Schema.Types.ObjectId,
      ref: 'FamilyMember',
    },
    nationalIdNumber: {
      type: String,
      trim: true,
    },
    status: {
      type: String,
      enum: LIFE_STATUS,
      default: 'alive',
    },
    createdFromApplicationId: {
      type: Schema.Types.ObjectId,
      ref: 'Application',
    },
  },
  {
    timestamps: true,
  },
);

export default mongoose.model('FamilyMember', familyMemberSchema);





