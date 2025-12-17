import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../provider/marriage_form_provider.dart';

/// Marriage Registration Step 2: Wife Details & Marriage Info
class MarriageRegistrationStep2Page extends StatefulWidget {
  const MarriageRegistrationStep2Page({super.key});

  @override
  State<MarriageRegistrationStep2Page> createState() => _MarriageRegistrationStep2PageState();
}

class _MarriageRegistrationStep2PageState extends State<MarriageRegistrationStep2Page> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<MarriageFormProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            'Wife & Marriage Details',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide wife\'s details and marriage information',
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
              name: 'wifeName',
              initialValue: provider.wifeName,
              decoration: InputDecoration(
                labelText: 'Wife\'s Full Name *',
                hintText: 'Enter wife\'s full name',
                prefixIcon: const Icon(Icons.person),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
              ]),
              onChanged: (value) {
                if (value != null) {
                  provider.updateWifeName(value);
                }
              },
            ),
            const SizedBox(height: 16),

            FormBuilderDateTimePicker(
              name: 'wifeDateOfBirth',
              initialValue: provider.wifeDateOfBirth,
              decoration: InputDecoration(
                labelText: 'Date of Birth (Optional)',
                hintText: 'Select date of birth',
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onChanged: (value) {
                if (value != null) {
                  provider.updateWifeDateOfBirth(value);
                }
              },
            ),
            const SizedBox(height: 16),

            FormBuilderTextField(
              name: 'wifeNationalId',
              initialValue: provider.wifeNationalId,
              decoration: InputDecoration(
                labelText: 'National ID (Optional)',
                hintText: 'Enter national ID',
                prefixIcon: const Icon(Icons.badge),
              ),
              onChanged: (value) {
                provider.updateWifeNationalId(value ?? '');
              },
            ),
            const SizedBox(height: 24),

            FormBuilderDateTimePicker(
              name: 'marriageDate',
              initialValue: provider.marriageDate,
              decoration: InputDecoration(
                labelText: 'Marriage Date *',
                hintText: 'Select marriage date',
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              validator: FormBuilderValidators.required(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onChanged: (value) {
                if (value != null) {
                  provider.updateMarriageDate(value);
                }
              },
            ),
            const SizedBox(height: 16),

            FormBuilderTextField(
              name: 'location',
              initialValue: provider.location,
              decoration: InputDecoration(
                labelText: 'Marriage Location *',
                hintText: 'Enter location',
                prefixIcon: const Icon(Icons.location_on),
              ),
              validator: FormBuilderValidators.required(),
              onChanged: (value) {
                if (value != null) {
                  provider.updateLocation(value);
                }
              },
            ),
            const SizedBox(height: 24),

            FormBuilderTextField(
              name: 'witness1',
              initialValue: provider.witness1,
              decoration: InputDecoration(
                labelText: 'Witness 1 Name *',
                hintText: 'Enter first witness name',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: FormBuilderValidators.required(),
              onChanged: (value) {
                if (value != null) {
                  provider.updateWitness1(value);
                }
              },
            ),
            const SizedBox(height: 16),

            FormBuilderTextField(
              name: 'witness2',
              initialValue: provider.witness2,
              decoration: InputDecoration(
                labelText: 'Witness 2 Name *',
                hintText: 'Enter second witness name',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: FormBuilderValidators.required(),
              onChanged: (value) {
                if (value != null) {
                  provider.updateWitness2(value);
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

