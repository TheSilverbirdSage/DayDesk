import 'package:get/get.dart';

import '../../data/services/onboarding_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _continueAfterSplash();
  }

  Future<void> _continueAfterSplash() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    final hasCompletedOnboarding = Get.isRegistered<OnboardingService>() &&
        Get.find<OnboardingService>().hasCompletedOnboarding.value;
    Get.offAllNamed(
      hasCompletedOnboarding ? AppRoutes.home : AppRoutes.onboarding,
    );
  }
}
