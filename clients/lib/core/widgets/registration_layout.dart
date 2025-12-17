import 'package:flutter/material.dart';

/// Registration Layout Widget
/// Reusable layout for all registration steps
/// Provides consistent AppBar, step indicator, body, and action buttons
class RegistrationLayout extends StatelessWidget {
  /// Title to display in AppBar
  final String title;

  /// Current step number (1-based)
  final int currentStep;

  /// Total number of steps
  final int totalSteps;

  /// Main content widget
  final Widget body;

  /// Whether the Previous button should be shown
  final bool showPreviousButton;

  /// Whether the next/submit button should be enabled
  final bool canProceed;

  /// Callback when AppBar back button is pressed
  final VoidCallback? onAppBarBack;

  /// Callback when Previous button is pressed
  final VoidCallback? onPrevious;

  /// Callback when next/submit button is pressed
  final VoidCallback? onNext;

  /// Label for the action button (Next or Submit)
  final String actionLabel;

  /// Whether this is the final step
  final bool isFinalStep;

  const RegistrationLayout({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    required this.body,
    this.showPreviousButton = false,
    this.canProceed = false,
    this.onAppBarBack,
    this.onPrevious,
    this.onNext,
    this.actionLabel = 'Next',
    this.isFinalStep = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onAppBarBack,
        ),
      ),
      body: Column(
        children: [
          // Step Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
              ),
            ),
            child: Column(
              children: [
                // Progress Bar
                Row(
                  children: List.generate(totalSteps, (index) {
                    final stepNumber = index + 1;
                    final isActive = stepNumber == currentStep;
                    final isCompleted = stepNumber < currentStep;
                    final isLast = stepNumber == totalSteps;

                    return Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Connector Line (positioned between circles)
                          if (!isLast)
                            Positioned.fill(
                              left: 16, // Half of circle width
                              right: -16, // Extend into next step's space
                              child: Center(
                                child: Container(
                                  height: 2,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? colorScheme.primary
                                        : colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),
                            ),
                          // Step Circle (centered)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive || isCompleted
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest,
                            ),
                            child: isCompleted
                                ? Center(
                                    child: Icon(
                                      Icons.check,
                                      color: colorScheme.onPrimary,
                                      size: 18,
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      '$stepNumber',
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: isActive
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface.withOpacity(
                                                0.5,
                                              ),
                                        fontWeight: FontWeight.bold,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                // Step Text
                Text(
                  'Step $currentStep of $totalSteps',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(child: body),

          // Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button (only show if not on step 1)
                  if (showPreviousButton)
                    OutlinedButton.icon(
                      onPressed: onPrevious,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // Next/Submit Button
                  ElevatedButton.icon(
                    onPressed: canProceed ? onNext : null,
                    icon: Icon(isFinalStep ? Icons.check : Icons.arrow_forward),
                    label: Text(actionLabel),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
