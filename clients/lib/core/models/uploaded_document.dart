import 'dart:io';

/// Uploaded Document Model
/// Represents a document uploaded by the user
class UploadedDocument {
  /// Display name of the document
  final String name;

  /// The actual file
  final File file;

  /// File type (e.g., 'pdf', 'jpg', 'png')
  final String fileType;

  /// Document type/description (e.g., "National ID", "Birth Certificate")
  final String? documentType;

  UploadedDocument({
    required this.name,
    required this.file,
    required this.fileType,
    this.documentType,
  });

  /// Check if the document is a PDF
  bool get isPdf => fileType.toLowerCase() == 'pdf';

  /// Check if the document is an image
  bool get isImage =>
      fileType.toLowerCase() == 'jpg' ||
      fileType.toLowerCase() == 'jpeg' ||
      fileType.toLowerCase() == 'png' ||
      fileType.toLowerCase() == 'gif';

  /// Get file size in KB
  double get fileSizeKB => file.lengthSync() / 1024;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fileType': fileType,
      'documentType': documentType,
      'filePath': file.path,
      'fileSizeKB': fileSizeKB,
    };
  }
}


