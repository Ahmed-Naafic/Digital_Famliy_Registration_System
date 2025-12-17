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

  /// Constructor for QuickActionCard
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = backgroundColor ?? kPrimaryColor;
    
    return Card(
      elevation: 0,
      color: kDarkCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor.withOpacity(0.2),
                cardColor.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: cardColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: kDefaultPadding * 0.75),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: kBodyFontSize,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
