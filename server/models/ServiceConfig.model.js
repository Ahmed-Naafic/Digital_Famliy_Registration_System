import mongoose from 'mongoose';

const { Schema } = mongoose;

const SERVICE_TYPES = ['birth', 'marriage', 'divorce', 'death'];

const serviceConfigSchema = new Schema(
  {
    serviceType: {
      type: String,
      enum: SERVICE_TYPES,
      required: true,
      unique: true,
    },
    enabled: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  },
);

export default mongoose.model('ServiceConfig', serviceConfigSchema);



