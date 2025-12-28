import 'package:flutter/foundation.dart';
import '../../../../core/models/uploaded_document.dart';
import '../../../../features/applications/data/application_service.dart';
import '../../models/identity_model.dart';

/// Birth Registration Form Provider
/// Manages form state for birth registration multi-step flow (CRVS)
class BirthFormProvider extends ChangeNotifier {
  // Step 0: Applicant Details
  String? _applicantNationalId;
  IdentityData? _applicantIdentity;
  bool _isLoadingApplicant = false;
  String? _applicantError;

  // Step 1: Child Details
  String? _childName;
  DateTime? _dateOfBirth;
  String? _placeOfBirth;
  String? _gender;
  String? _nationality;

  // Step 2: Parent Details (using National IDs)
  String? _fatherNationalId;
  IdentityData? _fatherIdentity;
  bool _isLoadingFather = false;
  String? _fatherError;
  String? _fatherDistrict;
  String? _fatherSector;

  String? _motherNationalId;
  IdentityData? _motherIdentity;
  bool _isLoadingMother = false;
  String? _motherError;
  String? _motherDistrict;
  String? _motherSector;

  // Step 3: Documents
  List<UploadedDocument> _documents = [];

  // Current step in the multi-step flow
  int _currentStep = 0;

  // Getters
  String? get applicantNationalId => _applicantNationalId;
  IdentityData? get applicantIdentity => _applicantIdentity;
  bool get isLoadingApplicant => _isLoadingApplicant;
  String? get applicantError => _applicantError;

  String? get childName => _childName;
  DateTime? get dateOfBirth => _dateOfBirth;
  String? get placeOfBirth => _placeOfBirth;
  String? get gender => _gender;
  String? get nationality => _nationality;

  String? get fatherNationalId => _fatherNationalId;
  IdentityData? get fatherIdentity => _fatherIdentity;
  bool get isLoadingFather => _isLoadingFather;
  String? get fatherError => _fatherError;
  String? get fatherDistrict => _fatherDistrict;
  String? get fatherSector => _fatherSector;

  String? get motherNationalId => _motherNationalId;
  IdentityData? get motherIdentity => _motherIdentity;
  bool get isLoadingMother => _isLoadingMother;
  String? get motherError => _motherError;
  String? get motherDistrict => _motherDistrict;
  String? get motherSector => _motherSector;

  List<UploadedDocument> get documents => List.unmodifiable(_documents);
  int get currentStep => _currentStep;

  // Validation
  bool get isApplicantValid =>
      _applicantNationalId != null &&
      _applicantNationalId!.isNotEmpty &&
      _applicantIdentity != null;

  bool get isStep1Valid =>
      _childName != null &&
      _childName!.isNotEmpty &&
      _dateOfBirth != null &&
      _placeOfBirth != null &&
      _placeOfBirth!.isNotEmpty &&
      _gender != null &&
      _gender!.isNotEmpty &&
      _nationality != null &&
      _nationality!.isNotEmpty;

  bool get isStep2Valid =>
      _fatherNationalId != null &&
      _fatherNationalId!.isNotEmpty &&
      _fatherIdentity != null &&
      _fatherDistrict != null &&
      _fatherDistrict!.isNotEmpty &&
      _fatherSector != null &&
      _fatherSector!.isNotEmpty &&
      _motherNationalId != null &&
      _motherNationalId!.isNotEmpty &&
      _motherIdentity != null &&
      _motherDistrict != null &&
      _motherDistrict!.isNotEmpty &&
      _motherSector != null &&
      _motherSector!.isNotEmpty;

  bool get isStep3Valid => _documents.isNotEmpty;

  bool get isFormComplete =>
      isApplicantValid && isStep1Valid && isStep2Valid && isStep3Valid;

  // Update methods
  void updateApplicantNationalId(String? value) {
    _applicantNationalId = value;
    _applicantIdentity = null;
    _applicantError = null;
    notifyListeners();
  }

  Future<void> fetchApplicantIdentity(String token) async {
    if (_applicantNationalId == null || _applicantNationalId!.isEmpty) {
      return;
    }

    _isLoadingApplicant = true;
    _applicantError = null;
    notifyListeners();

    try {
      final applicationService = const ApplicationService();
      final identityData = await applicationService.fetchPersonByNationalId(
        nationalId: _applicantNationalId!,
        token: token,
      );
      _applicantIdentity = IdentityData.fromJson(identityData);
      _applicantError = null;
    } catch (e) {
      _applicantIdentity = null;
      _applicantError = 'Failed to verify applicant: $e';
    } finally {
      _isLoadingApplicant = false;
      notifyListeners();
    }
  }

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

  void updateNationality(String value) {
    _nationality = value;
    notifyListeners();
  }

  void updateFatherNationalId(String? value) {
    _fatherNationalId = value;
    _fatherIdentity = null;
    _fatherError = null;
    notifyListeners();
  }

  Future<void> fetchFatherIdentity(String token) async {
    if (_fatherNationalId == null || _fatherNationalId!.isEmpty) {
      return;
    }

    _isLoadingFather = true;
    _fatherError = null;
    notifyListeners();

    try {
      final applicationService = const ApplicationService();
      final identityData = await applicationService.fetchPersonByNationalId(
        nationalId: _fatherNationalId!,
        token: token,
      );
      _fatherIdentity = IdentityData.fromJson(identityData);
      _fatherError = null;
    } catch (e) {
      _fatherIdentity = null;
      _fatherError = 'Failed to verify father: $e';
    } finally {
      _isLoadingFather = false;
      notifyListeners();
    }
  }

  void updateFatherDistrict(String? value) {
    _fatherDistrict = value;
    // Clear sector when district changes
    _fatherSector = null;
    notifyListeners();
  }

  void updateFatherSector(String? value) {
    _fatherSector = value;
    notifyListeners();
  }

  void updateMotherNationalId(String? value) {
    _motherNationalId = value;
    _motherIdentity = null;
    _motherError = null;
    notifyListeners();
  }

  Future<void> fetchMotherIdentity(String token) async {
    if (_motherNationalId == null || _motherNationalId!.isEmpty) {
      return;
    }

    _isLoadingMother = true;
    _motherError = null;
    notifyListeners();

    try {
      final applicationService = const ApplicationService();
      final identityData = await applicationService.fetchPersonByNationalId(
        nationalId: _motherNationalId!,
        token: token,
      );
      _motherIdentity = IdentityData.fromJson(identityData);
      _motherError = null;
    } catch (e) {
      _motherIdentity = null;
      _motherError = 'Failed to verify mother: $e';
    } finally {
      _isLoadingMother = false;
      notifyListeners();
    }
  }

  void updateMotherDistrict(String? value) {
    _motherDistrict = value;
    // Clear sector when district changes
    _motherSector = null;
    notifyListeners();
  }

  void updateMotherSector(String? value) {
    _motherSector = value;
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
    _applicantNationalId = null;
    _applicantIdentity = null;
    _applicantError = null;
    _isLoadingApplicant = false;
    _childName = null;
    _dateOfBirth = null;
    _placeOfBirth = null;
    _gender = null;
    _nationality = null;
    _fatherNationalId = null;
    _fatherIdentity = null;
    _fatherError = null;
    _isLoadingFather = false;
    _fatherDistrict = null;
    _fatherSector = null;
    _motherNationalId = null;
    _motherIdentity = null;
    _motherError = null;
    _isLoadingMother = false;
    _motherDistrict = null;
    _motherSector = null;
    _documents = [];
    _currentStep = 0;
    notifyListeners();
  }

  /// Build complete payload for API submission (CRVS format)
  Map<String, dynamic> buildPayload() {
    return {
      'applicantNationalId': _applicantNationalId,
      'child': {
        'name': _childName,
        'dateOfBirth': _dateOfBirth?.toIso8601String(),
        'placeOfBirth': _placeOfBirth,
        'gender': _gender,
        'nationality': _nationality,
      },
      'fatherNationalId': _fatherNationalId,
      'motherNationalId': _motherNationalId,
      'fatherResidence': {
        'district': _fatherDistrict,
        'sector': _fatherSector,
      },
      'motherResidence': {
        'district': _motherDistrict,
        'sector': _motherSector,
      },
    };
  }

  /// Get documents as JSON for API submission
  List<Map<String, dynamic>> getDocumentsJson() {
    return _documents.map((doc) => doc.toJson()).toList();
  }
}
