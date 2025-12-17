import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../provider/birth_form_provider.dart';

/// Birth Registration Step 2: Parent Details
class BirthRegistrationStep2Page extends StatefulWidget {
  const BirthRegistrationStep2Page({super.key});

  @override
  State<BirthRegistrationStep2Page> createState() =>
      _BirthRegistrationStep2PageState();
}

class _BirthRegistrationStep2PageState
    extends State<BirthRegistrationStep2Page> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<BirthFormProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            'Parent Information',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide parent details',
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
                      name: 'fatherName',
                      initialValue: provider.fatherName,
                      decoration: const InputDecoration(
                        labelText: 'Father\'s Full Name *',
                        hintText: 'Enter father\'s full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(2),
                      ]),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateFatherName(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    FormBuilderTextField(
                      name: 'motherName',
                      initialValue: provider.motherName,
                      decoration: const InputDecoration(
                        labelText: 'Mother\'s Full Name *',
                        hintText: 'Enter mother\'s full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(2),
                      ]),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateMotherName(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    FormBuilderTextField(
                      name: ' nationalId',
                      initialValue: provider.nationalId,
                      decoration: const InputDecoration(
                        labelText: 'Father\'s National ID *',
                        hintText: 'Enter national ID if available',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      onChanged: (value) {
                        provider.updateNationalId(value ?? '');
                      },
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'nationalId',
                      initialValue: provider.nationalId,
                      decoration: const InputDecoration(
                        labelText: 'Mother\'s National ID *',
                        hintText: 'Enter national ID if available',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      onChanged: (value) {
                        provider.updateNationalId(value ?? '');
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
}
