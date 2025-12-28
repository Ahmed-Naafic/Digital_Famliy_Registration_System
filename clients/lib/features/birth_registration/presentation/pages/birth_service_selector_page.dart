import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/theme_provider.dart';
import '../../../../core/router/route_names.dart';
import 'package:provider/provider.dart';

/// Birth Service Selector Page
/// Shows options: Birth Record Registration and Birth Certificate Generation
class BirthServiceSelectorPage extends StatelessWidget {
  const BirthServiceSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? kDarkBackgroundColor : kBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? kDarkCardColor : kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.goNamed(Routes.dashboard),
        ),
        title: const Text(
          'Birth Services',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Select a Service',
              style: TextStyle(
                fontSize: kHeadingFontSize,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose Birth Record Registration or Birth Certificate Generation',
              style: TextStyle(
                fontSize: kBodyFontSize,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: kDefaultPadding * 2),

            // Birth Record Registration Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => context.goNamed(Routes.birthRegistration),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_document,
                          color: kPrimaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: kDefaultPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Birth Record Registration',
                              style: TextStyle(
                                fontSize: kSubheadingFontSize,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Register a new birth event. Requires admin approval.',
                              style: TextStyle(
                                fontSize: kBodyFontSize,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: kDefaultPadding),

            // Birth Certificate Generation Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => context.goNamed(Routes.birthCertificate),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kAccentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.description,
                          color: kAccentColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: kDefaultPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Birth Certificate',
                              style: TextStyle(
                                fontSize: kSubheadingFontSize,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Generate certificate from approved birth record. Instant issue.',
                              style: TextStyle(
                                fontSize: kBodyFontSize,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: kAccentColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

