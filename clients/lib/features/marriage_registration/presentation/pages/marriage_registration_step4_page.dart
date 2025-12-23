import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/document_upload_widget.dart';
import '../provider/marriage_form_provider.dart';

/// Marriage Registration Step 4: Marriage Details & Document Upload
class MarriageRegistrationStep4Page extends StatelessWidget {
  const MarriageRegistrationStep4Page({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<MarriageFormProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Marriage Details Section
          Text(
            'Marriage Details',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide marriage date and location',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FormBuilder(
                child: Column(
                  children: [
                    FormBuilderDateTimePicker(
                      name: 'marriageDate',
                      initialValue: provider.marriageDate,
                      decoration: InputDecoration(
                        labelText: 'Marriage Date *',
                        hintText: 'Select marriage date',
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      validator: FormBuilderValidators.required(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateMarriageDate(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'location',
                      initialValue: provider.location,
                      decoration: InputDecoration(
                        labelText: 'Marriage Location *',
                        hintText: 'Enter location',
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      validator: FormBuilderValidators.required(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateLocation(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Documents Section
          Text(
            'Required Documents',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please upload the required documents for marriage registration',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          DocumentUploadWidget(
            title: 'Upload Required Documents',
            requiredDocuments: [
              'National ID (Husband)',
              'National ID (Wife)',
              'Birth Certificates (Both)',
              'Witness IDs',
            ],
            initialDocuments: provider.documents,
            onChanged: (documents) {
              provider.updateDocuments(documents);
            },
          ),

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


