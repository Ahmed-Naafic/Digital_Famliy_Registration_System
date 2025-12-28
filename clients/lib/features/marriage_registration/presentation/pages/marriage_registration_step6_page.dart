import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../provider/marriage_form_provider.dart';

/// Marriage Registration Step 6: Meher Details
class MarriageRegistrationStep6Page extends StatefulWidget {
  const MarriageRegistrationStep6Page({super.key});

  @override
  State<MarriageRegistrationStep6Page> createState() =>
      _MarriageRegistrationStep6PageState();
}

class _MarriageRegistrationStep6PageState
    extends State<MarriageRegistrationStep6Page> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _valueController = TextEditingController();

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<MarriageFormProvider>(context);

    if (provider.meherValue != null &&
        _valueController.text != provider.meherValue.toString()) {
      _valueController.text = provider.meherValue.toString();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.amber.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Meher is required. Select type (CASH or ASSET) and enter value. Currency required for CASH.',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Meher Information',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    FormBuilderDropdown<String>(
                      name: 'meherType',
                      initialValue: provider.meherType != null &&
                              ['CASH', 'ASSET'].contains(provider.meherType)
                          ? provider.meherType
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Meher Type *',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: ['CASH', 'ASSET']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      validator: FormBuilderValidators.required(),
                      onChanged: (value) {
                        provider.updateMeherType(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'meherValue',
                      controller: _valueController,
                      decoration: const InputDecoration(
                        labelText: 'Meher Value *',
                        hintText: 'Enter value',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                      ]),
                      onChanged: (value) {
                        if (value != null && value.isNotEmpty) {
                          provider.updateMeherValue(double.tryParse(value));
                        }
                      },
                    ),
                    if (provider.meherType == 'CASH') ...[
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'meherCurrency',
                        initialValue: provider.meherCurrency,
                        decoration: const InputDecoration(
                          labelText: 'Currency *',
                          hintText: 'e.g., USD, SOS',
                          prefixIcon: Icon(Icons.currency_exchange),
                        ),
                        validator: FormBuilderValidators.required(),
                        onChanged: (value) {
                          provider.updateMeherCurrency(value);
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    FormBuilderCheckbox(
                      name: 'meherDeferred',
                      initialValue: provider.meherDeferred,
                      title: const Text('Meher is deferred'),
                      onChanged: (value) {
                        provider.updateMeherDeferred(value ?? false);
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

