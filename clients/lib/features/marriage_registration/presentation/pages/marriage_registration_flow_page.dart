import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/registration_layout.dart';
import '../provider/marriage_form_provider.dart';
import 'marriage_registration_step0_page.dart'; // Applicant
import 'marriage_registration_step1_page.dart'; // Groom
import 'marriage_registration_step2_page.dart'; // Bride
import 'marriage_registration_step3_page.dart'; // Wali
import 'marriage_registration_step4_page.dart'; // Witnesses
import 'marriage_registration_step5_page.dart'; // Sheikh
import 'marriage_registration_step6_page.dart'; // Meher
import 'marriage_registration_step7_page.dart'; // Marriage Details
import 'marriage_registration_step8_page.dart'; // Documents
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
  final int _totalSteps =
      9; // Step 0: Applicant, 1: Groom, 2: Bride, 3: Wali, 4: Witnesses, 5: Sheikh, 6: Meher, 7: Marriage Details, 8: Documents

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
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (newContext) => ChangeNotifierProvider.value(
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
              ? provider.isApplicantValid
              : currentStep == 1
              ? provider.isStep1Valid
              : currentStep == 2
              ? provider.isStep2Valid
              : currentStep == 3
              ? provider.isStep3Valid
              : currentStep == 4
              ? provider.isStep4Valid
              : currentStep == 5
              ? provider.isStep5Valid
              : currentStep == 6
              ? provider.isStep6Valid
              : currentStep == 7
              ? provider.isStep7Valid
              : provider.isStep8Valid;

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
                MarriageRegistrationStep0Page(), // Step 0: Applicant Information
                MarriageRegistrationStep1Page(), // Step 1: Groom Information
                MarriageRegistrationStep2Page(), // Step 2: Bride Information
                MarriageRegistrationStep3Page(), // Step 3: Wali Information
                MarriageRegistrationStep4Page(), // Step 4: Witnesses Information
                MarriageRegistrationStep5Page(), // Step 5: Sheikh Information
                MarriageRegistrationStep6Page(), // Step 6: Meher
                MarriageRegistrationStep7Page(), // Step 7: Marriage Details
                MarriageRegistrationStep8Page(), // Step 8: Documents
              ],
            ),
          );
        },
      ),
    );
  }
}
