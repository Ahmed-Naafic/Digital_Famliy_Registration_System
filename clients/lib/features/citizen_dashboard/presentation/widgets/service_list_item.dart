import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/theme_provider.dart';

/// Service List Item Widget
/// Beautiful list item for displaying services in the Services tab
/// Features icon, title, description, and gradient accent
class ServiceListItem extends StatelessWidget {
  /// Icon for the service
  final IconData icon;

  /// Service title
  final String title;

  /// Service description
  final String description;

  /// Background color for the icon
  final Color? iconColor;

  /// Callback when item is tapped
  final VoidCallback? onTap;

  /// Constructor for ServiceListItem
  const ServiceListItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final cardColor = iconColor ?? kPrimaryColor;

    return Card(
      elevation: 0,
      color: isDark ? kDarkCardColor : Colors.white,
      margin: const EdgeInsets.only(bottom: kDefaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cardColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(kDefaultPadding * 1.25),
          child: Row(
            children: [
              // Icon container with gradient
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cardColor,
                      cardColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cardColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: kDefaultPadding * 1.25),

              // Service details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: kSubheadingFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: kBodyFontSize,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: cardColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

