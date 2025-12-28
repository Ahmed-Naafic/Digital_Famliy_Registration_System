import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/location_service.dart';
import '../../../../features/auth/auth_provider.dart';
import '../provider/birth_form_provider.dart';

/// Birth Registration Step 2: Parent Details (using National IDs)
class BirthRegistrationStep2Page extends StatefulWidget {
  const BirthRegistrationStep2Page({super.key});

  @override
  State<BirthRegistrationStep2Page> createState() =>
      _BirthRegistrationStep2PageState();
}

class _BirthRegistrationStep2PageState
    extends State<BirthRegistrationStep2Page> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _fatherIdController = TextEditingController();
  final _motherIdController = TextEditingController();
  final _locationService = const LocationService();

  // Location data
  List<String> _districts = [];
  List<String> _fatherSectors = [];
  List<String> _motherSectors = [];
  bool _isLoadingDistricts = false;
  bool _isLoadingFatherSectors = false;
  bool _isLoadingMotherSectors = false;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    setState(() => _isLoadingDistricts = true);
    try {
      final districts = await _locationService.getDistricts();
      if (mounted) {
        setState(() {
          _districts = districts;
          _isLoadingDistricts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDistricts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading districts: $e')),
        );
      }
    }
  }

  Future<void> _loadFatherSectors(String district) async {
    if (district.isEmpty) {
      setState(() {
        _fatherSectors = [];
        _isLoadingFatherSectors = false;
      });
      return;
    }

    setState(() => _isLoadingFatherSectors = true);
    try {
      final sectors = await _locationService.getSectorsByDistrict(district);
      if (mounted) {
        setState(() {
          _fatherSectors = sectors;
          _isLoadingFatherSectors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFatherSectors = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sectors: $e')),
        );
      }
    }
  }

  Future<void> _loadMotherSectors(String district) async {
    if (district.isEmpty) {
      setState(() {
        _motherSectors = [];
        _isLoadingMotherSectors = false;
      });
      return;
    }

    setState(() => _isLoadingMotherSectors = true);
    try {
      final sectors = await _locationService.getSectorsByDistrict(district);
      if (mounted) {
        setState(() {
          _motherSectors = sectors;
          _isLoadingMotherSectors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMotherSectors = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sectors: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _fatherIdController.dispose();
    _motherIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<BirthFormProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Sync controllers with provider values
    if (provider.fatherNationalId != null &&
        _fatherIdController.text != provider.fatherNationalId) {
      _fatherIdController.text = provider.fatherNationalId!;
    }
    if (provider.motherNationalId != null &&
        _motherIdController.text != provider.motherNationalId) {
      _motherIdController.text = provider.motherNationalId!;
    }

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
                      'Enter parent National IDs to verify their identity via NIRA. Then provide their administrative location (district and sector).',
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
            'Father and Mother details',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Father Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Father',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'fatherNationalId',
                    controller: _fatherIdController,
                    decoration: InputDecoration(
                      labelText: 'Father National ID *',
                      hintText: 'Enter father\'s National ID',
                      prefixIcon: const Icon(Icons.badge),
                      suffixIcon: provider.isLoadingFather
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : provider.fatherIdentity != null
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : null,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    onChanged: (value) {
                      provider.updateFatherNationalId(value);
                      if (value != null && value.length >= 9) {
                        final token = authProvider.token;
                        if (token != null && token.isNotEmpty) {
                          provider.fetchFatherIdentity(token);
                        }
                      }
                    },
                  ),
                  if (provider.fatherError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      provider.fatherError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  if (provider.fatherIdentity != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verified Identity (Read-only)',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildReadOnlyField(
                            context,
                            'Full Name',
                            provider.fatherIdentity!.fullName,
                          ),
                          if (provider.fatherIdentity!.dateOfBirth != null)
                            _buildReadOnlyField(
                              context,
                              'Date of Birth',
                              provider.fatherIdentity!.dateOfBirth!,
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FormBuilderDropdown<String>(
                    name: 'fatherDistrict',
                    initialValue: provider.fatherDistrict,
                    decoration: InputDecoration(
                      labelText: 'Father District *',
                      hintText: 'Select district',
                      prefixIcon: const Icon(Icons.location_city),
                      suffixIcon: _isLoadingDistricts
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    items: _districts
                        .map((district) => DropdownMenuItem(
                              value: district,
                              child: Text(district),
                            ))
                        .toList(),
                    validator: FormBuilderValidators.required(),
                    onChanged: (value) {
                      provider.updateFatherDistrict(value);
                      if (value != null && value.isNotEmpty) {
                        _loadFatherSectors(value);
                      } else {
                        setState(() => _fatherSectors = []);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FormBuilderDropdown<String>(
                    name: 'fatherSector',
                    initialValue: provider.fatherSector,
                    decoration: InputDecoration(
                      labelText: 'Father Sector *',
                      hintText: 'Select sector',
                      prefixIcon: const Icon(Icons.map),
                      suffixIcon: _isLoadingFatherSectors
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    items: _fatherSectors
                        .map((sector) => DropdownMenuItem(
                              value: sector,
                              child: Text(sector),
                            ))
                        .toList(),
                    validator: FormBuilderValidators.required(),
                    enabled: provider.fatherDistrict != null &&
                        provider.fatherDistrict!.isNotEmpty,
                    onChanged: (value) {
                      provider.updateFatherSector(value);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Mother Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mother',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'motherNationalId',
                    controller: _motherIdController,
                    decoration: InputDecoration(
                      labelText: 'Mother National ID *',
                      hintText: 'Enter mother\'s National ID',
                      prefixIcon: const Icon(Icons.badge),
                      suffixIcon: provider.isLoadingMother
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : provider.motherIdentity != null
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : null,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    onChanged: (value) {
                      provider.updateMotherNationalId(value);
                      if (value != null && value.length >= 9) {
                        final token = authProvider.token;
                        if (token != null && token.isNotEmpty) {
                          provider.fetchMotherIdentity(token);
                        }
                      }
                    },
                  ),
                  if (provider.motherError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      provider.motherError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  if (provider.motherIdentity != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verified Identity (Read-only)',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildReadOnlyField(
                            context,
                            'Full Name',
                            provider.motherIdentity!.fullName,
                          ),
                          if (provider.motherIdentity!.dateOfBirth != null)
                            _buildReadOnlyField(
                              context,
                              'Date of Birth',
                              provider.motherIdentity!.dateOfBirth!,
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FormBuilderDropdown<String>(
                    name: 'motherDistrict',
                    initialValue: provider.motherDistrict,
                    decoration: InputDecoration(
                      labelText: 'Mother District *',
                      hintText: 'Select district',
                      prefixIcon: const Icon(Icons.location_city),
                      suffixIcon: _isLoadingDistricts
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    items: _districts
                        .map((district) => DropdownMenuItem(
                              value: district,
                              child: Text(district),
                            ))
                        .toList(),
                    validator: FormBuilderValidators.required(),
                    onChanged: (value) {
                      provider.updateMotherDistrict(value);
                      if (value != null && value.isNotEmpty) {
                        _loadMotherSectors(value!);
                      } else {
                        setState(() => _motherSectors = []);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FormBuilderDropdown<String>(
                    name: 'motherSector',
                    initialValue: provider.motherSector,
                    decoration: InputDecoration(
                      labelText: 'Mother Sector *',
                      hintText: 'Select sector',
                      prefixIcon: const Icon(Icons.map),
                      suffixIcon: _isLoadingMotherSectors
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    items: _motherSectors
                        .map((sector) => DropdownMenuItem(
                              value: sector,
                              child: Text(sector),
                            ))
                        .toList(),
                    validator: FormBuilderValidators.required(),
                    enabled: provider.motherDistrict != null &&
                        provider.motherDistrict!.isNotEmpty,
                    onChanged: (value) {
                      provider.updateMotherSector(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
