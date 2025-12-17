import 'package:flutter/material.dart';
import 'pages/admin_dashboard_page.dart';

/// Admin Dashboard Screen
/// Main entry point for admin interface
/// Uses AdminDashboardPage which includes AdminScaffold
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboardPage();
  }
}

