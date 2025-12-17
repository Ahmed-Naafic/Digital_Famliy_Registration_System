import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/theme_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/auth_provider.dart';

/// Sidebar Widget
/// Modern theme-aware drawer widget with gradient header
/// Adapts to light and dark modes
class SidebarWidget extends StatelessWidget {
  /// Constructor for SidebarWidget
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Drawer(
      backgroundColor: isDark ? kDarkBackgroundColor : kBackgroundColor,
      child: Column(
        children: [
          // ====================================================================
          // DRAWER HEADER
          // ====================================================================
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPrimaryColor, kSecondaryColor],
              ),
            ),
            child: DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App icon with rounded background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.family_restroom,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: kDefaultPadding * 0.75),
                  // App title
                  const Text(
                    'Digital Family System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: kSubheadingFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kDefaultPadding * 0.25),
                  // User name if logged in
                  if (authProvider.user != null)
                    Text(
                      authProvider.user!.name,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: kBodyFontSize,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ====================================================================
          // NAVIGATION MENU ITEMS
          // ====================================================================
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Settings option
                ListTile(
                  textColor: isDark ? Colors.white : Colors.black87,
                  iconColor: kPrimaryColor,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: kPrimaryColor,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Settings',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed(Routes.settings);
                  },
                ),

                // Help & Support option
                ListTile(
                  textColor: isDark ? Colors.white : Colors.black87,
                  iconColor: kAccentColor,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kAccentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: kAccentColor,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Help & Support',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help & Support coming soon'),
                      ),
                    );
                  },
                ),

                // About option
                ListTile(
                  textColor: isDark ? Colors.white : Colors.black87,
                  iconColor: kSecondaryColor,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kSecondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: kSecondaryColor,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'About',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: isDark ? kDarkCardColor : Colors.white,
                        title: Text(
                          'About',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        content: Text(
                          'Digital Family System\nVersion 1.0.0\n\nA comprehensive platform for managing family records and certificates.',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),

                // Logout option
                ListTile(
                  textColor: isDark ? Colors.white : Colors.black87,
                  iconColor: kErrorColor,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kErrorColor.withOpacity(0.2),
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
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    authProvider.logout();
                    context.goNamed(Routes.login);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged out successfully'),
                        backgroundColor: Colors.green,
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
