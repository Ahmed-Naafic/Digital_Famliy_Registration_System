import 'package:flutter/foundation.dart';
import '../../../../core/models/uploaded_document.dart';

/// Marriage Registration Form Provider
/// Manages form state for marriage registration multi-step flow
class MarriageFormProvider extends ChangeNotifier {
  // Step 1: Husband Details
  String? _husbandName;
  String? _husbandNationalId;
  DateTime? _husbandDateOfBirth;

  // Step 2: Wife Details
  String? _wifeName;
  String? _wifeNationalId;
  DateTime? _wifeDateOfBirth;
  DateTime? _marriageDate;
  String? _location;
  String? _witness1;
  String? _witness2;

  // Step 3: Documents
  List<UploadedDocument> _documents = [];

  // Current step in the multi-step flow
  int _currentStep = 0;

  // Getters
  String? get husbandName => _husbandName;
  String? get husbandNationalId => _husbandNationalId;
  DateTime? get husbandDateOfBirth => _husbandDateOfBirth;
  String? get wifeName => _wifeName;
  String? get wifeNationalId => _wifeNationalId;
  DateTime? get wifeDateOfBirth => _wifeDateOfBirth;
  DateTime? get marriageDate => _marriageDate;
  String? get location => _location;
  String? get witness1 => _witness1;
  String? get witness2 => _witness2;
  List<UploadedDocument> get documents => List.unmodifiable(_documents);
  int get currentStep => _currentStep;

  // Validation
  bool get isStep1Valid =>
      _husbandName != null && _husbandName!.isNotEmpty;

  bool get isStep2Valid =>
      _wifeName != null &&
      _wifeName!.isNotEmpty &&
      _marriageDate != null &&
      _location != null &&
      _location!.isNotEmpty &&
      _witness1 != null &&
      _witness1!.isNotEmpty &&
      _witness2 != null &&
      _witness2!.isNotEmpty;

  bool get isStep3Valid => _documents.isNotEmpty;

  bool get isFormComplete => isStep1Valid && isStep2Valid && isStep3Valid;

  // Update methods
  void updateHusbandName(String value) {
    _husbandName = value;
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

  void updateWifeName(String value) {
    _wifeName = value;
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

  void updateMarriageDate(DateTime value) {
    _marriageDate = value;
    notifyListeners();
  }

  void updateLocation(String value) {
    _location = value;
    notifyListeners();
  }

  void updateWitness1(String value) {
    _witness1 = value;
    notifyListeners();
  }

  void updateWitness2(String value) {
    _witness2 = value;
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
    _husbandName = null;
    _husbandNationalId = null;
    _husbandDateOfBirth = null;
    _wifeName = null;
    _wifeNationalId = null;
    _wifeDateOfBirth = null;
    _marriageDate = null;
    _location = null;
    _witness1 = null;
    _witness2 = null;
    _documents = [];
    _currentStep = 0;
    notifyListeners();
  }

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

