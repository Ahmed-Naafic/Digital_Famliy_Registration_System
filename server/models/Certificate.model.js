import mongoose from 'mongoose';

const { Schema } = mongoose;

const CERTIFICATE_TYPES = ['birth', 'marriage', 'divorce', 'death'];
const CERTIFICATE_STATUS = ['valid', 'revoked'];

const certificateSchema = new Schema(
  {
    applicationId: {
      type: Schema.Types.ObjectId,
      ref: 'Application',
      required: true,
    },
    certificateNumber: {
      type: String,
      unique: true,
      required: true,
      trim: true,
    },
    type: {
      type: String,
      enum: CERTIFICATE_TYPES,
    },
    issuedTo: [
      {
        type: Schema.Types.ObjectId,
        // CRVS model: no FamilyMember reference
      },
    ],
    issueDate: {
      type: Date,
    },
    issuedBy: {
      type: Schema.Types.ObjectId,
      ref: 'User',
    },
    filePath: {
      type: String,
      trim: true,
    },
    status: {
      type: String,
      enum: CERTIFICATE_STATUS,
      default: 'valid',
    },
  },
  {
    timestamps: true,
  },
);

export default mongoose.model('Certificate', certificateSchema);





