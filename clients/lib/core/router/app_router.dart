import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/email_verification_screen.dart';
import '../../features/citizen_dashboard/presentation/dashboard_screen.dart';
import '../../features/citizen_dashboard/presentation/settings_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/birth_registration/presentation/pages/birth_registration_flow_page.dart';
import '../../features/marriage_registration/presentation/pages/marriage_registration_flow_page.dart';
import '../../features/divorce_registration/presentation/pages/divorce_registration_flow_page.dart';
import '../../features/death_registration/presentation/pages/death_registration_flow_page.dart';
import '../../features/family_profile/presentation/pages/family_profile_page.dart';
import '../../features/application_status/presentation/pages/application_status_page.dart';
import '../../features/certificate_viewer/presentation/pages/certificate_viewer_page.dart';
import 'route_names.dart';

/// App Router Configuration
///
/// Uses GoRouter for navigation throughout the app with auth and role guards.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _AuthRouterListenable(),
  redirect: (context, state) {
    final auth = context.read<AuthProvider>();

    // Ensure auth has had a chance to restore session before applying guards.
    if (!auth.isInitialized) {
      if (state.fullPath != '/' && state.fullPath != '/splash') {
        return '/';
      }
      return null;
    }

    final bool loggedIn = auth.isAuthenticated;
    final String role = auth.role;
    final String path = state.fullPath ?? '/';

    final bool isAuthRoute =
        path == '/login' || path == '/register' || path == '/forgot-password';

    // If not logged in, protect all non-auth routes.
    if (!loggedIn && !isAuthRoute) {
      return '/login';
    }

    // If logged in and on auth routes, send to appropriate dashboard.
    if (loggedIn && isAuthRoute) {
      return role == 'admin' ? '/admin' : '/dashboard';
    }

    // Role-based restrictions for admin vs citizen routes.
    if (loggedIn) {
      if (role == 'admin') {
        // Prevent admin from citizen-only flows if needed.
        // (Currently admin can only be blocked from explicit citizen dashboard.)
        if (path == '/dashboard') return '/admin';
      } else {
        // citizen role
        if (path == '/admin') return '/dashboard';
      }
    }

    return null;
  },
  routes: [
    // Splash/Home route
    GoRoute(
      path: '/',
      name: Routes.splash,
      builder: (context, state) {
        final auth = context.read<AuthProvider>();
        // Trigger initialization when app starts.
        if (!auth.isInitialized) {
          auth.init();
        }
        return const SplashScreen();
      },
    ),

    // Auth routes
    GoRoute(
      path: '/login',
      name: Routes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: Routes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/email-verification',
      name: 'email-verification',
      builder: (context, state) => const EmailVerificationScreen(),
    ),

    // Dashboard routes
    GoRoute(
      path: '/dashboard',
      name: Routes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/admin',
      name: Routes.admin,
      builder: (context, state) => const AdminDashboardScreen(),
    ),

    // Citizen service routes
    GoRoute(
      path: '/birth-registration',
      name: Routes.birthRegistration,
      builder: (context, state) => const BirthRegistrationFlowPage(),
    ),
    GoRoute(
      path: '/marriage-registration',
      name: Routes.marriageRegistration,
      builder: (context, state) => const MarriageRegistrationFlowPage(),
    ),
    GoRoute(
      path: '/divorce-registration',
      name: Routes.divorceRegistration,
      builder: (context, state) => const DivorceRegistrationFlowPage(),
    ),
    GoRoute(
      path: '/death-registration',
      name: Routes.deathRegistration,
      builder: (context, state) => const DeathRegistrationFlowPage(),
    ),
    GoRoute(
      path: '/family-profile',
      name: Routes.familyProfile,
      builder: (context, state) => const FamilyProfilePage(),
    ),
    GoRoute(
      path: '/application-status',
      name: Routes.applicationStatus,
      builder: (context, state) => const ApplicationStatusPage(),
    ),
    GoRoute(
      path: '/certificates',
      name: Routes.certificates,
      builder: (context, state) => const CertificateViewerPage(),
    ),
  ],
);

/// Small wrapper to allow GoRouter to listen to auth changes.
class _AuthRouterListenable extends ChangeNotifier {
  _AuthRouterListenable() {
    // Intentionally left simple – the router will read AuthProvider via context.
  }
}


