import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../provider/birth_form_provider.dart';

/// Birth Registration Step 1: Child Details
class BirthRegistrationStep1Page extends StatefulWidget {
  const BirthRegistrationStep1Page({super.key});

  @override
  State<BirthRegistrationStep1Page> createState() =>
      _BirthRegistrationStep1PageState();
}

class _BirthRegistrationStep1PageState
    extends State<BirthRegistrationStep1Page> {
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
