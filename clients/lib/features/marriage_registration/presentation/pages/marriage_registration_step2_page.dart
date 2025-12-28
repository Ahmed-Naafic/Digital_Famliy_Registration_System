import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/auth_provider.dart';
import '../provider/marriage_form_provider.dart';

/// Marriage Registration Step 2: Bride Details (using National ID)
class MarriageRegistrationStep2Page extends StatefulWidget {
  const MarriageRegistrationStep2Page({super.key});

  @override
  State<MarriageRegistrationStep2Page> createState() =>
      _MarriageRegistrationStep2PageState();
}

class _MarriageRegistrationStep2PageState
    extends State<MarriageRegistrationStep2Page> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _brideIdController = TextEditingController();

  @override
  void dispose() {
    _brideIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<MarriageFormProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Sync controller with provider value
    if (provider.brideNationalId != null &&
        _brideIdController.text != provider.brideNationalId) {
      _brideIdController.text = provider.brideNationalId!;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            color: Colors.pink.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.pink.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.pink.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter bride\'s National ID to verify identity via NIRA. Bride must be FEMALE and not already married.',
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
            'Bride Information',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Bride details (must be female)',
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
                      name: 'brideNationalId',
                      controller: _brideIdController,
                      decoration: InputDecoration(
                        labelText: 'Bride National ID *',
                        hintText: 'Enter bride\'s National ID',
                        prefixIcon: const Icon(Icons.badge),
                        suffixIcon: provider.isLoadingBride
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : provider.brideIdentity != null
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : null,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      onChanged: (value) {
                        provider.updateBrideNationalId(value);
                        if (value != null && value.length >= 9) {
                          final token = authProvider.token;
                          if (token != null && token.isNotEmpty) {
                            provider.fetchBrideIdentity(token);
                          }
                        }
                      },
                    ),
                    if (provider.brideError != null) ...[
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
                                provider.brideError!,
                                style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (provider.brideIdentity != null) ...[
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
                              provider.brideIdentity!.fullName,
                            ),
                            if (provider.brideIdentity!.dateOfBirth != null)
                              _buildReadOnlyField(
                                context,
                                'Date of Birth',
                                provider.brideIdentity!.dateOfBirth!,
                              ),
                            if (provider.brideIdentity!.gender != null)
                              _buildReadOnlyField(
                                context,
                                'Gender',
                                provider.brideIdentity!.gender!.toUpperCase(),
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
