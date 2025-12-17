import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/registration_layout.dart';
import '../provider/marriage_form_provider.dart';
import 'marriage_registration_step1_page.dart';
import 'marriage_registration_step2_page.dart';
import 'marriage_registration_step3_page.dart';
import 'marriage_registration_confirmation_page.dart';

/// Marriage Registration Flow Page
/// Multi-step wizard for marriage registration
class MarriageRegistrationFlowPage extends StatefulWidget {
  const MarriageRegistrationFlowPage({super.key});

  @override
  State<MarriageRegistrationFlowPage> createState() =>
      _MarriageRegistrationFlowPageState();
}

class _MarriageRegistrationFlowPageState
    extends State<MarriageRegistrationFlowPage> {
  final PageController _pageController = PageController();
  final int _totalSteps = 3; // Changed from 4 since confirmation is separate

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep(MarriageFormProvider provider) {
    if (provider.currentStep < _totalSteps - 1) {
      provider.updateCurrentStep(provider.currentStep + 1);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (provider.currentStep == _totalSteps - 1) {
      // Navigate to confirmation screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: provider,
            child: const MarriageRegistrationConfirmationPage(),
          ),
        ),
      );
    }
  }

  void _previousStep(MarriageFormProvider provider) {
    if (provider.currentStep > 0) {
      provider.updateCurrentStep(provider.currentStep - 1);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToServices() {
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MarriageFormProvider(),
      child: Consumer<MarriageFormProvider>(
        builder: (context, provider, child) {
          final currentStep = provider.currentStep;
          final canProceed = currentStep == 0
              ? provider.isStep1Valid
              : currentStep == 1
              ? provider.isStep2Valid
              : provider.isStep3Valid;

          // Sync PageController with provider's currentStep
          if (_pageController.hasClients &&
              _pageController.page?.round() != currentStep) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients &&
                  _pageController.page?.round() != currentStep) {
                _pageController.jumpToPage(currentStep);
              }
            });
          }

          return RegistrationLayout(
            title: 'Marriage Registration',
            currentStep: currentStep + 1,
            totalSteps: _totalSteps + 1, // +1 for confirmation screen
            showPreviousButton: currentStep > 0,
            canProceed: canProceed,
            isFinalStep: currentStep == _totalSteps - 1,
            actionLabel: currentStep == _totalSteps - 1 ? 'Review' : 'Next',
            onAppBarBack: currentStep == 0
                ? _goToServices
                : () => _previousStep(provider),
            onPrevious: () => _previousStep(provider),
            onNext: currentStep == _totalSteps - 1
                ? () => _nextStep(provider)
                : () => _nextStep(provider),
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                provider.updateCurrentStep(index);
              },
              children: const [
                MarriageRegistrationStep1Page(),
                MarriageRegistrationStep2Page(),
                MarriageRegistrationStep3Page(),
              ],
            ),
          );
        },
      ),
    );
  }
}
