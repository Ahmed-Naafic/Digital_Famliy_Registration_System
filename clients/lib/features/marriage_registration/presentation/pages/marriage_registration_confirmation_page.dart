import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/uploaded_document.dart';
import '../../../../core/services/application_service.dart';
import '../../../../features/auth/auth_provider.dart';
import '../../../../features/application_status/data/application_model.dart';
import '../provider/marriage_form_provider.dart';

/// Marriage Registration Confirmation Page
class MarriageRegistrationConfirmationPage extends StatelessWidget {
  const MarriageRegistrationConfirmationPage({super.key});

  void _onEditStep(
    BuildContext context,
    MarriageFormProvider provider,
    int step,
  ) {
    provider.updateCurrentStep(step);
    Navigator.pop(context);
  }

  Future<void> _handleSubmit(
    BuildContext context,
    MarriageFormProvider provider,
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
        'husbandNationalId': provider.husbandNationalId,
        'husbandDateOfBirth': provider.husbandDateOfBirth?.toIso8601String(),
        'wifeName': provider.wifeName,
        'wifeNationalId': provider.wifeNationalId,
        'wifeDateOfBirth': provider.wifeDateOfBirth?.toIso8601String(),
        'marriageDate': provider.marriageDate?.toIso8601String(),
        'location': provider.location,
        'witness1': provider.witness1,
        'witness2': provider.witness2,
        'documents': provider.documents.map((doc) => doc.toJson()).toList(),
      };

      await applicationService.submitApplication(
        user: user,
        type: ApplicationType.marriage,
        formData: formData,
      );

      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Submitted'),
            content: const Text(
              'Your marriage registration has been submitted successfully. You will be notified once it is processed.',
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
    return Consumer<MarriageFormProvider>(
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

                // Husband Details
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person, color: colorScheme.primary),
                        title: Text(
                          'Husband Details',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () => _onEditStep(context, provider, 0),
                          child: const Text('Edit Husband Details'),
                        ),
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        context,
                        'Name',
                        provider.husbandName ?? '',
                      ),
                      if (provider.husbandDateOfBirth != null)
                        _buildInfoTile(
                          context,
                          'Date of Birth',
                          DateFormat(
                            'yyyy-MM-dd',
                          ).format(provider.husbandDateOfBirth!),
                        ),
                      if (provider.husbandNationalId != null &&
                          provider.husbandNationalId!.isNotEmpty)
                        _buildInfoTile(
                          context,
                          'National ID',
                          provider.husbandNationalId!,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Wife Details
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person, color: colorScheme.primary),
                        title: Text(
                          'Wife Details',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () => _onEditStep(context, provider, 1),
                          child: const Text('Edit Wife & Marriage Details'),
                        ),
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(context, 'Name', provider.wifeName ?? ''),
                      if (provider.wifeDateOfBirth != null)
                        _buildInfoTile(
                          context,
                          'Date of Birth',
                          DateFormat(
                            'yyyy-MM-dd',
                          ).format(provider.wifeDateOfBirth!),
                        ),
                      if (provider.wifeNationalId != null &&
                          provider.wifeNationalId!.isNotEmpty)
                        _buildInfoTile(
                          context,
                          'National ID',
                          provider.wifeNationalId!,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Marriage Details
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.favorite,
                          color: colorScheme.primary,
                        ),
                        title: Text(
                          'Marriage Details',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () => _onEditStep(context, provider, 1),
                          child: const Text('Edit Marriage Details'),
                        ),
                      ),
                      const Divider(height: 1),
                      if (provider.marriageDate != null)
                        _buildInfoTile(
                          context,
                          'Marriage Date',
                          DateFormat(
                            'yyyy-MM-dd',
                          ).format(provider.marriageDate!),
                        ),
                      _buildInfoTile(
                        context,
                        'Location',
                        provider.location ?? '',
                      ),
                      _buildInfoTile(
                        context,
                        'Witness 1',
                        provider.witness1 ?? '',
                      ),
                      _buildInfoTile(
                        context,
                        'Witness 2',
                        provider.witness2 ?? '',
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
