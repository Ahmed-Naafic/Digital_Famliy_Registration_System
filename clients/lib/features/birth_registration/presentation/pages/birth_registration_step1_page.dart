import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/auth_provider.dart';
import '../provider/birth_form_provider.dart';

/// Birth Registration Step 1: Applicant & Child Details
class BirthRegistrationStep1Page extends StatefulWidget {
  const BirthRegistrationStep1Page({super.key});

  @override
  State<BirthRegistrationStep1Page> createState() =>
      _BirthRegistrationStep1PageState();
}

class _BirthRegistrationStep1PageState
    extends State<BirthRegistrationStep1Page> {
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
    final provider = Provider.of<BirthFormProvider>(context);
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
          // Applicant Section
          Text(
            'Applicant Information',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your National ID to verify your identity',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 24),

          // Child Section
          Text(
            'Child Information',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide the child\'s details',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),

          // Form Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'childName',
                      initialValue: provider.childName,
                      decoration: const InputDecoration(
                        labelText: 'Child Full Name *',
                        hintText: 'Enter child\'s full name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(2),
                      ]),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateChildName(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    FormBuilderDateTimePicker(
                      name: 'dateOfBirth',
                      initialValue: provider.dateOfBirth,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth *',
                        hintText: 'Select date of birth',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: FormBuilderValidators.required(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateDateOfBirth(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    FormBuilderTextField(
                      name: 'placeOfBirth',
                      initialValue: provider.placeOfBirth,
                      decoration: const InputDecoration(
                        labelText: 'Place of Birth *',
                        hintText: 'Enter place of birth',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: FormBuilderValidators.required(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updatePlaceOfBirth(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    FormBuilderDropdown<String>(
                      name: 'gender',
                      initialValue: provider.gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender *',
                        prefixIcon: Icon(Icons.people),
                      ),
                      items: ['Male', 'Female']
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ),
                          )
                          .toList(),
                      validator: FormBuilderValidators.required(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateGender(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    FormBuilderTextField(
                      name: 'nationality',
                      initialValue: provider.nationality ?? 'Somali',
                      decoration: const InputDecoration(
                        labelText: 'Nationality *',
                        hintText: 'Enter nationality',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      validator: FormBuilderValidators.required(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateNationality(value);
                        }
                      },
                    ),
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
