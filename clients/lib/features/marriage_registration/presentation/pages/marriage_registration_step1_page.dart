import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../provider/marriage_form_provider.dart';

/// Marriage Registration Step 1: Husband Details
class MarriageRegistrationStep1Page extends StatefulWidget {
  const MarriageRegistrationStep1Page({super.key});

  @override
  State<MarriageRegistrationStep1Page> createState() => _MarriageRegistrationStep1PageState();
}

class _MarriageRegistrationStep1PageState extends State<MarriageRegistrationStep1Page> {
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
            'Husband Information',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide husband\'s details',
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
              name: 'husbandName',
              initialValue: provider.husbandName,
              decoration: InputDecoration(
                labelText: 'Husband\'s Full Name *',
                hintText: 'Enter husband\'s full name',
                prefixIcon: const Icon(Icons.person),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
              ]),
              onChanged: (value) {
                if (value != null) {
                  provider.updateHusbandName(value);
                }
              },
            ),
            const SizedBox(height: 16),

            FormBuilderDateTimePicker(
              name: 'husbandDateOfBirth',
              initialValue: provider.husbandDateOfBirth,
              decoration: InputDecoration(
                labelText: 'Date of Birth (Optional)',
                hintText: 'Select date of birth',
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onChanged: (value) {
                if (value != null) {
                  provider.updateHusbandDateOfBirth(value);
                }
              },
            ),
            const SizedBox(height: 16),

            FormBuilderTextField(
              name: 'husbandNationalId',
              initialValue: provider.husbandNationalId,
              decoration: InputDecoration(
                labelText: 'National ID (Optional)',
                hintText: 'Enter national ID',
                prefixIcon: const Icon(Icons.badge),
              ),
              onChanged: (value) {
                provider.updateHusbandNationalId(value ?? '');
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

