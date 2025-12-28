import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/uploaded_document.dart';
import '../../../../features/auth/auth_provider.dart';
import '../../../../features/applications/data/application_service.dart';
import '../provider/birth_form_provider.dart';

/// Birth Registration Confirmation Page
/// Displays summary and allows submission
class BirthRegistrationConfirmationPage extends StatelessWidget {
  const BirthRegistrationConfirmationPage({super.key});

  void _onEditStep(BuildContext context, BirthFormProvider provider, int step) {
    provider.updateCurrentStep(step);
    Navigator.pop(context);
  }

  Future<void> _handleSubmit(
    BuildContext context,
    BirthFormProvider provider,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final applicationService = const ApplicationService();
    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit applications')),
      );
      return;
    }

    // Validate that all required data is present
    if (!provider.isFormComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      debugPrint('=== BIRTH SUBMISSION STARTED ===');
      
      // Build complete payload from provider
      final payload = provider.buildPayload();
      debugPrint('Payload built: $payload');
      
      // Get actual File objects from documents
      final documentFiles = provider.documents
          .map((doc) => doc.file)
          .where((file) => file.existsSync())
          .toList();
      debugPrint('Document files: ${documentFiles.length}');

      // Submit Birth application to backend with files
      debugPrint('Calling applicationService.submitBirthApplication...');
      await applicationService.submitBirthApplication(
        applicantNationalId: provider.applicantNationalId!,
        child: payload['child'] as Map<String, dynamic>,
        fatherNationalId: provider.fatherNationalId!,
        motherNationalId: provider.motherNationalId!,
        fatherResidence: payload['fatherResidence'] as Map<String, dynamic>,
        motherResidence: payload['motherResidence'] as Map<String, dynamic>,
        token: token,
        documents: documentFiles,
      );
      debugPrint('=== BIRTH SUBMISSION SUCCESS ===');

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Submitted'),
            content: const Text(
              'Your birth registration has been submitted successfully. You will be notified once it is processed.',
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
    } catch (e, stackTrace) {
      debugPrint('=== BIRTH SUBMISSION ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting application: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BirthFormProvider>(
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

                // Child Details Card
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.child_care,
                          color: colorScheme.primary,
                        ),
                        title: Text(
                          'Child Details',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () => _onEditStep(context, provider, 0),
                          child: const Text('Edit Main Details'),
                        ),
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(context, 'Name', provider.childName ?? ''),
                      _buildInfoTile(
                        context,
                        'Date of Birth',
                        provider.dateOfBirth != null
                            ? DateFormat(
                                'yyyy-MM-dd',
                              ).format(provider.dateOfBirth!)
                            : '',
                      ),
                      _buildInfoTile(
                        context,
                        'Place of Birth',
                        provider.placeOfBirth ?? '',
                      ),
                      _buildInfoTile(context, 'Gender', provider.gender ?? ''),
                      _buildInfoTile(
                        context,
                        'Nationality',
                        provider.nationality ?? '',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Applicant Details Card
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person, color: colorScheme.primary),
                        title: Text(
                          'Applicant Details',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () => _onEditStep(context, provider, 0),
                          child: const Text('Edit'),
                        ),
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        context,
                        'National ID',
                        provider.applicantNationalId ?? '',
                      ),
                      if (provider.applicantIdentity != null)
                        _buildInfoTile(
                          context,
                          'Full Name',
                          provider.applicantIdentity!.fullName,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Parent Details Card
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.people, color: colorScheme.primary),
                        title: Text(
                          'Parent Details',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () => _onEditStep(context, provider, 1),
                          child: const Text('Edit Parent Details'),
                        ),
                      ),
                      const Divider(height: 1),
                      if (provider.fatherIdentity != null)
                        _buildInfoTile(
                          context,
                          'Father\'s Name',
                          provider.fatherIdentity!.fullName,
                        ),
                      _buildInfoTile(
                        context,
                        'Father National ID',
                        provider.fatherNationalId ?? '',
                      ),
                      _buildInfoTile(
                        context,
                        'Father District',
                        provider.fatherDistrict ?? '',
                      ),
                      _buildInfoTile(
                        context,
                        'Father Sector',
                        provider.fatherSector ?? '',
                      ),
                      const Divider(height: 1),
                      if (provider.motherIdentity != null)
                        _buildInfoTile(
                          context,
                          'Mother\'s Name',
                          provider.motherIdentity!.fullName,
                        ),
                      _buildInfoTile(
                        context,
                        'Mother National ID',
                        provider.motherNationalId ?? '',
                      ),
                      _buildInfoTile(
                        context,
                        'Mother District',
                        provider.motherDistrict ?? '',
                      ),
                      _buildInfoTile(
                        context,
                        'Mother Sector',
                        provider.motherSector ?? '',
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
