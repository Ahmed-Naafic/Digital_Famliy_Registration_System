import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/document_upload_widget.dart';
import '../provider/birth_form_provider.dart';

/// Birth Registration Step 3: Document Upload
class BirthRegistrationStep3Page extends StatelessWidget {
  const BirthRegistrationStep3Page({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<BirthFormProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            'Required Documents',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please upload the required documents for birth registration',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Document Upload Widget
          DocumentUploadWidget(
            title: 'Upload Required Documents',
            requiredDocuments: [
              'National ID (Father)',
              'National ID (Mother)',
              'Hospital Birth Letter',
              'Marriage Certificate',
            ],
            initialDocuments: provider.documents,
            onChanged: (documents) {
              provider.updateDocuments(documents);
            },
          ),

          // Validation message
          if (provider.documents.isEmpty) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please upload at least one required document to proceed.',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


