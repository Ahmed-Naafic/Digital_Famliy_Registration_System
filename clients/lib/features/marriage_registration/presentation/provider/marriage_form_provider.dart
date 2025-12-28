import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../core/models/uploaded_document.dart';
import '../../../../features/applications/data/application_service.dart';
import '../../../birth_registration/models/identity_model.dart';

/// Marriage Registration Form Provider
/// Manages form state for marriage registration multi-step flow (CRVS - Islamic Law)
class MarriageFormProvider extends ChangeNotifier {
  // Step 0: Applicant Details
  String? _applicantNationalId;
  IdentityData? _applicantIdentity;
  bool _isLoadingApplicant = false;
  String? _applicantError;

  // Step 1: Groom Details
  String? _groomNationalId;
  IdentityData? _groomIdentity;
  bool _isLoadingGroom = false;
  String? _groomError;

  // Step 2: Bride Details
  String? _brideNationalId;
  IdentityData? _brideIdentity;
  bool _isLoadingBride = false;
  String? _brideError;

  // Step 3: Wali Details
  String? _waliNationalId;
  String? _waliRelationship;
  IdentityData? _waliIdentity;
  bool _isLoadingWali = false;
  String? _waliError;

  // Step 4: Witnesses (2 required)
  String? _witness1NationalId;
  IdentityData? _witness1Identity;
  bool _isLoadingWitness1 = false;
  String? _witness1Error;

  String? _witness2NationalId;
  IdentityData? _witness2Identity;
  bool _isLoadingWitness2 = false;
  String? _witness2Error;

  // Step 5: Sheikh Details
  String? _sheikhNationalId;
  IdentityData? _sheikhIdentity;
  bool _isLoadingSheikh = false;
  String? _sheikhError;

  // Step 6: Meher
  String? _meherType; // "CASH" or "ASSET"
  double? _meherValue;
  String? _meherCurrency;
  bool _meherDeferred = false;

  // Step 7: Marriage Details
  DateTime? _marriageDate;
  String? _marriageDistrict;
  String? _marriageSector;
  String? _marriagePlace;

  // Step 8: Documents
  List<UploadedDocument> _documents = [];

  // Current step in the multi-step flow
  int _currentStep = 0;

  // Getters
  String? get applicantNationalId => _applicantNationalId;
  IdentityData? get applicantIdentity => _applicantIdentity;
  bool get isLoadingApplicant => _isLoadingApplicant;
  String? get applicantError => _applicantError;

  String? get groomNationalId => _groomNationalId;
  IdentityData? get groomIdentity => _groomIdentity;
  bool get isLoadingGroom => _isLoadingGroom;
  String? get groomError => _groomError;

  String? get brideNationalId => _brideNationalId;
  IdentityData? get brideIdentity => _brideIdentity;
  bool get isLoadingBride => _isLoadingBride;
  String? get brideError => _brideError;

  String? get waliNationalId => _waliNationalId;
  String? get waliRelationship => _waliRelationship;
  IdentityData? get waliIdentity => _waliIdentity;
  bool get isLoadingWali => _isLoadingWali;
  String? get waliError => _waliError;

  String? get witness1NationalId => _witness1NationalId;
  IdentityData? get witness1Identity => _witness1Identity;
  bool get isLoadingWitness1 => _isLoadingWitness1;
  String? get witness1Error => _witness1Error;

  String? get witness2NationalId => _witness2NationalId;
  IdentityData? get witness2Identity => _witness2Identity;
  bool get isLoadingWitness2 => _isLoadingWitness2;
  String? get witness2Error => _witness2Error;

  String? get sheikhNationalId => _sheikhNationalId;
  IdentityData? get sheikhIdentity => _sheikhIdentity;
  bool get isLoadingSheikh => _isLoadingSheikh;
  String? get sheikhError => _sheikhError;

  String? get meherType => _meherType;
  double? get meherValue => _meherValue;
  String? get meherCurrency => _meherCurrency;
  bool get meherDeferred => _meherDeferred;

  DateTime? get marriageDate => _marriageDate;
  String? get marriageDistrict => _marriageDistrict;
  String? get marriageSector => _marriageSector;
  String? get marriagePlace => _marriagePlace;

  List<UploadedDocument> get documents => List.unmodifiable(_documents);
  int get currentStep => _currentStep;

  // Validation
  bool get isApplicantValid =>
      _applicantNationalId != null &&
      _applicantNationalId!.isNotEmpty &&
      _applicantIdentity != null;

  bool get isStep1Valid =>
      _groomNationalId != null &&
      _groomNationalId!.isNotEmpty &&
      _groomIdentity != null;

  bool get isStep2Valid =>
      _brideNationalId != null &&
      _brideNationalId!.isNotEmpty &&
      _brideIdentity != null;

  bool get isStep3Valid =>
      _waliNationalId != null &&
      _waliNationalId!.isNotEmpty &&
      _waliRelationship != null &&
      _waliRelationship!.isNotEmpty &&
      _waliIdentity != null;

  bool get isStep4Valid =>
      _witness1NationalId != null &&
      _witness1NationalId!.isNotEmpty &&
      _witness1Identity != null &&
      _witness2NationalId != null &&
      _witness2NationalId!.isNotEmpty &&
      _witness2Identity != null;

  bool get isStep5Valid =>
      _sheikhNationalId != null &&
      _sheikhNationalId!.isNotEmpty &&
      _sheikhIdentity != null;

  bool get isStep6Valid =>
      _meherType != null &&
      _meherType!.isNotEmpty &&
      _meherValue != null &&
      _meherValue! > 0 &&
      (_meherType == 'ASSET' || (_meherType == 'CASH' && _meherCurrency != null && _meherCurrency!.isNotEmpty));

  bool get isStep7Valid =>
      _marriageDate != null &&
      _marriageDistrict != null &&
      _marriageDistrict!.isNotEmpty &&
      _marriageSector != null &&
      _marriageSector!.isNotEmpty;

  bool get isStep8Valid => _documents.isNotEmpty;

  bool get isFormComplete =>
      isApplicantValid &&
      isStep1Valid &&
      isStep2Valid &&
      isStep3Valid &&
      isStep4Valid &&
      isStep5Valid &&
      isStep6Valid &&
      isStep7Valid &&
      isStep8Valid;

  // Helper method to check for duplicate National IDs
  String? _checkDuplicateNationalId(String nationalId, String role) {
    final id = nationalId.trim();
    
    // Applicant can be groom, bride, or wali - so allow those
    if (role == 'groom' && _applicantNationalId != null && _applicantNationalId!.trim() == id) {
      return null; // Allowed: Applicant can be groom
    }
    if (role == 'bride' && _applicantNationalId != null && _applicantNationalId!.trim() == id) {
      return null; // Allowed: Applicant can be bride
    }
    if (role == 'wali' && _applicantNationalId != null && _applicantNationalId!.trim() == id) {
      return null; // Allowed: Applicant can be wali
    }
    
    // Groom cannot be wali, sheikh, or witness
    if (role == 'wali' && _groomNationalId != null && _groomNationalId!.trim() == id) {
      return 'This is the groom and cannot be wali. Groom cannot hold multiple roles.';
    }
    if (role == 'sheikh' && _groomNationalId != null && _groomNationalId!.trim() == id) {
      return 'This is the groom and cannot be sheikh. Groom cannot hold multiple roles.';
    }
    if (role == 'witness1' && _groomNationalId != null && _groomNationalId!.trim() == id) {
      return 'This is the groom and cannot be a witness. Groom cannot hold multiple roles.';
    }
    if (role == 'witness2' && _groomNationalId != null && _groomNationalId!.trim() == id) {
      return 'This is the groom and cannot be a witness. Groom cannot hold multiple roles.';
    }
    
    // Wali cannot be witness
    if (role == 'witness1' && _waliNationalId != null && _waliNationalId!.trim() == id) {
      return 'This is the wali and cannot be a witness. Wali cannot hold multiple roles.';
    }
    if (role == 'witness2' && _waliNationalId != null && _waliNationalId!.trim() == id) {
      return 'This is the wali and cannot be a witness. Wali cannot hold multiple roles.';
    }
    
    // Sheikh cannot be witness
    if (role == 'witness1' && _sheikhNationalId != null && _sheikhNationalId!.trim() == id) {
      return 'This is the sheikh and cannot be a witness. Sheikh cannot hold multiple roles.';
    }
    if (role == 'witness2' && _sheikhNationalId != null && _sheikhNationalId!.trim() == id) {
      return 'This is the sheikh and cannot be a witness. Sheikh cannot hold multiple roles.';
    }
    
    // Two witnesses cannot be the same
    if (role == 'witness1' && _witness2NationalId != null && _witness2NationalId!.trim() == id) {
      return 'This is already used as Witness 2. Two witnesses must be different people.';
    }
    if (role == 'witness2' && _witness1NationalId != null && _witness1NationalId!.trim() == id) {
      return 'This is already used as Witness 1. Two witnesses must be different people.';
    }
    
    // Wali cannot be sheikh
    if (role == 'sheikh' && _waliNationalId != null && _waliNationalId!.trim() == id) {
      return 'This is the wali and cannot be sheikh. Wali cannot hold multiple roles.';
    }
    if (role == 'wali' && _sheikhNationalId != null && _sheikhNationalId!.trim() == id) {
      return 'This is the sheikh and cannot be wali. Sheikh cannot hold multiple roles.';
    }
    
    // Bride cannot be in any other role
    if (role != 'bride' && _brideNationalId != null && _brideNationalId!.trim() == id) {
      return 'This is the bride and cannot hold another role.';
    }
    
    return null; // No conflict
  }

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

  void updateGroomNationalId(String? value) {
    _groomNationalId = value;
    _groomIdentity = null;
    _groomError = null;
    // Re-validate wali, sheikh, and witnesses if they exist (they might conflict with new groom)
    if (value != null && value.isNotEmpty) {
      _revalidateConflictingRoles('groom', value);
    }
    notifyListeners();
  }
  
  // Re-validate roles that might conflict with a changed National ID
  void _revalidateConflictingRoles(String changedRole, String newNationalId) {
    final id = newNationalId.trim();
    
    if (changedRole == 'groom') {
      // If groom changed, check if wali, sheikh, or witnesses match
      if (_waliNationalId != null && _waliNationalId!.trim() == id && _waliIdentity != null) {
        _waliIdentity = null;
        _waliError = 'This is the groom and cannot be wali. Groom cannot hold multiple roles.';
      }
      if (_sheikhNationalId != null && _sheikhNationalId!.trim() == id && _sheikhIdentity != null) {
        _sheikhIdentity = null;
        _sheikhError = 'This is the groom and cannot be sheikh. Groom cannot hold multiple roles.';
      }
      if (_witness1NationalId != null && _witness1NationalId!.trim() == id && _witness1Identity != null) {
        _witness1Identity = null;
        _witness1Error = 'This is the groom and cannot be a witness. Groom cannot hold multiple roles.';
      }
      if (_witness2NationalId != null && _witness2NationalId!.trim() == id && _witness2Identity != null) {
        _witness2Identity = null;
        _witness2Error = 'This is the groom and cannot be a witness. Groom cannot hold multiple roles.';
      }
    } else if (changedRole == 'wali') {
      // If wali changed, check if witnesses or sheikh match
      if (_witness1NationalId != null && _witness1NationalId!.trim() == id && _witness1Identity != null) {
        _witness1Identity = null;
        _witness1Error = 'This is the wali and cannot be a witness. Wali cannot hold multiple roles.';
      }
      if (_witness2NationalId != null && _witness2NationalId!.trim() == id && _witness2Identity != null) {
        _witness2Identity = null;
        _witness2Error = 'This is the wali and cannot be a witness. Wali cannot hold multiple roles.';
      }
      if (_sheikhNationalId != null && _sheikhNationalId!.trim() == id && _sheikhIdentity != null) {
        _sheikhIdentity = null;
        _sheikhError = 'This is the wali and cannot be sheikh. Wali cannot hold multiple roles.';
      }
      // Also check if groom matches
      if (_groomNationalId != null && _groomNationalId!.trim() == id && _groomIdentity != null) {
        _groomIdentity = null;
        _groomError = 'This is the groom and cannot be wali. Groom cannot hold multiple roles.';
      }
    } else if (changedRole == 'sheikh') {
      // If sheikh changed, check if wali, witnesses, or groom match
      if (_waliNationalId != null && _waliNationalId!.trim() == id && _waliIdentity != null) {
        _waliIdentity = null;
        _waliError = 'This is the sheikh and cannot be wali. Sheikh cannot hold multiple roles.';
      }
      if (_witness1NationalId != null && _witness1NationalId!.trim() == id && _witness1Identity != null) {
        _witness1Identity = null;
        _witness1Error = 'This is the sheikh and cannot be a witness. Sheikh cannot hold multiple roles.';
      }
      if (_witness2NationalId != null && _witness2NationalId!.trim() == id && _witness2Identity != null) {
        _witness2Identity = null;
        _witness2Error = 'This is the sheikh and cannot be a witness. Sheikh cannot hold multiple roles.';
      }
      if (_groomNationalId != null && _groomNationalId!.trim() == id && _groomIdentity != null) {
        _groomIdentity = null;
        _groomError = 'This is the groom and cannot be sheikh. Groom cannot hold multiple roles.';
      }
    } else if (changedRole == 'witness1') {
      // If witness1 changed, check if witness2, groom, wali, or sheikh match
      if (_witness2NationalId != null && _witness2NationalId!.trim() == id && _witness2Identity != null) {
        _witness2Identity = null;
        _witness2Error = 'This is already used as Witness 1. Two witnesses must be different people.';
      }
      if (_groomNationalId != null && _groomNationalId!.trim() == id && _groomIdentity != null) {
        _groomIdentity = null;
        _groomError = 'This is the groom and cannot be a witness. Groom cannot hold multiple roles.';
      }
      if (_waliNationalId != null && _waliNationalId!.trim() == id && _waliIdentity != null) {
        _waliIdentity = null;
        _waliError = 'This is the wali and cannot be a witness. Wali cannot hold multiple roles.';
      }
      if (_sheikhNationalId != null && _sheikhNationalId!.trim() == id && _sheikhIdentity != null) {
        _sheikhIdentity = null;
        _sheikhError = 'This is the sheikh and cannot be a witness. Sheikh cannot hold multiple roles.';
      }
    } else if (changedRole == 'witness2') {
      // If witness2 changed, check if witness1, groom, wali, or sheikh match
      if (_witness1NationalId != null && _witness1NationalId!.trim() == id && _witness1Identity != null) {
        _witness1Identity = null;
        _witness1Error = 'This is already used as Witness 2. Two witnesses must be different people.';
      }
      if (_groomNationalId != null && _groomNationalId!.trim() == id && _groomIdentity != null) {
        _groomIdentity = null;
        _groomError = 'This is the groom and cannot be a witness. Groom cannot hold multiple roles.';
      }
      if (_waliNationalId != null && _waliNationalId!.trim() == id && _waliIdentity != null) {
        _waliIdentity = null;
        _waliError = 'This is the wali and cannot be a witness. Wali cannot hold multiple roles.';
      }
      if (_sheikhNationalId != null && _sheikhNationalId!.trim() == id && _sheikhIdentity != null) {
        _sheikhIdentity = null;
        _sheikhError = 'This is the sheikh and cannot be a witness. Sheikh cannot hold multiple roles.';
      }
    }
  }

  Future<void> fetchGroomIdentity(String token) async {
    if (_groomNationalId == null || _groomNationalId!.isEmpty) {
      return;
    }

    _isLoadingGroom = true;
    _groomError = null;
    notifyListeners();

    try {
      final applicationService = const ApplicationService();
      final identityData = await applicationService.fetchPersonByNationalId(
        nationalId: _groomNationalId!,
        token: token,
      );
      final identity = IdentityData.fromJson(identityData);
      
      // Check for duplicate National IDs
      final duplicateError = _checkDuplicateNationalId(_groomNationalId!, 'groom');
      if (duplicateError != null) {
        _groomIdentity = null;
        _groomError = duplicateError;
      } else {
        // Validate gender - Groom must be MALE
        final gender = (identity.gender ?? '').toUpperCase();
        if (gender != 'MALE') {
          _groomIdentity = null;
          _groomError = 'Groom must be MALE according to Islamic law. This person is ${gender.isNotEmpty ? gender : "not specified"}.';
        } else {
          _groomIdentity = identity;
          _groomError = null;
        }
      }
    } catch (e) {
      _groomIdentity = null;
      _groomError = 'Failed to verify groom: $e';
    } finally {
      _isLoadingGroom = false;
      notifyListeners();
    }
  }

  void updateBrideNationalId(String? value) {
    _brideNationalId = value;
    _brideIdentity = null;
    _brideError = null;
    notifyListeners();
  }

  Future<void> fetchBrideIdentity(String token) async {
    if (_brideNationalId == null || _brideNationalId!.isEmpty) {
      return;
    }

    _isLoadingBride = true;
    _brideError = null;
    notifyListeners();

    try {
      final applicationService = const ApplicationService();
      final identityData = await applicationService.fetchPersonByNationalId(
        nationalId: _brideNationalId!,
        token: token,
      );
      final identity = IdentityData.fromJson(identityData);
      
      // Check for duplicate National IDs
      final duplicateError = _checkDuplicateNationalId(_brideNationalId!, 'bride');
      if (duplicateError != null) {
        _brideIdentity = null;
        _brideError = duplicateError;
      } else {
        // Validate gender - Bride must be FEMALE
        final gender = (identity.gender ?? '').toUpperCase();
        if (gender != 'FEMALE') {
          _brideIdentity = null;
          _brideError = 'Bride must be FEMALE according to Islamic law. This person is ${gender.isNotEmpty ? gender : "not specified"}.';
        } else {
          _brideIdentity = identity;
          _brideError = null;
        }
      }
    } catch (e) {
      _brideIdentity = null;
      _brideError = 'Failed to verify bride: $e';
    } finally {
      _isLoadingBride = false;
      notifyListeners();
    }
  }

  void updateWaliNationalId(String? value) {
    _waliNationalId = value;
    _waliIdentity = null;
    _waliError = null;
    // Re-validate witnesses and sheikh if they exist (they might conflict with new wali)
    if (value != null && value.isNotEmpty) {
      _revalidateConflictingRoles('wali', value);
    }
    notifyListeners();
  }

  void updateWaliRelationship(String? value) {
    _waliRelationship = value;
    notifyListeners();
  }

  Future<void> fetchWaliIdentity(String token) async {
    if (_waliNationalId == null || _waliNationalId!.isEmpty) {
      return;
    }

    _isLoadingWali = true;
    _waliError = null;
    notifyListeners();

    try {
      final applicationService = const ApplicationService();
      final identityData = await applicationService.fetchPersonByNationalId(
        nationalId: _waliNationalId!,
        token: token,
      );
      final identity = IdentityData.fromJson(identityData);
      
      // Check for duplicate National IDs
      final duplicateError = _checkDuplicateNationalId(_waliNationalId!, 'wali');
      if (duplicateError != null) {
        _waliIdentity = null;
        _waliError = duplicateError;
      } else {
        // Validate gender - Wali must be MALE
        final gender = (identity.gender ?? '').toUpperCase();
        if (gender != 'MALE') {
          _waliIdentity = null;
          _waliError = 'Wali must be MALE according to Islamic law. This person is ${gender.isNotEmpty ? gender : "not specified"}.';
        } else {
          _waliIdentity = identity;
          _waliError = null;
        }
      }
    } catch (e) {
      _waliIdentity = null;
      _waliError = 'Failed to verify wali: $e';
    } finally {
      _isLoadingWali = false;
      notifyListeners();
    }
  }

  void updateWitness1NationalId(String? value) {
    _witness1NationalId = value;
    _witness1Identity = null;
    _witness1Error = null;
    // Re-validate witness2 if it exists (they might be the same)
    if (value != null && value.isNotEmpty) {
      _revalidateConflictingRoles('witness1', value);
    }
    notifyListeners();
  }

  Future<void> fetchWitness1Identity(String token) async {
    if (_witness1NationalId == null || _witness1NationalId!.isEmpty) {
      return;
    }

    _isLoadingWitness1 = true;
    _witness1Error = null;
    notifyListeners();

    try {
      final applicationService = const ApplicationService();
      final identityData = await applicationService.fetchPersonByNationalId(
        nationalId: _witness1NationalId!,
        token: token,
      );
      final identity = IdentityData.fromJson(identityData);
      
      // Check for duplicate National IDs
      final duplicateError = _checkDuplicateNationalId(_witness1NationalId!, 'witness1');
      if (duplicateError != null) {
        _witness1Identity = null;
        _witness1Error = duplicateError;
      } else {
        // Validate gender - Witness must be MALE
        final gender = (identity.gender ?? '').toUpperCase();
        if (gender != 'MALE') {
          _witness1Identity = null;
          _witness1Error = 'Marriage witnesses must be MALE according to Islamic law. This person is ${gender.isNotEmpty ? gender : "not specified"}.';
        } else {
          _witness1Identity = identity;
          _witness1Error = null;
        }
      }
    } catch (e) {
      _witness1Identity = null;
      _witness1Error = 'Failed to verify witness 1: $e';
    } finally {
      _isLoadingWitness1 = false;
      notifyListeners();
    }
  }

  void updateWitness2NationalId(String? value) {
    _witness2NationalId = value;
    _witness2Identity = null;
    _witness2Error = null;
    // Re-validate witness1 if it exists (they might be the same)
    if (value != null && value.isNotEmpty) {
      _revalidateConflictingRoles('witness2', value);
    }
    notifyListeners();
  }

  Future<void> fetchWitness2Identity(String token) async {
    if (_witness2NationalId == null || _witness2NationalId!.isEmpty) {
      return;
    }

    _isLoadingWitness2 = true;
    _witness2Error = null;
    notifyListeners();

    try {
      final applicationService = const ApplicationService();
      final identityData = await applicationService.fetchPersonByNationalId(
        nationalId: _witness2NationalId!,
        token: token,
      );
      final identity = IdentityData.fromJson(identityData);
      
      // Check for duplicate National IDs
      final duplicateError = _checkDuplicateNationalId(_witness2NationalId!, 'witness2');
      if (duplicateError != null) {
        _witness2Identity = null;
        _witness2Error = duplicateError;
      } else {
        // Validate gender - Witness must be MALE
        final gender = (identity.gender ?? '').toUpperCase();
        if (gender != 'MALE') {
          _witness2Identity = null;
          _witness2Error = 'Marriage witnesses must be MALE according to Islamic law. This person is ${gender.isNotEmpty ? gender : "not specified"}.';
        } else {
          _witness2Identity = identity;
          _witness2Error = null;
        }
      }
    } catch (e) {
      _witness2Identity = null;
      _witness2Error = 'Failed to verify witness 2: $e';
    } finally {
      _isLoadingWitness2 = false;
      notifyListeners();
    }
  }

  void updateSheikhNationalId(String? value) {
    _sheikhNationalId = value;
    _sheikhIdentity = null;
    _sheikhError = null;
    // Re-validate wali and witnesses if they exist (they might conflict with new sheikh)
    if (value != null && value.isNotEmpty) {
      _revalidateConflictingRoles('sheikh', value);
    }
    notifyListeners();
  }

  Future<void> fetchSheikhIdentity(String token) async {
    if (_sheikhNationalId == null || _sheikhNationalId!.isEmpty) {
      return;
    }

    _isLoadingSheikh = true;
    _sheikhError = null;
    notifyListeners();

    try {
      final applicationService = const ApplicationService();
      final identityData = await applicationService.fetchPersonByNationalId(
        nationalId: _sheikhNationalId!,
        token: token,
      );
      final identity = IdentityData.fromJson(identityData);
      
      // Check for duplicate National IDs
      final duplicateError = _checkDuplicateNationalId(_sheikhNationalId!, 'sheikh');
      if (duplicateError != null) {
        _sheikhIdentity = null;
        _sheikhError = duplicateError;
      } else {
        // Validate gender - Sheikh must be MALE
        final gender = (identity.gender ?? '').toUpperCase();
        if (gender != 'MALE') {
          _sheikhIdentity = null;
          _sheikhError = 'Sheikh must be MALE according to Islamic law. This person is ${gender.isNotEmpty ? gender : "not specified"}.';
        } else {
          _sheikhIdentity = identity;
          _sheikhError = null;
        }
      }
    } catch (e) {
      _sheikhIdentity = null;
      _sheikhError = 'Failed to verify sheikh: $e';
    } finally {
      _isLoadingSheikh = false;
      notifyListeners();
    }
  }

  void updateMeherType(String? value) {
    _meherType = value;
    if (value == 'ASSET') {
      _meherCurrency = null; // Clear currency if not CASH
    }
    notifyListeners();
  }

  void updateMeherValue(double? value) {
    _meherValue = value;
    notifyListeners();
  }

  void updateMeherCurrency(String? value) {
    _meherCurrency = value;
    notifyListeners();
  }

  void updateMeherDeferred(bool value) {
    _meherDeferred = value;
    notifyListeners();
  }

  void updateMarriageDate(DateTime? value) {
    _marriageDate = value;
    notifyListeners();
  }

  void updateMarriageDistrict(String? value) {
    _marriageDistrict = value;
    _marriageSector = null; // Clear sector when district changes
    notifyListeners();
  }

  void updateMarriageSector(String? value) {
    _marriageSector = value;
    notifyListeners();
  }

  void updateMarriagePlace(String? value) {
    _marriagePlace = value;
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
    _groomNationalId = null;
    _groomIdentity = null;
    _groomError = null;
    _isLoadingGroom = false;
    _brideNationalId = null;
    _brideIdentity = null;
    _brideError = null;
    _isLoadingBride = false;
    _waliNationalId = null;
    _waliRelationship = null;
    _waliIdentity = null;
    _waliError = null;
    _isLoadingWali = false;
    _witness1NationalId = null;
    _witness1Identity = null;
    _witness1Error = null;
    _isLoadingWitness1 = false;
    _witness2NationalId = null;
    _witness2Identity = null;
    _witness2Error = null;
    _isLoadingWitness2 = false;
    _sheikhNationalId = null;
    _sheikhIdentity = null;
    _sheikhError = null;
    _isLoadingSheikh = false;
    _meherType = null;
    _meherValue = null;
    _meherCurrency = null;
    _meherDeferred = false;
    _marriageDate = null;
    _marriageDistrict = null;
    _marriageSector = null;
    _marriagePlace = null;
    _documents = [];
    _currentStep = 0;
    notifyListeners();
  }

  /// Build complete payload for API submission (CRVS - Islamic Marriage format)
  Map<String, dynamic> buildPayload() {
    return {
      'applicantNationalId': _applicantNationalId,
      'groomNationalId': _groomNationalId,
      'brideNationalId': _brideNationalId,
      'wali': {
        'nationalId': _waliNationalId,
        'relationship': _waliRelationship,
      },
      'witnesses': [
        {'nationalId': _witness1NationalId},
        {'nationalId': _witness2NationalId},
      ],
      'sheikh': {
        'nationalId': _sheikhNationalId,
      },
      'meher': {
        'type': _meherType,
        'value': _meherValue,
        'currency': _meherCurrency,
        'deferred': _meherDeferred,
      },
      'marriageDetails': {
        'date': _marriageDate?.toIso8601String(),
        'district': _marriageDistrict,
        'sector': _marriageSector,
        'place': _marriagePlace ?? '',
      },
    };
  }

  /// Get documents as File objects for API submission
  List<File> getDocumentFiles() {
    return _documents
        .map((doc) => doc.file)
        .where((file) => file.existsSync())
        .toList();
  }
}
