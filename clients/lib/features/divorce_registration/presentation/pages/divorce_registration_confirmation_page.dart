import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/uploaded_document.dart';
import '../../../../core/services/application_service.dart';
import '../../../../features/auth/auth_provider.dart';
import '../../../../features/application_status/data/application_model.dart';
import '../provider/divorce_form_provider.dart';

/// Divorce Registration Confirmation Page
class DivorceRegistrationConfirmationPage extends StatelessWidget {
  const DivorceRegistrationConfirmationPage({super.key});

  void _onEditStep(
    BuildContext context,
    DivorceFormProvider provider,
    int step,
  ) {
    provider.updateCurrentStep(step);
    Navigator.pop(context);
  }

  Future<void> _handleSubmit(
    BuildContext context,
    DivorceFormProvider provider,
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
        'husbandName': provider.husbandName,
        'wifeName': provider.wifeName,
        'divorceDate': provider.divorceDate?.toIso8601String(),
        'reason': provider.reason,
        'documents': provider.documents.map((doc) => doc.toJson()).toList(),
      };

      await applicationService.submitApplication(
        user: user,
        type: ApplicationType.divorce,
        formData: formData,
      );

      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Submitted'),
            content: const Text(
              'Your divorce registration has been submitted successfully. You will be notified once it is processed.',
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
    return Consumer<DivorceFormProvider>(
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

                // Couple Details
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.heart_broken,
                          color: colorScheme.primary,
                        ),
                        title: Text(
                          'Couple Details',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () => _onEditStep(context, provider, 0),
                          child: const Text('Edit Couple Details'),
                        ),
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        context,
                        'Husband',
                        provider.husbandName ?? '',
                      ),
                      _buildInfoTile(context, 'Wife', provider.wifeName ?? ''),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Divorce Details
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.description,
                          color: colorScheme.primary,
                        ),
                        title: Text(
                          'Divorce Details',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () => _onEditStep(context, provider, 0),
                          child: const Text('Edit Couple Details'),
                        ),
                      ),
                      const Divider(height: 1),
                      if (provider.divorceDate != null)
                        _buildInfoTile(
                          context,
                          'Divorce Date',
                          DateFormat(
                            'yyyy-MM-dd',
                          ).format(provider.divorceDate!),
                        ),
                      _buildInfoTile(context, 'Reason', provider.reason ?? ''),
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
