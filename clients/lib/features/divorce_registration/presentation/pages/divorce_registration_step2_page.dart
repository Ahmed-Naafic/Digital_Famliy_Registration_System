import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../provider/divorce_form_provider.dart';

/// Divorce Registration Step 2: Divorce Information
class DivorceRegistrationStep2Page extends StatefulWidget {
  const DivorceRegistrationStep2Page({super.key});

  @override
  State<DivorceRegistrationStep2Page> createState() => _DivorceRegistrationStep2PageState();
}

class _DivorceRegistrationStep2PageState extends State<DivorceRegistrationStep2Page> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<DivorceFormProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            'Divorce Details',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide divorce information',
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
                    FormBuilderDateTimePicker(
              name: 'divorceDate',
              initialValue: provider.divorceDate,
              decoration: InputDecoration(
                labelText: 'Divorce Date *',
                hintText: 'Select divorce date',
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              validator: FormBuilderValidators.required(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onChanged: (value) {
                if (value != null) {
                  provider.updateDivorceDate(value);
                }
              },
            ),
            const SizedBox(height: 16),

            FormBuilderDropdown<String>(
              name: 'reason',
              initialValue: provider.reason,
              decoration: InputDecoration(
                labelText: 'Reason *',
                prefixIcon: const Icon(Icons.description),
              ),
              items: [
                'Mutual Consent',
                'Irreconcilable Differences',
                'Abandonment',
                'Other',
              ]
                  .map((reason) => DropdownMenuItem(
                        value: reason,
                        child: Text(reason),
                      ))
                  .toList(),
              validator: FormBuilderValidators.required(),
              onChanged: (value) {
                if (value != null) {
                  provider.updateReason(value);
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

