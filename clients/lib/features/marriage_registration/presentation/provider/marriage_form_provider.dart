import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../core/models/uploaded_document.dart';

/// Marriage Registration Form Provider
/// Manages form state for marriage registration multi-step flow
class MarriageFormProvider extends ChangeNotifier {
  // Step 1: Husband Details (using ID from existing family members)
  String? _husbandId;
  String? _husbandName; // For display only
  String? _husbandNationalId;
  DateTime? _husbandDateOfBirth;

  // Step 2: Wife Details ONLY (using ID from existing family members)
  String? _wifeId;
  String? _wifeName; // For display only
  String? _wifeNationalId;
  DateTime? _wifeDateOfBirth;
  String? _wifeAddress;

  // Step 3: Witness Details ONLY
  String? _witness1;
  String? _witness1NationalId;
  String? _witness2;
  String? _witness2NationalId;

  // Step 4: Marriage Details & Documents
  DateTime? _marriageDate;
  String? _location;
  List<UploadedDocument> _documents = [];

  // Current step in the multi-step flow
  int _currentStep = 0;

  // Getters
  String? get husbandId => _husbandId;
  String? get husbandName => _husbandName; // Display name
  String? get husbandNationalId => _husbandNationalId;
  DateTime? get husbandDateOfBirth => _husbandDateOfBirth;
  String? get wifeId => _wifeId;
  String? get wifeName => _wifeName; // Display name
  String? get wifeNationalId => _wifeNationalId;
  DateTime? get wifeDateOfBirth => _wifeDateOfBirth;
  String? get wifeAddress => _wifeAddress;
  String? get witness1 => _witness1;
  String? get witness1NationalId => _witness1NationalId;
  String? get witness2 => _witness2;
  String? get witness2NationalId => _witness2NationalId;
  DateTime? get marriageDate => _marriageDate;
  String? get location => _location;
  List<UploadedDocument> get documents => List.unmodifiable(_documents);
  int get currentStep => _currentStep;

  // Validation
  bool get isStep1Valid =>
      _husbandId != null && _husbandId!.isNotEmpty;

  // Step 2: Wife Information ONLY
  bool get isStep2Valid =>
      _wifeId != null && _wifeId!.isNotEmpty;

  // Step 3: Witness Information ONLY
  bool get isStep3Valid =>
      _witness1 != null &&
      _witness1!.isNotEmpty &&
      _witness2 != null &&
      _witness2!.isNotEmpty;

  // Step 4: Marriage Details & Documents
  bool get isStep4Valid =>
      _marriageDate != null &&
      _location != null &&
      _location!.isNotEmpty &&
      _documents.isNotEmpty;

  bool get isFormComplete =>
      isStep1Valid && isStep2Valid && isStep3Valid && isStep4Valid;

  // Update methods
  void updateHusbandId(String? id, String? name) {
    _husbandId = id;
    _husbandName = name;
    notifyListeners();
  }

  void updateHusbandNationalId(String value) {
    _husbandNationalId = value;
    notifyListeners();
  }

  void updateHusbandDateOfBirth(DateTime value) {
    _husbandDateOfBirth = value;
    notifyListeners();
  }

  void updateWifeId(String? id, String? name) {
    _wifeId = id;
    _wifeName = name;
    notifyListeners();
  }

  void updateWifeNationalId(String value) {
    _wifeNationalId = value;
    notifyListeners();
  }

  void updateWifeDateOfBirth(DateTime value) {
    _wifeDateOfBirth = value;
    notifyListeners();
  }

  void updateWifeAddress(String value) {
    _wifeAddress = value;
    notifyListeners();
  }

  void updateWitness1(String value) {
    _witness1 = value;
    notifyListeners();
  }

  void updateWitness1NationalId(String value) {
    _witness1NationalId = value;
    notifyListeners();
  }

  void updateWitness2(String value) {
    _witness2 = value;
    notifyListeners();
  }

  void updateWitness2NationalId(String value) {
    _witness2NationalId = value;
    notifyListeners();
  }

  void updateMarriageDate(DateTime value) {
    _marriageDate = value;
    notifyListeners();
  }

  void updateLocation(String value) {
    _location = value;
    notifyListeners();
  }

  void updateDocuments(List<UploadedDocument> documents) {
    _documents = documents;
    notifyListeners();
  }

  void updateCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void reset() {
    _husbandId = null;
    _husbandName = null;
    _husbandNationalId = null;
    _husbandDateOfBirth = null;
    _wifeId = null;
    _wifeName = null;
    _wifeNationalId = null;
    _wifeDateOfBirth = null;
    _wifeAddress = null;
    _witness1 = null;
    _witness1NationalId = null;
    _witness2 = null;
    _witness2NationalId = null;
    _marriageDate = null;
    _location = null;
    _documents = [];
    _currentStep = 0;
    notifyListeners();
  }

  /// Build complete payload for API submission
  /// Returns payload in structured format matching backend expectations:
  /// {
  ///   husband: { name, nationalId, dateOfBirth },
  ///   wife: { name, nationalId, dateOfBirth, address },
  ///   witnesses: [{ name, nationalId }, { name, nationalId }],
  ///   marriageDate: ISO string,
  ///   location: string
  /// }
  /// Note: documents are NOT included in payload - they are uploaded separately as files
  Map<String, dynamic> buildPayload() {
    // Build witnesses array from witness1 and witness2 with their national IDs
    final List<Map<String, dynamic>> witnesses = [];
    if (_witness1 != null && _witness1!.isNotEmpty) {
      witnesses.add({
        'name': _witness1,
        if (_witness1NationalId != null && _witness1NationalId!.isNotEmpty)
          'nationalId': _witness1NationalId,
      });
    }
    if (_witness2 != null && _witness2!.isNotEmpty) {
      witnesses.add({
        'name': _witness2,
        if (_witness2NationalId != null && _witness2NationalId!.isNotEmpty)
          'nationalId': _witness2NationalId,
      });
    }

    return {
      'husbandId': _husbandId,
      'wifeId': _wifeId,
      'witnesses': witnesses,
      if (_marriageDate != null) 'marriageDate': _marriageDate!.toIso8601String(),
      if (_location != null && _location!.isNotEmpty) 'location': _location,
    };
  }

  /// Get documents as File objects for API submission
  /// Documents are uploaded separately, not included in payload
  List<File> getDocumentFiles() {
    return _documents
        .map((doc) => doc.file)
        .where((file) => file.existsSync())
        .toList();
  }

  /// Get form data as map (for backward compatibility)
  Map<String, dynamic> toJson() {
    return {
      'husbandName': _husbandName,
      'husbandNationalId': _husbandNationalId,
      'husbandDateOfBirth': _husbandDateOfBirth?.toIso8601String(),
      'wifeName': _wifeName,
      'wifeNationalId': _wifeNationalId,
      'wifeDateOfBirth': _wifeDateOfBirth?.toIso8601String(),
      'marriageDate': _marriageDate?.toIso8601String(),
      'location': _location,
      'witness1': _witness1,
      'witness2': _witness2,
      'documents': _documents.map((doc) => doc.toJson()).toList(),
    };
  }
}

