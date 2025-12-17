import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/uploaded_document.dart';

/// Document Upload Widget
/// Reusable widget for uploading documents in registration forms
/// Supports both images and PDF files
class DocumentUploadWidget extends StatefulWidget {
  /// Title of the document upload section
  final String title;

  /// List of required document types
  final List<String> requiredDocuments;

  /// Callback when documents change
  final Function(List<UploadedDocument>) onChanged;

  /// Initial documents (for editing)
  final List<UploadedDocument>? initialDocuments;

  const DocumentUploadWidget({
    super.key,
    required this.title,
    required this.requiredDocuments,
    required this.onChanged,
    this.initialDocuments,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  final List<UploadedDocument> _documents = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialDocuments != null) {
      _documents.addAll(widget.initialDocuments!);
    }
  }

  Future<void> _pickFile() async {
    try {
      // Show dialog to choose between camera, gallery, or file picker
      final source = await showDialog<FileSource?>(
        context: context,
        builder: (context) => _SourceSelectionDialog(),
      );

      if (source == null) return;

      PlatformFile? pickedFile;

      if (source == FileSource.camera) {
        // Pick image from camera
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (image != null) {
          pickedFile = PlatformFile(
            name: image.name,
            path: image.path,
            size: await image.length(),
          );
        }
      } else if (source == FileSource.gallery) {
        // Pick image from gallery
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (image != null) {
          pickedFile = PlatformFile(
            name: image.name,
            path: image.path,
            size: await image.length(),
          );
        }
      } else {
        // Pick file (PDF or images)
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif'],
          allowMultiple: false,
        );

        if (result != null && result.files.single.path != null) {
          pickedFile = result.files.single;
        }
      }

      if (pickedFile != null && pickedFile.path != null) {
        final file = File(pickedFile.path!);
        final extension = pickedFile.extension ?? 'unknown';
        final fileName = pickedFile.name;

        final document = UploadedDocument(
          name: fileName,
          file: file,
          fileType: extension.toLowerCase(),
        );

        setState(() {
          _documents.add(document);
        });

        widget.onChanged(_documents);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _documents.removeAt(index);
    });
    widget.onChanged(_documents);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Required documents list
            if (widget.requiredDocuments.isNotEmpty) ...[
              Text(
                'Required: ${widget.requiredDocuments.join(', ')}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Upload button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Document'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Documents list
            if (_documents.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Uploaded Documents (${_documents.length})',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(_documents.length, (index) {
                final doc = _documents[index];
                return _DocumentItem(
                  document: doc,
                  onRemove: () => _removeDocument(index),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

/// Source Selection Dialog
enum FileSource { camera, gallery, file }

class _SourceSelectionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Select Source'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt, color: colorScheme.primary),
            title: const Text('Camera'),
            onTap: () => Navigator.pop(context, FileSource.camera),
          ),
          ListTile(
            leading: Icon(Icons.photo_library, color: colorScheme.primary),
            title: const Text('Gallery'),
            onTap: () => Navigator.pop(context, FileSource.gallery),
          ),
          ListTile(
            leading: Icon(Icons.insert_drive_file, color: colorScheme.primary),
            title: const Text('File Picker'),
            onTap: () => Navigator.pop(context, FileSource.file),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Document Item Widget
class _DocumentItem extends StatelessWidget {
  final UploadedDocument document;
  final VoidCallback onRemove;

  const _DocumentItem({
    required this.document,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: document.isPdf
                ? Colors.red.withOpacity(0.1)
                : colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            document.isPdf ? Icons.picture_as_pdf : Icons.image,
            color: document.isPdf ? Colors.red : colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          document.name,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${document.fileType.toUpperCase()} • ${document.fileSizeKB.toStringAsFixed(1)} KB',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: colorScheme.error,
          onPressed: onRemove,
        ),
      ),
    );
  }
}


