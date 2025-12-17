import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../provider/death_form_provider.dart';

/// Death Registration Step 1: Deceased Details
class DeathRegistrationStep1Page extends StatefulWidget {
  const DeathRegistrationStep1Page({super.key});

  @override
  State<DeathRegistrationStep1Page> createState() => _DeathRegistrationStep1PageState();
}

class _DeathRegistrationStep1PageState extends State<DeathRegistrationStep1Page> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<DeathFormProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please provide accurate information. This registration is required for official records.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section Header
          Text(
            'Deceased Information',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
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
                  name: 'deceasedName',
                  initialValue: provider.deceasedName,
                  decoration: InputDecoration(
                    labelText: 'Deceased Full Name *',
                    hintText: 'Enter full name',
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(2),
                  ]),
                  onChanged: (value) {
                    if (value != null) {
                      provider.updateDeceasedName(value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                FormBuilderDateTimePicker(
                  name: 'dateOfDeath',
                  initialValue: provider.dateOfDeath,
                  decoration: InputDecoration(
                    labelText: 'Date of Death *',
                    hintText: 'Select date of death',
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  validator: FormBuilderValidators.required(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.updateDateOfDeath(value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'placeOfDeath',
                  initialValue: provider.placeOfDeath,
                  decoration: InputDecoration(
                    labelText: 'Place of Death *',
                    hintText: 'Enter place of death',
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.updatePlaceOfDeath(value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'causeOfDeath',
                  initialValue: provider.causeOfDeath,
                  decoration: InputDecoration(
                    labelText: 'Cause of Death *',
                    hintText: 'Enter cause of death',
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.updateCauseOfDeath(value);
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

