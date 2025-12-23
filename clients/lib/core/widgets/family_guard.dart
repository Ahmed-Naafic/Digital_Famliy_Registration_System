import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../features/family/providers/family_provider.dart';
import '../../features/auth/auth_provider.dart';
import '../router/route_names.dart';

/// Family Guard Widget
/// Ensures user has a family before allowing access to services
/// Redirects to family setup if no family exists
class FamilyGuard extends StatefulWidget {
  final Widget child;

  const FamilyGuard({
    super.key,
    required this.child,
  });

  @override
  State<FamilyGuard> createState() => _FamilyGuardState();
}

class _FamilyGuardState extends State<FamilyGuard> {
  bool _isChecking = true;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _checkFamily();
  }

  Future<void> _checkFamily() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final familyProvider = Provider.of<FamilyProvider>(context, listen: false);
    final token = authProvider.token;

    // Admin doesn't need family check
    if (authProvider.role == 'admin') {
      setState(() {
        _hasAccess = true;
        _isChecking = false;
      });
      return;
    }

    if (token == null || token.isEmpty) {
      setState(() {
        _hasAccess = false;
        _isChecking = false;
      });
      if (mounted) {
        context.goNamed(Routes.login);
      }
      return;
    }

    // Check family status
    await familyProvider.checkFamily(token: token);

    if (!mounted) return;

    if (familyProvider.hasFamily) {
      setState(() {
        _hasAccess = true;
        _isChecking = false;
      });
    } else {
      setState(() {
        _hasAccess = false;
        _isChecking = false;
      });
      // Redirect to family setup
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please set up your family first before using services'),
            duration: Duration(seconds: 3),
          ),
        );
        context.goNamed(Routes.createFamily);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasAccess) {
      return const Scaffold(
        body: Center(
          child: Text('Redirecting to family setup...'),
        ),
      );
    }

    return widget.child;
  }
}

