import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/location_service.dart';
import '../provider/marriage_form_provider.dart';

/// Marriage Registration Step 7: Marriage Details with Location
class MarriageRegistrationStep7Page extends StatefulWidget {
  const MarriageRegistrationStep7Page({super.key});

  @override
  State<MarriageRegistrationStep7Page> createState() =>
      _MarriageRegistrationStep7PageState();
}

class _MarriageRegistrationStep7PageState
    extends State<MarriageRegistrationStep7Page> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _locationService = const LocationService();
  List<String> _districts = [];
  List<String> _sectors = [];
  bool _isLoadingDistricts = false;
  bool _isLoadingSectors = false;

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

  Future<void> _loadSectors(String district) async {
    if (district.isEmpty) {
      setState(() {
        _sectors = [];
        _isLoadingSectors = false;
      });
      return;
    }

    setState(() => _isLoadingSectors = true);
    try {
      final sectors = await _locationService.getSectorsByDistrict(district);
      if (mounted) {
        setState(() {
          _sectors = sectors;
          _isLoadingSectors = false;
        });
        
        // If provider has a sector value that's not in the loaded sectors, clear it
        final provider = Provider.of<MarriageFormProvider>(context, listen: false);
        if (provider.marriageSector != null && 
            provider.marriageSector!.isNotEmpty &&
            !sectors.contains(provider.marriageSector)) {
          provider.updateMarriageSector(null);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSectors = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sectors: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<MarriageFormProvider>(context);
    
    // Load sectors if district is already selected and sectors haven't been loaded
    if (provider.marriageDistrict != null && 
        provider.marriageDistrict!.isNotEmpty &&
        _sectors.isEmpty &&
        !_isLoadingSectors &&
        _districts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadSectors(provider.marriageDistrict!);
        }
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marriage Details',
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
                    FormBuilderDateTimePicker(
                      name: 'marriageDate',
                      initialValue: provider.marriageDate,
                      decoration: const InputDecoration(
                        labelText: 'Marriage Date *',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: FormBuilderValidators.required(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      onChanged: (value) {
                        provider.updateMarriageDate(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    FormBuilderDropdown<String>(
                      name: 'marriageDistrict',
                      initialValue: provider.marriageDistrict != null &&
                              _districts.contains(provider.marriageDistrict)
                          ? provider.marriageDistrict
                          : null,
                      decoration: InputDecoration(
                        labelText: 'District *',
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
                        if (value != null) {
                          provider.updateMarriageDistrict(value);
                          _loadSectors(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    FormBuilderDropdown<String>(
                      name: 'marriageSector',
                      initialValue: provider.marriageSector != null &&
                              _sectors.contains(provider.marriageSector)
                          ? provider.marriageSector
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Sector *',
                        prefixIcon: const Icon(Icons.location_on),
                        suffixIcon: _isLoadingSectors
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
                      items: _sectors
                          .map((sector) => DropdownMenuItem(
                                value: sector,
                                child: Text(sector),
                              ))
                          .toList(),
                      validator: FormBuilderValidators.required(),
                      enabled: provider.marriageDistrict != null &&
                          provider.marriageDistrict!.isNotEmpty &&
                          _sectors.isNotEmpty,
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateMarriageSector(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'marriagePlace',
                      initialValue: provider.marriagePlace,
                      decoration: const InputDecoration(
                        labelText: 'Place (Optional)',
                        hintText: 'e.g., Mosque name, venue',
                        prefixIcon: Icon(Icons.place),
                      ),
                      onChanged: (value) {
                        provider.updateMarriagePlace(value);
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

