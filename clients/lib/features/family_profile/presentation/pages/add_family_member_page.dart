import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/applications/data/application_service.dart';
import '../../../../features/auth/auth_provider.dart';
import '../../../../core/router/route_names.dart';

/// Add Family Member Page
/// Form to add a new family member to the user's family
class AddFamilyMemberPage extends StatefulWidget {
  const AddFamilyMemberPage({super.key});

  @override
  State<AddFamilyMemberPage> createState() => _AddFamilyMemberPageState();
}

class _AddFamilyMemberPageState extends State<AddFamilyMemberPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final applicationService = const ApplicationService();
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to add family members'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        // Build member data payload
        final memberData = <String, dynamic>{
          'firstName': formData['firstName'] as String,
          'lastName': formData['lastName'] as String,
          if (formData['gender'] != null) 'gender': formData['gender'] as String,
          if (formData['dateOfBirth'] != null)
            'dateOfBirth': (formData['dateOfBirth'] as DateTime).toIso8601String(),
          if (formData['placeOfBirth'] != null && (formData['placeOfBirth'] as String).isNotEmpty)
            'placeOfBirth': formData['placeOfBirth'] as String,
          if (formData['nationalIdNumber'] != null && (formData['nationalIdNumber'] as String).isNotEmpty)
            'nationalIdNumber': formData['nationalIdNumber'] as String,
          if (formData['maritalStatus'] != null)
            'maritalStatus': formData['maritalStatus'] as String,
        };

        await applicationService.addFamilyMember(
          token: token,
          memberData: memberData,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Family member added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to family profile
          context.pop(true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          final errorMessage = e.toString();
          // Check if error is about missing family
          if (errorMessage.contains('does not have an active family') ||
              errorMessage.contains('no active family')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please create your family record first before adding members'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
            // Redirect to create family page
            context.goNamed(Routes.createFamily);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error adding family member: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Family Member'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Text(
              'Family Member Information',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide the family member\'s details',
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
                        name: 'firstName',
                        decoration: const InputDecoration(
                          labelText: 'First Name *',
                          hintText: 'Enter first name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(2),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      FormBuilderTextField(
                        name: 'lastName',
                        decoration: const InputDecoration(
                          labelText: 'Last Name *',
                          hintText: 'Enter last name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(2),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      FormBuilderDropdown<String>(
                        name: 'gender',
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          hintText: 'Select gender',
                          prefixIcon: Icon(Icons.wc),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Male')),
                          DropdownMenuItem(value: 'female', child: Text('Female')),
                        ],
                      ),
                      const SizedBox(height: 16),

                      FormBuilderDateTimePicker(
                        name: 'dateOfBirth',
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          hintText: 'Select date of birth',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      ),
                      const SizedBox(height: 16),

                      FormBuilderTextField(
                        name: 'placeOfBirth',
                        decoration: const InputDecoration(
                          labelText: 'Place of Birth',
                          hintText: 'Enter place of birth',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 16),

                      FormBuilderTextField(
                        name: 'nationalIdNumber',
                        decoration: const InputDecoration(
                          labelText: 'National ID Number',
                          hintText: 'Enter national ID number',
                          prefixIcon: Icon(Icons.badge),
                        ),
                      ),
                      const SizedBox(height: 16),

                      FormBuilderDropdown<String>(
                        name: 'maritalStatus',
                        decoration: const InputDecoration(
                          labelText: 'Marital Status',
                          hintText: 'Select marital status',
                          prefixIcon: Icon(Icons.favorite),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'single', child: Text('Single')),
                          DropdownMenuItem(value: 'married', child: Text('Married')),
                          DropdownMenuItem(value: 'divorced', child: Text('Divorced')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Add Family Member',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

