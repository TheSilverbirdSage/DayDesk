import 'package:get/get.dart';

import 'local_storage_service.dart';

class OnboardingService extends GetxService {
  final hasCompletedOnboarding = false.obs;
  final name = ''.obs;
  final currency = 'USD'.obs;
  final dailyTaskGoal = 8.obs;
  final categories = <String>['Work', 'Finance'].obs;
  final dailyBudget = 45.0.obs;
  final savingsGoal = 2500.0.obs;

  @override
  void onInit() {
    super.onInit();
    _restoreProfile();
  }

  Future<void> saveProfile({
    required String userName,
    required String selectedCurrency,
    required int taskGoal,
    required List<String> selectedCategories,
    required double budget,
    required double savings,
  }) async {
    name.value = userName.trim().isEmpty ? 'Alex' : userName.trim();
    currency.value = selectedCurrency;
    dailyTaskGoal.value = taskGoal;
    categories.assignAll(selectedCategories);
    dailyBudget.value = budget;
    savingsGoal.value = savings;
    hasCompletedOnboarding.value = true;

    final storage = Get.find<LocalStorageService>();
    await storage.saveOnboardingProfile(
      userName: name.value,
      selectedCurrency: currency.value,
      taskGoal: dailyTaskGoal.value,
      selectedCategories: categories.toList(),
      budget: dailyBudget.value,
      savings: savingsGoal.value,
    );
    await storage.setHasCompletedOnboarding(true);
  }

  Future<void> skip() async {
    hasCompletedOnboarding.value = true;
    await Get.find<LocalStorageService>().setHasCompletedOnboarding(true);
  }

  void _restoreProfile() {
    final storage = Get.find<LocalStorageService>();
    hasCompletedOnboarding.value = storage.hasCompletedOnboarding;

    final profile = storage.getOnboardingProfile();
    if (profile == null) return;

    name.value = (profile['userName'] as String?)?.trim().isNotEmpty == true
        ? profile['userName'] as String
        : 'Alex';
    currency.value = profile['selectedCurrency'] as String? ?? 'USD';
    dailyTaskGoal.value = profile['taskGoal'] as int? ?? 8;
    categories.assignAll(
      (profile['selectedCategories'] as List?)?.whereType<String>().toList() ??
          const ['Work', 'Finance'],
    );
    dailyBudget.value = (profile['budget'] as num?)?.toDouble() ?? 45.0;
    savingsGoal.value = (profile['savings'] as num?)?.toDouble() ?? 2500.0;
  }
}
