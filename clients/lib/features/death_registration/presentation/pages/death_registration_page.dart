import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Death Registration Page
/// Form for registering a death
/// Theme-aware with Material 3 design
class DeathRegistrationPage extends StatefulWidget {
  const DeathRegistrationPage({super.key});

  @override
  State<DeathRegistrationPage> createState() => _DeathRegistrationPageState();
}

class _DeathRegistrationPageState extends State<DeathRegistrationPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  void _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Submitted'),
            content: const Text('The death registration has been submitted successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Death Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informational Note Card
              Card(
                elevation: isDark ? 0 : 2,
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please provide accurate information. This registration is required for official records.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Header Card
              Card(
                elevation: isDark ? 0 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.celebration,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Register Death',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Complete the form below',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Deceased Information
              Text(
                'Deceased Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'deceasedName',
                decoration: InputDecoration(
                  labelText: 'Deceased Full Name *',
                  hintText: 'Enter full name',
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(2),
                ]),
              ),
              const SizedBox(height: 16),

              FormBuilderDateTimePicker(
                name: 'dateOfDeath',
                decoration: InputDecoration(
                  labelText: 'Date of Death *',
                  hintText: 'Select date of death',
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                validator: FormBuilderValidators.required(),
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              ),
              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'placeOfDeath',
                decoration: InputDecoration(
                  labelText: 'Place of Death *',
                  hintText: 'Enter place of death',
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'causeOfDeath',
                decoration: InputDecoration(
                  labelText: 'Cause of Death *',
                  hintText: 'Enter cause of death',
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Registration'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}


