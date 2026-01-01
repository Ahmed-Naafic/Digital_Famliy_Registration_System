/**
 * Application-related utilities
 */

/**
 * Normalize document metadata from uploaded files
 * @param {Array} files - Array of multer file objects
 * @returns {Array} Array of document metadata objects
 */
export const normalizeDocuments = (files = []) => {
  return files.map((file) => ({
    fileName: file.originalname,
    fileType: file.mimetype,
    filePath: file.path,
    uploadedAt: new Date(),
  }));
};




