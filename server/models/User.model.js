import mongoose from 'mongoose';

const { Schema } = mongoose;

const USER_ROLES = ['citizen', 'admin'];
const USER_STATUS = ['active', 'suspended'];

const userSchema = new Schema(
  {
    fullName: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    phoneNumber: {
      type: String,
      trim: true,
    },
    passwordHash: {
      type: String,
      required: true,
    },
    role: {
      type: String,
      enum: USER_ROLES,
      default: 'citizen',
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
    status: {
      type: String,
      enum: USER_STATUS,
      default: 'active',
    },
  },
  {
    timestamps: true,
  },
);

export default mongoose.model('User', userSchema);


