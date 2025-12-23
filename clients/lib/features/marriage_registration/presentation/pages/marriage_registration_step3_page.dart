import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../provider/marriage_form_provider.dart';

/// Marriage Registration Step 3: Witness Information ONLY
class MarriageRegistrationStep3Page extends StatefulWidget {
  const MarriageRegistrationStep3Page({super.key});

  @override
  State<MarriageRegistrationStep3Page> createState() =>
      _MarriageRegistrationStep3PageState();
}

class _MarriageRegistrationStep3PageState
    extends State<MarriageRegistrationStep3Page> {
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
            'Witness Information',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide details of two witnesses',
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
                      name: 'witness1',
                      initialValue: provider.witness1,
                      decoration: InputDecoration(
                        labelText: 'Witness 1 Full Name *',
                        hintText: 'Enter first witness full name',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(2),
                      ]),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateWitness1(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'witness1NationalId',
                      initialValue: provider.witness1NationalId,
                      decoration: InputDecoration(
                        labelText: 'Witness 1 National ID (Optional)',
                        hintText: 'Enter national ID',
                        prefixIcon: const Icon(Icons.badge),
                      ),
                      onChanged: (value) {
                        provider.updateWitness1NationalId(value ?? '');
                      },
                    ),
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
                      name: 'witness2',
                      initialValue: provider.witness2,
                      decoration: InputDecoration(
                        labelText: 'Witness 2 Full Name *',
                        hintText: 'Enter second witness full name',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(2),
                      ]),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateWitness2(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'witness2NationalId',
                      initialValue: provider.witness2NationalId,
                      decoration: InputDecoration(
                        labelText: 'Witness 2 National ID (Optional)',
                        hintText: 'Enter national ID',
                        prefixIcon: const Icon(Icons.badge),
                      ),
                      onChanged: (value) {
                        provider.updateWitness2NationalId(value ?? '');
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
