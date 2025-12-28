import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/auth_provider.dart';
import '../provider/marriage_form_provider.dart';

/// Marriage Registration Step 5: Sheikh Details (using National ID)
class MarriageRegistrationStep5Page extends StatefulWidget {
  const MarriageRegistrationStep5Page({super.key});

  @override
  State<MarriageRegistrationStep5Page> createState() =>
      _MarriageRegistrationStep5PageState();
}

class _MarriageRegistrationStep5PageState
    extends State<MarriageRegistrationStep5Page> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _sheikhIdController = TextEditingController();

  @override
  void dispose() {
    _sheikhIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<MarriageFormProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (provider.sheikhNationalId != null &&
        _sheikhIdController.text != provider.sheikhNationalId) {
      _sheikhIdController.text = provider.sheikhNationalId!;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.teal.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.teal.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.teal.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter sheikh\'s National ID. Sheikh must be MALE.',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sheikh Information',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'sheikhNationalId',
                      controller: _sheikhIdController,
                      decoration: InputDecoration(
                        labelText: 'Sheikh National ID *',
                        hintText: 'Enter sheikh\'s National ID',
                        prefixIcon: const Icon(Icons.badge),
                        suffixIcon: provider.isLoadingSheikh
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : provider.sheikhIdentity != null
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : null,
                      ),
                      validator: FormBuilderValidators.required(),
                      onChanged: (value) {
                        provider.updateSheikhNationalId(value);
                        if (value != null && value.length >= 9) {
                          final token = authProvider.token;
                          if (token != null && token.isNotEmpty) {
                            provider.fetchSheikhIdentity(token);
                          }
                        }
                      },
                    ),
                    if (provider.sheikhError != null) ...[
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
                                provider.sheikhError!,
                                style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (provider.sheikhIdentity != null) ...[
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
                            Text(
                              'Full Name: ${provider.sheikhIdentity!.fullName}',
                              style: textTheme.bodyMedium,
                            ),
                            if (provider.sheikhIdentity!.gender != null)
                              Text(
                                'Gender: ${provider.sheikhIdentity!.gender!.toUpperCase()}',
                                style: textTheme.bodyMedium,
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
}

