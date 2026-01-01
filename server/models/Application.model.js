import mongoose from 'mongoose';

const { Schema } = mongoose;

const APPLICATION_TYPES = ['birth', 'marriage', 'divorce', 'death'];
const APPLICATION_STATUS = ['pending', 'approved', 'rejected'];

const documentSubSchema = new Schema(
  {
    fileName: {
      type: String,
      required: true,
      trim: true,
    },
    fileType: {
      type: String,
      trim: true,
    },
    filePath: {
      type: String,
      required: true,
      trim: true,
    },
    uploadedAt: {
      type: Date,
      default: Date.now,
    },
  },
  { _id: false },
);

const applicationSchema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    applicationType: {
      type: String,
      enum: ['BIRTH', 'MARRIAGE', 'DIVORCE'],
      default: 'BIRTH',
    },
    type: {
      type: String,
      enum: APPLICATION_TYPES,
      required: true,
    },
    payload: {
      type: Schema.Types.Mixed,
      required: true,
    },
    documents: [documentSubSchema],
    status: {
      type: String,
      enum: APPLICATION_STATUS,
      default: 'pending',
    },
    adminComment: {
      type: String,
      trim: true,
    },
    reviewedBy: {
      type: Schema.Types.ObjectId,
      ref: 'User',
    },
    reviewedAt: {
      type: Date,
    },
    certificateId: {
      type: Schema.Types.ObjectId,
      ref: 'Certificate',
    },
  },
  {
    timestamps: true,
  },
);

export default mongoose.model('Application', applicationSchema);





