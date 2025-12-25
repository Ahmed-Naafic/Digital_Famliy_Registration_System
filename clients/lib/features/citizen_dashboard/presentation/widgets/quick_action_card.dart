import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

/// Quick Action Card Widget
/// Modern dark-themed card widget for displaying quick actions
/// Features gradient backgrounds and rounded corners matching the dark theme
class QuickActionCard extends StatelessWidget {
  /// Icon to display on the card
  final IconData icon;

  /// Title text for the card
  final String title;

  /// Background color for the card (defaults to primary color)
  final Color? backgroundColor;

  /// Callback function when card is tapped
  final VoidCallback? onTap;

  /// Whether the card is disabled
  final bool isDisabled;

  /// Disabled message to show
  final String? disabledMessage;

  /// Constructor for QuickActionCard
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.backgroundColor,
    this.onTap,
    this.isDisabled = false,
    this.disabledMessage,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = backgroundColor ?? kPrimaryColor;
    final effectiveColor = isDisabled ? Colors.grey : cardColor;
    final iconColor = isDisabled ? Colors.grey[400]! : Colors.white;
    final textColor = isDisabled ? Colors.grey[400]! : Colors.white;
    
    return Card(
      elevation: 0,
      color: kDarkCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                effectiveColor.withOpacity(isDisabled ? 0.1 : 0.2),
                effectiveColor.withOpacity(isDisabled ? 0.05 : 0.1),
              ],
            ),
            border: Border.all(
              color: effectiveColor.withOpacity(isDisabled ? 0.2 : 0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: effectiveColor.withOpacity(isDisabled ? 0.1 : 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: iconColor,
                    ),
                  ),
                  if (isDisabled)
                    Positioned(
                      right: 0,
                      top: 0,
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
              const SizedBox(height: kDefaultPadding * 0.75),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: kBodyFontSize,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isDisabled && disabledMessage != null) ...[
                const SizedBox(height: 4),
                Text(
                  disabledMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange[300],
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
