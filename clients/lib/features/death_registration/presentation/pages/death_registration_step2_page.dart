import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../provider/death_form_provider.dart';

/// Death Registration Step 2: Reporter Details
class DeathRegistrationStep2Page extends StatefulWidget {
  const DeathRegistrationStep2Page({super.key});

  @override
  State<DeathRegistrationStep2Page> createState() => _DeathRegistrationStep2PageState();
}

class _DeathRegistrationStep2PageState extends State<DeathRegistrationStep2Page> {
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
          // Section Header
          Text(
            'Reporter Information',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide your details as the reporter',
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
              name: 'reporterName',
              initialValue: provider.reporterName,
              decoration: InputDecoration(
                labelText: 'Reporter Full Name *',
                hintText: 'Enter your full name',
                prefixIcon: const Icon(Icons.person),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
              ]),
              onChanged: (value) {
                if (value != null) {
                  provider.updateReporterName(value);
                }
              },
            ),
            const SizedBox(height: 16),

            FormBuilderTextField(
              name: 'reporterRelationship',
              initialValue: provider.reporterRelationship,
              decoration: InputDecoration(
                labelText: 'Relationship to Deceased *',
                hintText: 'e.g., Son, Daughter, Spouse',
                prefixIcon: const Icon(Icons.people),
              ),
              validator: FormBuilderValidators.required(),
              onChanged: (value) {
                if (value != null) {
                  provider.updateReporterRelationship(value);
                }
              },
            ),
            const SizedBox(height: 16),

            FormBuilderTextField(
              name: 'reporterContact',
              initialValue: provider.reporterContact,
              decoration: InputDecoration(
                labelText: 'Contact Number (Optional)',
                hintText: 'Enter contact number',
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                provider.updateReporterContact(value ?? '');
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

