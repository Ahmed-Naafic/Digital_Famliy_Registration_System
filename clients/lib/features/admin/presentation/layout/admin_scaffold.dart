import 'package:flutter/material.dart';
import '../widgets/admin_sidebar.dart';

/// Admin Scaffold Widget
/// Reusable scaffold for admin pages with consistent AppBar and Drawer
/// Fully theme-aware and matches Material 3 design
class AdminScaffold extends StatelessWidget {
  /// Page title to display in AppBar
  final String title;

  /// Body content of the page
  final Widget body;

  /// Actions to display in AppBar (optional)
  final List<Widget>? actions;

  /// Floating action button (optional)
  final Widget? floatingActionButton;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: isDark ? 0 : 1,
        backgroundColor: isDark ? colorScheme.surface : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      drawer: const AdminSidebar(),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}


