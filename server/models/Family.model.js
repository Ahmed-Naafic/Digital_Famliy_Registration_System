import mongoose from 'mongoose';

const { Schema } = mongoose;

const FAMILY_STATUS = ['active', 'archived'];

const familySchema = new Schema(
  {
    familyName: {
      type: String,
      required: true,
      trim: true,
    },
    familyNumber: {
      type: String,
      unique: true,
      sparse: true,
      trim: true,
    },
    headOfFamilyId: {
      type: Schema.Types.ObjectId,
      ref: 'FamilyMember',
    },
    linkedUsers: [
      {
        type: Schema.Types.ObjectId,
        ref: 'User',
      },
    ],
    address: {
      type: String,
      trim: true,
    },
    status: {
      type: String,
      enum: FAMILY_STATUS,
      default: 'active',
    },
  },
  {
    timestamps: true,
  },
);

export default mongoose.model('Family', familySchema);





