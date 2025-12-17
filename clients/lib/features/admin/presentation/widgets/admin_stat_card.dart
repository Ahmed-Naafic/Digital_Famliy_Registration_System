import 'package:flutter/material.dart';

/// Admin Stat Card Widget
/// Displays a statistic card with icon, count, and subtitle
/// Theme-aware and matches the modern design language
class AdminStatCard extends StatelessWidget {
  /// Title of the statistic
  final String title;

  /// Count or value to display
  final String count;

  /// Icon to display
  final IconData icon;

  /// Gradient colors for the icon background
  final List<Color>? gradientColors;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultGradient = [
      colorScheme.primary,
      colorScheme.secondary,
    ];

    return Card(
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      colorScheme.surface.withOpacity(0.3),
                      colorScheme.surface.withOpacity(0.1),
                    ]
                  : [
                      Colors.white,
                      Colors.white,
                    ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors ?? defaultGradient,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                count,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


