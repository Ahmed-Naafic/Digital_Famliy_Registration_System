import 'package:flutter/foundation.dart';
import '../../../features/applications/data/application_service.dart';

/// Family Provider
/// Manages family state and checks if user has a family
class FamilyProvider extends ChangeNotifier {
  FamilyProvider({ApplicationService? applicationService})
      : _applicationService =
            applicationService ?? const ApplicationService();

  final ApplicationService _applicationService;

  bool _hasFamily = false;
  String? _familyId;
  bool _isChecking = false;
  String? _error;

  bool get hasFamily => _hasFamily;
  String? get familyId => _familyId;
  bool get isChecking => _isChecking;
  String? get error => _error;

  /// Check if the logged-in user has a family
  Future<void> checkFamily({required String token}) async {
    _isChecking = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _applicationService.checkFamily(token: token);
      _hasFamily = result['hasFamily'] as bool? ?? false;
      _familyId = result['familyId'] as String?;
      debugPrint('Family check result: hasFamily=$_hasFamily, familyId=$_familyId');
    } catch (e) {
      _error = e.toString();
      _hasFamily = false;
      _familyId = null;
      debugPrint('Error checking family: $e');
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// Reset family state (e.g., on logout)
  void reset() {
    _hasFamily = false;
    _familyId = null;
    _error = null;
    _isChecking = false;
    notifyListeners();
  }
}

