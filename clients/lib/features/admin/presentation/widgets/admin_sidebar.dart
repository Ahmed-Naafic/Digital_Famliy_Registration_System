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
    try {
      // Get GoRouter instance before closing drawer
      final router = GoRouter.of(context);
      debugPrint('GoRouter found, navigating to index: $index');
      
      // Navigate first, then close drawer
      switch (index) {
        case 0:
          router.go('/admin');
          Navigator.pop(context);
          break;
        case 1:
          // Navigate to Citizens page
          debugPrint('Navigating to citizens page: /admin/citizens');
          router.go('/admin/citizens');
          Navigator.pop(context);
          break;
      case 2:
        // Navigate to Families page
        debugPrint('Navigating to families page: /admin/families');
        router.go('/admin/families');
        Navigator.pop(context);
        break;
      case 3:
        // Navigate to Certificates page
        debugPrint('Navigating to certificates page: /admin/certificates');
        router.go('/admin/certificates');
        Navigator.pop(context);
        break;
      case 4:
        // Navigate to Services page
        debugPrint('Navigating to services page: /admin/services');
        router.go('/admin/services');
        Navigator.pop(context);
        break;
        case 5:
          // Navigate to Applications page
          debugPrint('Navigating to applications page: /admin/applications');
          router.go('/admin/applications');
          Navigator.pop(context);
          break;
      case 6:
        // Navigate to Admin Users page
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin Users page coming soon')),
        );
        break;
      case 7:
        // Navigate to Settings
        router.push('/settings');
        Navigator.pop(context);
        break;
      case 8:
        // Logout
          Navigator.pop(context);
          _handleLogout(context);
          break;
      }
    } catch (e) {
      debugPrint('Error navigating: $e');
      // Fallback: try direct path navigation
      try {
        // Fallback already uses direct paths, no change needed
        Navigator.pop(context);
      } catch (e2) {
        debugPrint('Fallback navigation also failed: $e2');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation error: $e')),
        );
      }
    }
  }

  void _handleLogout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    final router = GoRouter.of(context);
    router.go('/login');
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
      {'title': 'Applications', 'icon': Icons.assignment},
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
            child: Builder(
              builder: (builderContext) {
                return ListView(
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
                        onTap: () {
                          debugPrint('Admin sidebar item tapped: index=$index, title=${item['title']}');
                          _onItemTapped(index, builderContext);
                        },
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

