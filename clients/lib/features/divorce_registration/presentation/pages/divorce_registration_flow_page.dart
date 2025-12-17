import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/registration_layout.dart';
import '../provider/divorce_form_provider.dart';
import 'divorce_registration_step1_page.dart';
import 'divorce_registration_step2_page.dart';
import 'divorce_registration_step3_page.dart';
import 'divorce_registration_confirmation_page.dart';

/// Divorce Registration Flow Page
class DivorceRegistrationFlowPage extends StatefulWidget {
  const DivorceRegistrationFlowPage({super.key});

  @override
  State<DivorceRegistrationFlowPage> createState() =>
      _DivorceRegistrationFlowPageState();
}

class _DivorceRegistrationFlowPageState
    extends State<DivorceRegistrationFlowPage> {
  final PageController _pageController = PageController();
  final int _totalSteps = 3; // Changed from 4 since confirmation is separate

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep(DivorceFormProvider provider) {
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
            child: const DivorceRegistrationConfirmationPage(),
          ),
        ),
      );
    }
  }

  void _previousStep(DivorceFormProvider provider) {
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
      create: (_) => DivorceFormProvider(),
      child: Consumer<DivorceFormProvider>(
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
            title: 'Divorce Registration',
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
                DivorceRegistrationStep1Page(),
                DivorceRegistrationStep2Page(),
                DivorceRegistrationStep3Page(),
              ],
            ),
          );
        },
      ),
    );
  }
}
