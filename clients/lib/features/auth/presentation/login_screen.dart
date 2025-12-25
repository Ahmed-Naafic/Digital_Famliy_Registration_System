import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/constants.dart';
import '../../../core/theme_provider.dart';
import '../../../core/router/route_names.dart';
import '../auth_provider.dart';
import '../../family/providers/family_provider.dart';

/// Login Screen
/// Theme-aware login screen with gradient backgrounds
/// Features email and password form with validation
/// Adapts to light and dark modes
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final email = formData['email'] as String;
      final password = formData['password'] as String;

      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.login(email: email, password: password);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: kSuccessColor,
          ),
        );

        // Navigate based on role
        final role = authProvider.role;
        debugPrint('🔐 Login - User role: $role');
        debugPrint('🔐 Login - User: ${authProvider.user?.name}');
        debugPrint('🔐 Login - Token exists: ${authProvider.token != null}');
        
        if (role == 'admin') {
          debugPrint('🔐 Login - Redirecting to admin dashboard');
          context.goNamed(Routes.admin);
        } else {
          debugPrint('🔐 Login - Redirecting to citizen dashboard');
          // Check if user has a family (citizens only)
          final token = authProvider.token;
          
          if (token != null && token.isNotEmpty) {
            try {
              // Safely access FamilyProvider
              final familyProvider = Provider.of<FamilyProvider>(context, listen: false);
              await familyProvider.checkFamily(token: token);
              
              if (!mounted) return;
              
              // Navigate based on family status
              if (familyProvider.hasFamily) {
                context.goNamed(Routes.dashboard);
              } else {
                // Redirect to create family page
                context.goNamed(Routes.createFamily);
              }
            } catch (e) {
              // If FamilyProvider is not available, just go to dashboard
              debugPrint('⚠️ FamilyProvider not available: $e');
              if (mounted) {
                context.goNamed(Routes.dashboard);
              }
            }
          } else {
            context.goNamed(Routes.dashboard);
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: kErrorColor,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fix the errors in the form'),
            backgroundColor: kErrorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? kDarkBackgroundColor : kBackgroundColor,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kDefaultPadding * 2),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: kDefaultPadding * 2),

                  // App Logo/Icon
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [kPrimaryColor, kSecondaryColor],
                        ),
                      ),
                      child: const Icon(
                        Icons.family_restroom,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: kDefaultPadding * 2),

                  // Welcome text
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: kHeadingFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kDefaultPadding * 0.5),
                  Text(
                    'Please sign in to continue',
                    style: TextStyle(
                      color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey[700],
                      fontSize: kBodyFontSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kDefaultPadding * 3),

                  // Email field
                  FormBuilderTextField(
                    name: 'email',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                      prefixIcon: Icon(Icons.email, color: isDark ? Colors.grey : Colors.grey[600]),
                      filled: true,
                      fillColor: isDark ? kDarkCardColor : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Email is required'),
                      FormBuilderValidators.email(errorText: 'Please enter a valid email'),
                    ]),
                  ),
                  const SizedBox(height: kDefaultPadding),

                  // Password field
                  FormBuilderTextField(
                    name: 'password',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                      prefixIcon: Icon(Icons.lock, color: isDark ? Colors.grey : Colors.grey[600]),
                      filled: true,
                      fillColor: isDark ? kDarkCardColor : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                      ),
                    ),
                    obscureText: true,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Password is required'),
                      FormBuilderValidators.minLength(
                        6,
                        errorText: 'Password must be at least 6 characters',
                      ),
                    ]),
                  ),
                  const SizedBox(height: kDefaultPadding * 0.5),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: isDark ? kAccentColor : kPrimaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: kDefaultPadding * 2),

                  // Login button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: kDefaultPadding * 1.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: kBodyFontSize + 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: kDefaultPadding * 1.5),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () => context.pushNamed(Routes.register),
                        child: Text(
                          'Register',
                          style: TextStyle(color: isDark ? kAccentColor : kPrimaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
