import 'package:flutter/foundation.dart';
import '../../../../core/models/uploaded_document.dart';

/// Birth Registration Form Provider
/// Manages form state for birth registration multi-step flow
class BirthFormProvider extends ChangeNotifier {
  // Step 1: Child Details
  String? _childName;
  DateTime? _dateOfBirth;
  String? _placeOfBirth;
  String? _gender;

  // Step 2: Parent Details
  String? _fatherName;
  String? _motherName;
  String? _nationalId;

  // Step 3: Documents
  List<UploadedDocument> _documents = [];

  // Current step in the multi-step flow
  int _currentStep = 0;

  // Getters
  String? get childName => _childName;
  DateTime? get dateOfBirth => _dateOfBirth;
  String? get placeOfBirth => _placeOfBirth;
  String? get gender => _gender;
  String? get fatherName => _fatherName;
  String? get motherName => _motherName;
  String? get nationalId => _nationalId;
  List<UploadedDocument> get documents => List.unmodifiable(_documents);
  int get currentStep => _currentStep;

  // Validation
  bool get isStep1Valid =>
      _childName != null &&
      _childName!.isNotEmpty &&
      _dateOfBirth != null &&
      _placeOfBirth != null &&
      _placeOfBirth!.isNotEmpty &&
      _gender != null &&
      _gender!.isNotEmpty;

  bool get isStep2Valid =>
      _fatherName != null &&
      _fatherName!.isNotEmpty &&
      _motherName != null &&
      _motherName!.isNotEmpty;

  bool get isStep3Valid => _documents.isNotEmpty;

  bool get isFormComplete => isStep1Valid && isStep2Valid && isStep3Valid;

  // Update methods
  void updateChildName(String value) {
    _childName = value;
    notifyListeners();
  }

  void updateDateOfBirth(DateTime value) {
    _dateOfBirth = value;
    notifyListeners();
  }

  void updatePlaceOfBirth(String value) {
    _placeOfBirth = value;
    notifyListeners();
  }

  void updateGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void updateFatherName(String value) {
    _fatherName = value;
    notifyListeners();
  }

  void updateMotherName(String value) {
    _motherName = value;
    notifyListeners();
  }

  void updateNationalId(String value) {
    _nationalId = value;
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

  // Reset form
  void reset() {
    _childName = null;
    _dateOfBirth = null;
    _placeOfBirth = null;
    _gender = null;
    _fatherName = null;
    _motherName = null;
    _nationalId = null;
    _documents = [];
    _currentStep = 0;
    notifyListeners();
  }

  // Get form data as map (for future API integration)
  Map<String, dynamic> toJson() {
    return {
      'childName': _childName,
      'dateOfBirth': _dateOfBirth?.toIso8601String(),
      'placeOfBirth': _placeOfBirth,
      'gender': _gender,
      'fatherName': _fatherName,
      'motherName': _motherName,
      'nationalId': _nationalId,
    };
  }
}

