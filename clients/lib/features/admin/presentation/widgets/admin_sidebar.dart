import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/theme_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/auth_provider.dart';

/// Admin Sidebar Widget
/// Navigation drawer for admin interface
/// Theme-aware with Material 3 design
class AdminSidebar extends StatefulWidget {
  const AdminSidebar({super.key});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index, BuildContext context) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);

    switch (index) {
      case 0:
        context.goNamed(Routes.admin);
        break;
      case 1:
        // Navigate to Citizens page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Citizens page coming soon')),
        );
        break;
      case 2:
        // Navigate to Families page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Families page coming soon')),
        );
        break;
      case 3:
        // Navigate to Certificates page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificates page coming soon')),
        );
        break;
      case 4:
        // Navigate to Services page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Services page coming soon')),
        );
        break;
      case 5:
        // Navigate to Requests page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Requests page coming soon')),
        );
        break;
      case 6:
        // Navigate to Admin Users page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin Users page coming soon')),
        );
        break;
      case 7:
        // Navigate to Settings
        context.pushNamed(Routes.settings);
        break;
      case 8:
        // Logout
        _handleLogout(context);
        break;
    }
  }

  void _handleLogout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    context.goNamed(Routes.login);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
        backgroundColor: kSuccessColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    final menuItems = [
      {'title': 'Dashboard', 'icon': Icons.dashboard},
      {'title': 'Citizens', 'icon': Icons.people},
      {'title': 'Families', 'icon': Icons.family_restroom},
      {'title': 'Certificates', 'icon': Icons.description},
      {'title': 'Services', 'icon': Icons.apps},
      {'title': 'Requests', 'icon': Icons.assignment},
      {'title': 'Admin Users', 'icon': Icons.admin_panel_settings},
      {'title': 'Settings', 'icon': Icons.settings},
      {'title': 'Logout', 'icon': Icons.logout},
    ];

    return Drawer(
      backgroundColor: isDark ? colorScheme.surface : colorScheme.surface,
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                ],
              ),
            ),
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (authProvider.user != null)
                  Text(
                    authProvider.user!.name,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...menuItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = _selectedIndex == index;
                  final isLogout = index == 8;

                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: colorScheme.primary.withOpacity(0.1),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isLogout
                            ? kErrorColor.withOpacity(0.1)
                            : isSelected
                                ? colorScheme.primary.withOpacity(0.2)
                                : colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: isLogout
                            ? kErrorColor
                            : isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface.withOpacity(0.7),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      item['title'] as String,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isLogout
                                ? kErrorColor
                                : isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                            fontWeight: isSelected || isLogout
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                    onTap: () => _onItemTapped(index, context),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

