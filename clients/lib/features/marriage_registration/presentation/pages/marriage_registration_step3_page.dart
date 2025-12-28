import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/auth_provider.dart';
import '../provider/marriage_form_provider.dart';

/// Marriage Registration Step 3: Wali Details (using National ID)
class MarriageRegistrationStep3Page extends StatefulWidget {
  const MarriageRegistrationStep3Page({super.key});

  @override
  State<MarriageRegistrationStep3Page> createState() =>
      _MarriageRegistrationStep3PageState();
}

class _MarriageRegistrationStep3PageState
    extends State<MarriageRegistrationStep3Page> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _waliIdController = TextEditingController();

  final List<String> _allowedRelationships = [
    'father',
    'brother',
    'uncle',
    'grandfather',
    'son',
  ];

  @override
  void dispose() {
    _waliIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<MarriageFormProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Sync controller with provider value
    if (provider.waliNationalId != null &&
        _waliIdController.text != provider.waliNationalId) {
      _waliIdController.text = provider.waliNationalId!;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            color: Colors.orange.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter wali\'s National ID and relationship. Wali must be MALE (father, brother, uncle, grandfather, or son).',
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
            'Wali Information',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Wali details (must be male)',
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
                      name: 'waliNationalId',
                      controller: _waliIdController,
                      decoration: InputDecoration(
                        labelText: 'Wali National ID *',
                        hintText: 'Enter wali\'s National ID',
                        prefixIcon: const Icon(Icons.badge),
                        suffixIcon: provider.isLoadingWali
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : provider.waliIdentity != null
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : null,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      onChanged: (value) {
                        provider.updateWaliNationalId(value);
                        if (value != null && value.length >= 9) {
                          final token = authProvider.token;
                          if (token != null && token.isNotEmpty) {
                            provider.fetchWaliIdentity(token);
                          }
                        }
                      },
                    ),
                    if (provider.waliError != null) ...[
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
                                provider.waliError!,
                                style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FormBuilderDropdown<String>(
                      name: 'waliRelationship',
                      initialValue: provider.waliRelationship != null &&
                              _allowedRelationships.contains(provider.waliRelationship)
                          ? provider.waliRelationship
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Relationship to Bride *',
                        hintText: 'Select relationship',
                        prefixIcon: Icon(Icons.family_restroom),
                      ),
                      items: _allowedRelationships
                          .map((rel) => DropdownMenuItem(
                                value: rel,
                                child: Text(rel.toUpperCase()),
                              ))
                          .toList(),
                      validator: FormBuilderValidators.required(),
                      onChanged: (value) {
                        provider.updateWaliRelationship(value);
                      },
                    ),
                    if (provider.waliIdentity != null) ...[
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
                              provider.waliIdentity!.fullName,
                            ),
                            if (provider.waliIdentity!.dateOfBirth != null)
                              _buildReadOnlyField(
                                context,
                                'Date of Birth',
                                provider.waliIdentity!.dateOfBirth!,
                              ),
                            if (provider.waliIdentity!.gender != null)
                              _buildReadOnlyField(
                                context,
                                'Gender',
                                provider.waliIdentity!.gender!.toUpperCase(),
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
