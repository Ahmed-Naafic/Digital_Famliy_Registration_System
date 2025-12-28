import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/auth_provider.dart';
import '../provider/marriage_form_provider.dart';

/// Marriage Registration Step 0: Applicant Details (using National ID)
class MarriageRegistrationStep0Page extends StatefulWidget {
  const MarriageRegistrationStep0Page({super.key});

  @override
  State<MarriageRegistrationStep0Page> createState() =>
      _MarriageRegistrationStep0PageState();
}

class _MarriageRegistrationStep0PageState
    extends State<MarriageRegistrationStep0Page> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _applicantIdController = TextEditingController();

  @override
  void dispose() {
    _applicantIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<MarriageFormProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Sync controller with provider value
    if (provider.applicantNationalId != null &&
        _applicantIdController.text != provider.applicantNationalId) {
      _applicantIdController.text = provider.applicantNationalId!;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            color: Colors.blue.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter your National ID to verify your identity via NIRA.',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section Header
          Text(
            'Applicant Information',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your details as the applicant',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Form Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'applicantNationalId',
                      controller: _applicantIdController,
                      decoration: InputDecoration(
                        labelText: 'Applicant National ID *',
                        hintText: 'Enter your National ID',
                        prefixIcon: const Icon(Icons.badge),
                        suffixIcon: provider.isLoadingApplicant
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : provider.applicantIdentity != null
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : null,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      onChanged: (value) {
                        provider.updateApplicantNationalId(value);
                        if (value != null && value.length >= 9) {
                          final token = authProvider.token;
                          if (token != null && token.isNotEmpty) {
                            provider.fetchApplicantIdentity(token);
                          }
                        }
                      },
                    ),
                    if (provider.applicantError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        provider.applicantError!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                    if (provider.applicantIdentity != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verified Identity (Read-only)',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildReadOnlyField(
                              context,
                              'Full Name',
                              provider.applicantIdentity!.fullName,
                            ),
                            if (provider.applicantIdentity!.dateOfBirth != null)
                              _buildReadOnlyField(
                                context,
                                'Date of Birth',
                                provider.applicantIdentity!.dateOfBirth!,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

