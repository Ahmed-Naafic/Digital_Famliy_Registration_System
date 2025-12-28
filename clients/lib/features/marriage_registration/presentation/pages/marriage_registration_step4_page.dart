import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/auth_provider.dart';
import '../provider/marriage_form_provider.dart';

/// Marriage Registration Step 4: Witnesses Details (2 required, both using National ID)
class MarriageRegistrationStep4Page extends StatefulWidget {
  const MarriageRegistrationStep4Page({super.key});

  @override
  State<MarriageRegistrationStep4Page> createState() =>
      _MarriageRegistrationStep4PageState();
}

class _MarriageRegistrationStep4PageState
    extends State<MarriageRegistrationStep4Page> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _witness1IdController = TextEditingController();
  final _witness2IdController = TextEditingController();

  @override
  void dispose() {
    _witness1IdController.dispose();
    _witness2IdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<MarriageFormProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Sync controllers with provider values
    if (provider.witness1NationalId != null &&
        _witness1IdController.text != provider.witness1NationalId) {
      _witness1IdController.text = provider.witness1NationalId!;
    }
    if (provider.witness2NationalId != null &&
        _witness2IdController.text != provider.witness2NationalId) {
      _witness2IdController.text = provider.witness2NationalId!;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            color: Colors.purple.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.purple.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter National IDs for exactly TWO witnesses. Both must be MALE and cannot be groom, bride, wali, or sheikh.',
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
            'Witnesses Information',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Two male witnesses required',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Witness 1 Section
                    Text(
                      'Witness 1',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'witness1NationalId',
                      controller: _witness1IdController,
                      decoration: InputDecoration(
                        labelText: 'Witness 1 National ID *',
                        hintText: 'Enter witness 1 National ID',
                        prefixIcon: const Icon(Icons.badge),
                        suffixIcon: provider.isLoadingWitness1
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : provider.witness1Identity != null
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : null,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      onChanged: (value) {
                        provider.updateWitness1NationalId(value);
                        if (value != null && value.length >= 9) {
                          final token = authProvider.token;
                          if (token != null && token.isNotEmpty) {
                            provider.fetchWitness1Identity(token);
                          }
                        }
                      },
                    ),
                    if (provider.witness1Error != null) ...[
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
                                provider.witness1Error!,
                                style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (provider.witness1Identity != null) ...[
                      const SizedBox(height: 12),
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
                              provider.witness1Identity!.fullName,
                            ),
                            if (provider.witness1Identity!.gender != null)
                              _buildReadOnlyField(
                                context,
                                'Gender',
                                provider.witness1Identity!.gender!.toUpperCase(),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Divider
                    const Divider(),

                    // Witness 2 Section
                    const SizedBox(height: 16),
                    Text(
                      'Witness 2',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'witness2NationalId',
                      controller: _witness2IdController,
                      decoration: InputDecoration(
                        labelText: 'Witness 2 National ID *',
                        hintText: 'Enter witness 2 National ID',
                        prefixIcon: const Icon(Icons.badge),
                        suffixIcon: provider.isLoadingWitness2
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : provider.witness2Identity != null
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : null,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      onChanged: (value) {
                        provider.updateWitness2NationalId(value);
                        if (value != null && value.length >= 9) {
                          final token = authProvider.token;
                          if (token != null && token.isNotEmpty) {
                            provider.fetchWitness2Identity(token);
                          }
                        }
                      },
                    ),
                    if (provider.witness2Error != null) ...[
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
                                provider.witness2Error!,
                                style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (provider.witness2Identity != null) ...[
                      const SizedBox(height: 12),
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
                              provider.witness2Identity!.fullName,
                            ),
                            if (provider.witness2Identity!.gender != null)
                              _buildReadOnlyField(
                                context,
                                'Gender',
                                provider.witness2Identity!.gender!.toUpperCase(),
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
