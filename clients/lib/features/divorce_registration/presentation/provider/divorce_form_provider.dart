import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../core/models/uploaded_document.dart';

/// Divorce Registration Form Provider
class DivorceFormProvider extends ChangeNotifier {
  // Step 1: Selected Couple (from database)
  String? _selectedCoupleId; // Key to identify selected couple
  String? _husbandId;
  String? _husbandName;
  String? _wifeId;
  String? _wifeName;

  // Step 2: Divorce Info
  DateTime? _divorceDate;
  String? _reason;

  // Step 3: Documents
  List<UploadedDocument> _documents = [];

  // Current step in the multi-step flow
  int _currentStep = 0;

  // Getters
  String? get selectedCoupleId => _selectedCoupleId;
  String? get husbandId => _husbandId;
  String? get husbandName => _husbandName;
  String? get wifeId => _wifeId;
  String? get wifeName => _wifeName;
  DateTime? get divorceDate => _divorceDate;
  String? get reason => _reason;
  List<UploadedDocument> get documents => List.unmodifiable(_documents);
  int get currentStep => _currentStep;

  // Validation
  bool get isStep1Valid =>
      _selectedCoupleId != null &&
      _selectedCoupleId!.isNotEmpty &&
      _husbandId != null &&
      _wifeId != null;

  bool get isStep2Valid => _divorceDate != null;

  bool get isStep3Valid => _documents.isNotEmpty;

  bool get isFormComplete => isStep1Valid && isStep2Valid && isStep3Valid;

  // Update methods
  void selectCouple({
    required String coupleId,
    required String husbandId,
    required String husbandName,
    required String wifeId,
    required String wifeName,
  }) {
    _selectedCoupleId = coupleId;
    _husbandId = husbandId;
    _husbandName = husbandName;
    _wifeId = wifeId;
    _wifeName = wifeName;
    notifyListeners();
  }

  void updateDivorceDate(DateTime value) {
    _divorceDate = value;
    notifyListeners();
  }

  void updateReason(String value) {
    _reason = value;
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
    _selectedCoupleId = null;
    _husbandId = null;
    _husbandName = null;
    _wifeId = null;
    _wifeName = null;
    _divorceDate = null;
    _reason = null;
    _documents = [];
    _currentStep = 0;
    notifyListeners();
  }

  /// Build complete payload for API submission
  /// Returns payload in structured format matching backend expectations
  /// Uses database IDs, not names
  Map<String, dynamic> buildPayload() {
    return {
      'husbandId': _husbandId,
      'wifeId': _wifeId,
      if (_divorceDate != null) 'divorceDate': _divorceDate!.toIso8601String(),
      if (_reason != null && _reason!.isNotEmpty) 'reason': _reason,
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

  Map<String, dynamic> toJson() {
    return {
      'husbandName': _husbandName,
      'wifeName': _wifeName,
      'divorceDate': _divorceDate?.toIso8601String(),
      'reason': _reason,
      'documents': _documents.map((doc) => doc.toJson()).toList(),
    };
  }
}

