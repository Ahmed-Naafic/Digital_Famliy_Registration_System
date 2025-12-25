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

  /// Whether the service is disabled
  final bool isDisabled;

  /// Constructor for ServiceListItem
  const ServiceListItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final effectiveColor = isDisabled ? Colors.grey : (iconColor ?? kPrimaryColor);
    final textColor = isDisabled
        ? (isDark ? Colors.grey[600] : Colors.grey[500])
        : (isDark ? Colors.white : Colors.black87);
    final descriptionColor = isDisabled
        ? Colors.orange[300]
        : (isDark ? Colors.grey[400] : Colors.grey[600]);

    return Card(
      elevation: 0,
      color: isDark ? kDarkCardColor : Colors.white,
      margin: const EdgeInsets.only(bottom: kDefaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: effectiveColor.withOpacity(isDisabled ? 0.1 : 0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(kDefaultPadding * 1.25),
          child: Row(
            children: [
              // Icon container with gradient
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          effectiveColor,
                          effectiveColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: effectiveColor.withOpacity(isDisabled ? 0.1 : 0.3),
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
                  if (isDisabled)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.block,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: kDefaultPadding * 1.25),

              // Service details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: textColor,
                              fontSize: kSubheadingFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isDisabled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Disabled',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color: descriptionColor,
                        fontSize: kBodyFontSize,
                        fontStyle: isDisabled ? FontStyle.italic : FontStyle.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow icon or blocked icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: effectiveColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDisabled ? Icons.block : Icons.arrow_forward_ios,
                  size: 16,
                  color: effectiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

