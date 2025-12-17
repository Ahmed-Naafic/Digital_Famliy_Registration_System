import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/theme_provider.dart';
import '../../../auth/auth_provider.dart';

/// Admin Drawer Widget
/// Theme-aware drawer for admin navigation
/// Matches the design language of the citizen sidebar
class AdminDrawer extends StatelessWidget {
  /// Currently selected page index
  final int selectedIndex;

  /// Callback when a menu item is tapped
  final Function(int) onItemSelected;

  const AdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    final menuItems = [
      {'title': 'Dashboard', 'icon': Icons.dashboard, 'index': 0},
      {'title': 'Applications', 'icon': Icons.assignment, 'index': 1},
      {'title': 'Users', 'icon': Icons.people, 'index': 2},
      {'title': 'Certificates', 'icon': Icons.description, 'index': 3},
      {'title': 'Reports', 'icon': Icons.assessment, 'index': 4},
      {'title': 'Settings', 'icon': Icons.settings, 'index': 5},
    ];

    return Drawer(
      backgroundColor: isDark ? kDarkBackgroundColor : kBackgroundColor,
      child: Column(
        children: [
          // Drawer Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
            ),
            child: DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 48,
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
          ),

          // Navigation Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...menuItems.map((item) {
                  final isSelected = selectedIndex == item['index'] as int;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: colorScheme.primary.withOpacity(0.1),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary.withOpacity(0.2)
                            : colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.7),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      item['title'] as String,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isSelected
                                ? colorScheme.primary
                                : (isDark ? Colors.white : Colors.black87),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onItemSelected(item['index'] as int);
                    },
                  );
                }),
                Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),

                // Logout option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kErrorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: kErrorColor,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    authProvider.logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged out successfully'),
                        backgroundColor: kSuccessColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


