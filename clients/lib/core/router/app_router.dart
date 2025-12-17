import 'package:go_router/go_router.dart';
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
/// Uses GoRouter for navigation throughout the app
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash/Home route
    GoRoute(
      path: '/',
      name: Routes.splash,
      builder: (context, state) => const SplashScreen(),
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

