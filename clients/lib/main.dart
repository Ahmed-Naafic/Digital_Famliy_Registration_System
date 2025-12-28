import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/utils/theme.dart';
import 'core/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/application_service.dart';
import 'features/auth/auth_provider.dart';
import 'features/applications/providers/application_provider.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget of the application
/// Wraps MaterialApp with multiple ChangeNotifierProviders for AuthProvider and ThemeProvider
/// Uses Consumer to reactively switch between LoginScreen and DashboardScreen
/// Applies light/dark theme based on ThemeProvider state
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide AuthProvider for authentication state
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Provide ThemeProvider for theme management
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Provide ApplicationService for applications and certificates
        ChangeNotifierProvider(create: (_) => ApplicationService()),
        // Provide ApplicationProvider for fetching applications from backend
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Digital Family System',
            // Apply light or dark theme based on ThemeProvider
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            // Use GoRouter for navigation
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
