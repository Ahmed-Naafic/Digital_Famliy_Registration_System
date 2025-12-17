import 'package:flutter/foundation.dart';
import '../../../../core/models/uploaded_document.dart';

/// Divorce Registration Form Provider
class DivorceFormProvider extends ChangeNotifier {
  // Step 1: Couple Details
  String? _husbandName;
  String? _wifeName;

  // Step 2: Divorce Info
  DateTime? _divorceDate;
  String? _reason;

  // Step 3: Documents
  List<UploadedDocument> _documents = [];

  // Current step in the multi-step flow
  int _currentStep = 0;

  // Getters
  String? get husbandName => _husbandName;
  String? get wifeName => _wifeName;
  DateTime? get divorceDate => _divorceDate;
  String? get reason => _reason;
  List<UploadedDocument> get documents => List.unmodifiable(_documents);
  int get currentStep => _currentStep;

  // Validation
  bool get isStep1Valid =>
      _husbandName != null &&
      _husbandName!.isNotEmpty &&
      _wifeName != null &&
      _wifeName!.isNotEmpty;

  bool get isStep2Valid =>
      _divorceDate != null && _reason != null && _reason!.isNotEmpty;

  bool get isStep3Valid => _documents.isNotEmpty;

  bool get isFormComplete => isStep1Valid && isStep2Valid && isStep3Valid;

  // Update methods
  void updateHusbandName(String value) {
    _husbandName = value;
    notifyListeners();
  }

  void updateWifeName(String value) {
    _wifeName = value;
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
    _husbandName = null;
    _wifeName = null;
    _divorceDate = null;
    _reason = null;
    _documents = [];
    _currentStep = 0;
    notifyListeners();
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

