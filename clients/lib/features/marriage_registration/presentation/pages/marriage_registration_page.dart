import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Marriage Registration Page
/// Form for registering a marriage
/// Theme-aware with Material 3 design
class MarriageRegistrationPage extends StatefulWidget {
  const MarriageRegistrationPage({super.key});

  @override
  State<MarriageRegistrationPage> createState() => _MarriageRegistrationPageState();
}

class _MarriageRegistrationPageState extends State<MarriageRegistrationPage> {
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
            content: const Text('Your marriage registration has been submitted successfully.'),
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
        title: const Text('Marriage Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                          Icons.favorite,
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
                              'Register Marriage',
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

              // Couple Information Section
              Text(
                'Couple Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'husbandName',
                decoration: InputDecoration(
                  labelText: 'Husband\'s Full Name *',
                  hintText: 'Enter husband\'s full name',
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(2),
                ]),
              ),
              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'wifeName',
                decoration: InputDecoration(
                  labelText: 'Wife\'s Full Name *',
                  hintText: 'Enter wife\'s full name',
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(2),
                ]),
              ),
              const SizedBox(height: 24),

              // Marriage Details Section
              Text(
                'Marriage Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),

              FormBuilderDateTimePicker(
                name: 'marriageDate',
                decoration: InputDecoration(
                  labelText: 'Marriage Date *',
                  hintText: 'Select marriage date',
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                validator: FormBuilderValidators.required(),
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              ),
              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'location',
                decoration: InputDecoration(
                  labelText: 'Marriage Location *',
                  hintText: 'Enter location',
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 24),

              // Witnesses Section
              Text(
                'Witnesses',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'witness1',
                decoration: InputDecoration(
                  labelText: 'Witness 1 Name *',
                  hintText: 'Enter first witness name',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'witness2',
                decoration: InputDecoration(
                  labelText: 'Witness 2 Name *',
                  hintText: 'Enter second witness name',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
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


