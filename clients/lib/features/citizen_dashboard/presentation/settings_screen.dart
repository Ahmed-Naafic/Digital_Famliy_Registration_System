import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme_provider.dart';
import '../../../../core/utils/constants.dart';

/// Settings Screen
/// Displays app settings including dark mode toggle
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? kDarkBackgroundColor
          : kBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: themeProvider.isDarkMode
            ? kDarkCardColor
            : kPrimaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          // Appearance Section
          Card(
            color: themeProvider.isDarkMode
                ? kDarkCardColor
                : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Text(
                    'Appearance',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                      fontSize: kSubheadingFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(height: 1),
                // Dark Mode Toggle
                SwitchListTile(
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    themeProvider.isDarkMode
                        ? 'Dark theme is enabled'
                        : 'Light theme is enabled',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: kPrimaryColor,
                  secondary: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: kDefaultPadding),

          // General Settings Section
          Card(
            color: themeProvider.isDarkMode
                ? kDarkCardColor
                : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Text(
                    'General',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                      fontSize: kSubheadingFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: kPrimaryColor,
                  ),
                  title: Text(
                    'Notifications',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications settings')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.language,
                    color: kPrimaryColor,
                  ),
                  title: Text(
                    'Language',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Language settings')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: kDefaultPadding),

          // About Section
          Card(
            color: themeProvider.isDarkMode
                ? kDarkCardColor
                : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Text(
                    'About',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                      fontSize: kSubheadingFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.info,
                    color: kPrimaryColor,
                  ),
                  title: Text(
                    'App Version',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  subtitle: const Text('1.0.0'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: themeProvider.isDarkMode
                            ? kDarkCardColor
                            : Colors.white,
                        title: Text(
                          'Digital Family System',
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        content: Text(
                          'Version 1.0.0\n\nA comprehensive platform for managing family records and certificates.',
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? Colors.white70
                                : Colors.black87,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}


