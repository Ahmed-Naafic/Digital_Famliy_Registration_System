import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../provider/divorce_form_provider.dart';

/// Divorce Registration Step 1: Couple Details
class DivorceRegistrationStep1Page extends StatefulWidget {
  const DivorceRegistrationStep1Page({super.key});

  @override
  State<DivorceRegistrationStep1Page> createState() => _DivorceRegistrationStep1PageState();
}

class _DivorceRegistrationStep1PageState extends State<DivorceRegistrationStep1Page> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<DivorceFormProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning Card
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
                      'Please ensure all information is accurate. This registration cannot be easily reversed.',
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
            'Couple Information',
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

