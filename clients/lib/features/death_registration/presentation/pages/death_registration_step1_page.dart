import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../../../features/applications/data/application_service.dart';
import '../../../../features/auth/auth_provider.dart';
import '../provider/death_form_provider.dart';

/// Family Member Model for selection
class FamilyMember {
  final String id;
  final String fullName;
  final String? gender;
  final DateTime? dateOfBirth;

  FamilyMember({
    required this.id,
    required this.fullName,
    this.gender,
    this.dateOfBirth,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? 
                '${json['firstName']} ${json['lastName']}',
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
    );
  }

  @override
  String toString() => fullName;
}

/// Death Registration Step 1: Select Deceased from Family Members
class DeathRegistrationStep1Page extends StatefulWidget {
  const DeathRegistrationStep1Page({super.key});

  @override
  State<DeathRegistrationStep1Page> createState() => _DeathRegistrationStep1PageState();
}

class _DeathRegistrationStep1PageState extends State<DeathRegistrationStep1Page> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<FamilyMember> _familyMembers = [];
  bool _isLoadingMembers = true;
  String? _errorLoadingMembers;

  @override
  void initState() {
    super.initState();
    _fetchFamilyMembers();
  }

  Future<void> _fetchFamilyMembers() async {
    setState(() {
      _isLoadingMembers = true;
      _errorLoadingMembers = null;
    });

    final authProvider = context.read<AuthProvider>();
    final applicationService = const ApplicationService();
    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      setState(() {
        _errorLoadingMembers = 'Authentication token missing. Please log in.';
        _isLoadingMembers = false;
      });
      return;
    }

    try {
      final rawMembers = await applicationService.getFamilyMembers(token: token);
      setState(() {
        _familyMembers =
            rawMembers.map((json) => FamilyMember.fromJson(json)).toList();
        _isLoadingMembers = false;
      });
    } catch (e) {
      setState(() {
        _errorLoadingMembers = 'Failed to load family members: $e';
        _isLoadingMembers = false;
      });
    }
  }

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
          // Info Card
          Card(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please select the deceased person from your existing family members. They must already be registered in your family.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section Header
          Text(
            'Deceased Information',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select deceased person from your family members',
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
                    if (_isLoadingMembers)
                      const Center(child: CircularProgressIndicator())
                    else if (_errorLoadingMembers != null)
                      Text(
                        _errorLoadingMembers!,
                        style: textTheme.bodyMedium?.copyWith(color: Colors.red),
                      )
                    else if (_familyMembers.isEmpty)
                      Text(
                        'No family members found. Please add family members first before registering a death.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      )
                    else
                      FormBuilderDropdown<FamilyMember>(
                        name: 'deceased',
                        initialValue: provider.deceasedId != null
                            ? _familyMembers.firstWhere(
                                (m) => m.id == provider.deceasedId,
                                orElse: () => _familyMembers.first,
                              )
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Deceased Person *',
                          hintText: 'Select deceased person',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: FormBuilderValidators.required(),
                        items: _familyMembers
                            .map(
                              (member) => DropdownMenuItem(
                                value: member,
                                child: Text(member.fullName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            provider.updateDeceasedId(value.id, value.fullName);
                          }
                        },
                      ),
                    const SizedBox(height: 16),

                    FormBuilderDateTimePicker(
                      name: 'dateOfDeath',
                      initialValue: provider.dateOfDeath,
                      decoration: InputDecoration(
                        labelText: 'Date of Death *',
                        hintText: 'Select date of death',
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      validator: FormBuilderValidators.required(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateDateOfDeath(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    FormBuilderTextField(
                      name: 'placeOfDeath',
                      initialValue: provider.placeOfDeath,
                      decoration: InputDecoration(
                        labelText: 'Place of Death *',
                        hintText: 'Enter place of death',
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      validator: FormBuilderValidators.required(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updatePlaceOfDeath(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    FormBuilderTextField(
                      name: 'causeOfDeath',
                      initialValue: provider.causeOfDeath,
                      decoration: InputDecoration(
                        labelText: 'Cause of Death *',
                        hintText: 'Enter cause of death',
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: FormBuilderValidators.required(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateCauseOfDeath(value);
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
