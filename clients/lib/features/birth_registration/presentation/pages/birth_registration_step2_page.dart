import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../../../features/applications/data/application_service.dart';
import '../../../../features/auth/auth_provider.dart';
import '../provider/birth_form_provider.dart';

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

/// Birth Registration Step 2: Parent Details (Select from Family Members)
class BirthRegistrationStep2Page extends StatefulWidget {
  const BirthRegistrationStep2Page({super.key});

  @override
  State<BirthRegistrationStep2Page> createState() =>
      _BirthRegistrationStep2PageState();
}

class _BirthRegistrationStep2PageState
    extends State<BirthRegistrationStep2Page> {
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
    final provider = Provider.of<BirthFormProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            color: Colors.blue.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please select the father and mother from your existing family members. They must already be registered in your family.',
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
            'Parent Information',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select parents from your family members',
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
                        'No family members found. Please add family members first before registering a birth.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      )
                    else ...[
                      // Filter male members for father
                      FormBuilderDropdown<FamilyMember>(
                        name: 'father',
                        initialValue: provider.fatherId != null
                            ? _familyMembers.firstWhere(
                                (m) => m.id == provider.fatherId,
                                orElse: () => _familyMembers.first,
                              )
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Father *',
                          hintText: 'Select father',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: FormBuilderValidators.required(),
                        items: _familyMembers
                            .where((m) => m.gender == 'male' || m.gender == null)
                            .map(
                              (member) => DropdownMenuItem(
                                value: member,
                                child: Text(member.fullName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            provider.updateFatherId(value.id, value.fullName);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Filter female members for mother
                      FormBuilderDropdown<FamilyMember>(
                        name: 'mother',
                        initialValue: provider.motherId != null
                            ? _familyMembers.firstWhere(
                                (m) => m.id == provider.motherId,
                                orElse: () => _familyMembers.first,
                              )
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Mother *',
                          hintText: 'Select mother',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: FormBuilderValidators.required(),
                        items: _familyMembers
                            .where((m) => m.gender == 'female' || m.gender == null)
                            .map(
                              (member) => DropdownMenuItem(
                                value: member,
                                child: Text(member.fullName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            provider.updateMotherId(value.id, value.fullName);
                          }
                        },
                      ),
                    ],
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
