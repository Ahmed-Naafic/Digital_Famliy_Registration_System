import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/constants.dart';
import '../../../core/theme_provider.dart';
import '../../../core/router/route_names.dart';

/// Email Verification Screen
/// Theme-aware screen for email verification
/// Adapts to light and dark modes
class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  void _handleResendEmail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification email sent! Please check your inbox.'),
        backgroundColor: kSuccessColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? kDarkBackgroundColor : kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        title: Text(
          'Email Verification',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [kPrimaryColor.withOpacity(0.3), kSecondaryColor.withOpacity(0.3)],
                    ),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: kDefaultPadding * 2),

              // Verification message
              Text(
                'Please verify your email',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: kHeadingFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kDefaultPadding),

              // Description text
              Text(
                'We have sent a verification email to your registered email address. '
                'Please check your inbox and click on the verification link to activate your account.',
                style: TextStyle(
                  color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey[700],
                  fontSize: kBodyFontSize,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kDefaultPadding * 2),

              // Resend verification email button
              ElevatedButton(
                onPressed: () => _handleResendEmail(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: kDefaultPadding * 1.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Resend Verification Email',
                  style: TextStyle(
                    fontSize: kBodyFontSize + 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: kDefaultPadding),

              // Back to login button
              TextButton(
                onPressed: () => context.goNamed(Routes.login),
                child: Text(
                  'Back to Login',
                  style: TextStyle(color: isDark ? Colors.white70 : kPrimaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
