import 'package:flutter/foundation.dart';
import '../../../../core/models/uploaded_document.dart';

/// Death Registration Form Provider
class DeathFormProvider extends ChangeNotifier {
  // Step 1: Deceased Details
  String? _deceasedName;
  DateTime? _dateOfDeath;
  String? _placeOfDeath;
  String? _causeOfDeath;

  // Step 2: Reporter Details
  String? _reporterName;
  String? _reporterRelationship;
  String? _reporterContact;

  // Step 3: Documents
  List<UploadedDocument> _documents = [];

  // Current step in the multi-step flow
  int _currentStep = 0;

  // Getters
  String? get deceasedName => _deceasedName;
  DateTime? get dateOfDeath => _dateOfDeath;
  String? get placeOfDeath => _placeOfDeath;
  String? get causeOfDeath => _causeOfDeath;
  String? get reporterName => _reporterName;
  String? get reporterRelationship => _reporterRelationship;
  String? get reporterContact => _reporterContact;
  List<UploadedDocument> get documents => List.unmodifiable(_documents);
  int get currentStep => _currentStep;

  // Validation
  bool get isStep1Valid =>
      _deceasedName != null &&
      _deceasedName!.isNotEmpty &&
      _dateOfDeath != null &&
      _placeOfDeath != null &&
      _placeOfDeath!.isNotEmpty &&
      _causeOfDeath != null &&
      _causeOfDeath!.isNotEmpty;

  bool get isStep2Valid =>
      _reporterName != null &&
      _reporterName!.isNotEmpty &&
      _reporterRelationship != null &&
      _reporterRelationship!.isNotEmpty;

  bool get isStep3Valid => _documents.isNotEmpty;

  bool get isFormComplete => isStep1Valid && isStep2Valid && isStep3Valid;

  // Update methods
  void updateDeceasedName(String value) {
    _deceasedName = value;
    notifyListeners();
  }

  void updateDateOfDeath(DateTime value) {
    _dateOfDeath = value;
    notifyListeners();
  }

  void updatePlaceOfDeath(String value) {
    _placeOfDeath = value;
    notifyListeners();
  }

  void updateCauseOfDeath(String value) {
    _causeOfDeath = value;
    notifyListeners();
  }

  void updateReporterName(String value) {
    _reporterName = value;
    notifyListeners();
  }

  void updateReporterRelationship(String value) {
    _reporterRelationship = value;
    notifyListeners();
  }

  void updateReporterContact(String value) {
    _reporterContact = value;
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
    _deceasedName = null;
    _dateOfDeath = null;
    _placeOfDeath = null;
    _causeOfDeath = null;
    _reporterName = null;
    _reporterRelationship = null;
    _reporterContact = null;
    _documents = [];
    _currentStep = 0;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'deceasedName': _deceasedName,
      'dateOfDeath': _dateOfDeath?.toIso8601String(),
      'placeOfDeath': _placeOfDeath,
      'causeOfDeath': _causeOfDeath,
      'reporterName': _reporterName,
      'reporterRelationship': _reporterRelationship,
      'reporterContact': _reporterContact,
      'documents': _documents.map((doc) => doc.toJson()).toList(),
    };
  }
}

