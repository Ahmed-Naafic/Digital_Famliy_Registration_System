import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/constants.dart';
import '../../../core/theme_provider.dart';
import '../../../core/router/route_names.dart';
import '../auth_provider.dart';

/// Splash/Onboarding Screen
/// Theme-aware onboarding screen with gradient backgrounds
/// Features app branding and "Get Started" button
/// Adapts to light and dark modes
/// Automatically navigates to LoginScreen or DashboardScreen based on auth state
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Current page index for onboarding
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  /// Initialize auth and navigate based on token state
  Future<void> _initializeAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Wait for auth to initialize if not already done
    if (!authProvider.isInitialized) {
      await authProvider.init();
    }

    // Wait a moment for UI to settle, then navigate
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate based on token state
    if (!mounted) return;
    await _navigateToNextScreen();
  }

  /// Navigate to the next screen based on auth state
  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Ensure auth is initialized
      if (!authProvider.isInitialized) {
        await authProvider.init();
      }
      
      // Strict check: token must exist AND be non-empty
      if (authProvider.isLoggedIn) {
        final role = authProvider.role;
        debugPrint('🔐 Splash - User logged in');
        debugPrint('🔐 Splash - Role: $role');
        debugPrint('🔐 Splash - User: ${authProvider.user?.name}');
        
        // CRVS model: No family check needed
        if (role == 'citizen') {
          debugPrint('🔐 Splash - User is citizen, redirecting to dashboard');
          if (mounted) context.goNamed(Routes.dashboard);
        } else if (role == 'admin') {
          // Admin goes directly to admin dashboard
          debugPrint('🔐 Splash - User is admin, redirecting to admin dashboard');
          if (mounted) context.goNamed(Routes.admin);
        } else {
          // Unknown role, default to login
          debugPrint('🔐 Splash - Unknown role: $role, redirecting to login');
          if (mounted) context.goNamed(Routes.login);
        }
      } else {
        // Not logged in - go to login
        if (mounted) context.goNamed(Routes.login);
      }
    } catch (e) {
      debugPrint('Error navigating from splash screen: $e');
      // Fallback to login if there's an error
      if (mounted) {
        context.goNamed(Routes.login);
      }
    }
  }

  /// Onboarding pages data
  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'The best way to manage your family',
      'description': 'Keep all your family records and certificates in one secure place.',
      'icon': Icons.family_restroom,
    },
    {
      'title': 'Easy Registration Process',
      'description': 'Register births, marriages, and other events with ease.',
      'icon': Icons.assignment_turned_in,
    },
    {
      'title': 'Access Certificates Anytime',
      'description': 'View and download your certificates whenever you need them.',
      'icon': Icons.description,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [kDarkBackgroundColor, kDarkCardColor]
                : [kBackgroundColor, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _navigateToNextScreen,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ),
              ),

              // PageView for onboarding
              Expanded(
                child: PageView.builder(
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.all(kDefaultPadding * 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Gradient icon background
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  kPrimaryColor.withOpacity(0.3),
                                  kSecondaryColor.withOpacity(0.3),
                                ],
                              ),
                            ),
                            child: Icon(
                              page['icon'] as IconData,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: kDefaultPadding * 3),

                          // Title
                          Text(
                            page['title'] as String,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: kHeadingFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: kDefaultPadding * 1.5),

                          // Description
                          Text(
                            page['description'] as String,
                            style: TextStyle(
                              color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey[700],
                              fontSize: kBodyFontSize + 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? kPrimaryColor
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: kDefaultPadding * 2),

              // Get Started button
              Padding(
                padding: const EdgeInsets.all(kDefaultPadding * 2),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToNextScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: kDefaultPadding * 1.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: kBodyFontSize + 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

