import 'package:flutter/material.dart';

/// Family Guard Widget
/// CRVS model: No longer checks for family - always allows access
/// Kept for backward compatibility with existing registration flows
class FamilyGuard extends StatelessWidget {
  final Widget child;

  const FamilyGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // CRVS model: Always allow access (no family check needed)
    return child;
  }
}
