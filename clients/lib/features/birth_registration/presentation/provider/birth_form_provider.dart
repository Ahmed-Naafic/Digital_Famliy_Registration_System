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

  // Step 2: Parent Details (using IDs from existing family members)
  String? _fatherId;
  String? _motherId;
  String? _fatherName; // For display only
  String? _motherName; // For display only

  // Step 3: Documents
  List<UploadedDocument> _documents = [];

  // Current step in the multi-step flow
  int _currentStep = 0;

  // Getters
  String? get childName => _childName;
  DateTime? get dateOfBirth => _dateOfBirth;
  String? get placeOfBirth => _placeOfBirth;
  String? get gender => _gender;
  String? get fatherId => _fatherId;
  String? get motherId => _motherId;
  String? get fatherName => _fatherName; // Display name
  String? get motherName => _motherName; // Display name
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
      _fatherId != null &&
      _fatherId!.isNotEmpty &&
      _motherId != null &&
      _motherId!.isNotEmpty;

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

  void updateFatherId(String? id, String? name) {
    _fatherId = id;
    _fatherName = name;
    notifyListeners();
  }

  void updateMotherId(String? id, String? name) {
    _motherId = id;
    _motherName = name;
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
    _fatherId = null;
    _motherId = null;
    _fatherName = null;
    _motherName = null;
    _documents = [];
    _currentStep = 0;
    notifyListeners();
  }

  /// Build complete payload for API submission
  /// Returns payload using IDs from existing family members
  Map<String, dynamic> buildPayload() {
    return {
      'child': {
        'name': _childName,
        'dateOfBirth': _dateOfBirth?.toIso8601String(),
        'placeOfBirth': _placeOfBirth,
        'gender': _gender,
      },
      'fatherId': _fatherId,
      'motherId': _motherId,
    };
  }

  /// Get documents as JSON for API submission
  List<Map<String, dynamic>> getDocumentsJson() {
    return _documents.map((doc) => doc.toJson()).toList();
  }

  // Get form data as map (for backward compatibility)
  Map<String, dynamic> toJson() {
    return {
      'childName': _childName,
      'dateOfBirth': _dateOfBirth?.toIso8601String(),
      'placeOfBirth': _placeOfBirth,
      'gender': _gender,
      'fatherId': _fatherId,
      'motherId': _motherId,
      'fatherName': _fatherName,
      'motherName': _motherName,
    };
  }
}

