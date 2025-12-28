import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/auth_provider.dart';
import '../provider/marriage_form_provider.dart';

/// Marriage Registration Step 1: Groom Details (using National ID)
class MarriageRegistrationStep1Page extends StatefulWidget {
  const MarriageRegistrationStep1Page({super.key});

  @override
  State<MarriageRegistrationStep1Page> createState() =>
      _MarriageRegistrationStep1PageState();
}

class _MarriageRegistrationStep1PageState
    extends State<MarriageRegistrationStep1Page> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _groomIdController = TextEditingController();

  @override
  void dispose() {
    _groomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<MarriageFormProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Sync controller with provider value
    if (provider.groomNationalId != null &&
        _groomIdController.text != provider.groomNationalId) {
      _groomIdController.text = provider.groomNationalId!;
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
                      'Enter groom\'s National ID to verify identity via NIRA. Groom must be MALE.',
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
            'Groom Information',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Groom details (must be male)',
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
                      name: 'groomNationalId',
                      controller: _groomIdController,
                      decoration: InputDecoration(
                        labelText: 'Groom National ID *',
                        hintText: 'Enter groom\'s National ID',
                        prefixIcon: const Icon(Icons.badge),
                        suffixIcon: provider.isLoadingGroom
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : provider.groomIdentity != null
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : null,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      onChanged: (value) {
                        provider.updateGroomNationalId(value);
                        if (value != null && value.length >= 9) {
                          final token = authProvider.token;
                          if (token != null && token.isNotEmpty) {
                            provider.fetchGroomIdentity(token);
                          }
                        }
                      },
                    ),
                    if (provider.groomError != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.groomError!,
                                style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (provider.groomIdentity != null) ...[
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
                              provider.groomIdentity!.fullName,
                            ),
                            if (provider.groomIdentity!.dateOfBirth != null)
                              _buildReadOnlyField(
                                context,
                                'Date of Birth',
                                provider.groomIdentity!.dateOfBirth!,
                              ),
                            if (provider.groomIdentity!.gender != null)
                              _buildReadOnlyField(
                                context,
                                'Gender',
                                provider.groomIdentity!.gender!.toUpperCase(),
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
