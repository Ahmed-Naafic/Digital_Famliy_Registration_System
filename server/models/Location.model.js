import mongoose from 'mongoose';

const { Schema } = mongoose;

const locationSchema = new Schema(
  {
    region: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    district: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    sector: {
      type: String,
      required: true,
      trim: true,
    },
    isActive: {
      type: Boolean,
      default: true,
      index: true,
    },
  },
  {
    timestamps: true,
  },
);

// Compound index for efficient queries
locationSchema.index({ region: 1, district: 1, isActive: 1 });
locationSchema.index({ district: 1, isActive: 1 });

export default mongoose.model('Location', locationSchema);


