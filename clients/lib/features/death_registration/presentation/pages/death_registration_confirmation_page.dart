import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/uploaded_document.dart';
import '../../../../core/services/application_service.dart';
import '../../../../features/auth/auth_provider.dart';
import '../../../../features/application_status/data/application_model.dart';
import '../provider/death_form_provider.dart';

/// Death Registration Confirmation Page
class DeathRegistrationConfirmationPage extends StatelessWidget {
  const DeathRegistrationConfirmationPage({super.key});

  void _onEditStep(BuildContext context, DeathFormProvider provider, int step) {
    provider.updateCurrentStep(step);
    Navigator.pop(context);
  }

  Future<void> _handleSubmit(
    BuildContext context,
    DeathFormProvider provider,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final applicationService = Provider.of<ApplicationService>(
      context,
      listen: false,
    );
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit applications')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final formData = {
        'deceasedName': provider.deceasedName,
        'dateOfDeath': provider.dateOfDeath?.toIso8601String(),
        'placeOfDeath': provider.placeOfDeath,
        'causeOfDeath': provider.causeOfDeath,
        'reporterName': provider.reporterName,
        'reporterRelationship': provider.reporterRelationship,
        'reporterContact': provider.reporterContact,
        'documents': provider.documents.map((doc) => doc.toJson()).toList(),
      };

      await applicationService.submitApplication(
        user: user,
        type: ApplicationType.death,
        formData: formData,
      );

      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Submitted'),
            content: const Text(
              'The death registration has been submitted successfully. You will be notified once it is processed.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  provider.reset();
                  context.go('/dashboard');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting application: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeathFormProvider>(
      builder: (context, provider, child) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Review & Submit'),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Review Your Information',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please review all details before submitting',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),

                // Deceased Details
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person, color: colorScheme.primary),
                        title: Text(
                          'Deceased Details',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () => _onEditStep(context, provider, 0),
                          child: const Text('Edit Deceased Details'),
                        ),
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        context,
                        'Name',
                        provider.deceasedName ?? '',
                      ),
                      if (provider.dateOfDeath != null)
                        _buildInfoTile(
                          context,
                          'Date of Death',
                          DateFormat(
                            'yyyy-MM-dd',
                          ).format(provider.dateOfDeath!),
                        ),
                      _buildInfoTile(
                        context,
                        'Place of Death',
                        provider.placeOfDeath ?? '',
                      ),
                      _buildInfoTile(
                        context,
                        'Cause of Death',
                        provider.causeOfDeath ?? '',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Reporter Details
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.contact_page,
                          color: colorScheme.primary,
                        ),
                        title: Text(
                          'Reporter Details',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () => _onEditStep(context, provider, 1),
                          child: const Text('Edit Reporter Details'),
                        ),
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        context,
                        'Reporter Name',
                        provider.reporterName ?? '',
                      ),
                      _buildInfoTile(
                        context,
                        'Relationship',
                        provider.reporterRelationship ?? '',
                      ),
                      if (provider.reporterContact != null &&
                          provider.reporterContact!.isNotEmpty)
                        _buildInfoTile(
                          context,
                          'Contact',
                          provider.reporterContact!,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Documents Card
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.attach_file,
                          color: colorScheme.primary,
                        ),
                        title: Text(
                          'Uploaded Documents',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () => _onEditStep(context, provider, 2),
                          child: const Text('Edit Documents'),
                        ),
                      ),
                      const Divider(height: 1),
                      if (provider.documents.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No documents uploaded',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.5),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        ...provider.documents.map(
                          (doc) => _buildDocumentTile(context, doc),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: provider.isFormComplete
                          ? () => _handleSubmit(context, provider)
                          : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit Registration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentTile(BuildContext context, UploadedDocument doc) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: doc.isPdf
              ? Colors.red.withOpacity(0.1)
              : colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          doc.isPdf ? Icons.picture_as_pdf : Icons.image,
          color: doc.isPdf ? Colors.red : colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(doc.name, style: textTheme.bodyMedium),
      subtitle: Text(
        '${doc.fileType.toUpperCase()} • ${doc.fileSizeKB.toStringAsFixed(1)} KB',
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      dense: true,
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      title: Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      subtitle: Text(value, style: textTheme.bodyMedium),
      dense: true,
    );
  }
}
