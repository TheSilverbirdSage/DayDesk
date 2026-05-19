import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/onboarding_service.dart';
import '../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final nameController = TextEditingController();
  final dailyBudgetController = TextEditingController(text: '45.00');
  final savingsGoalController = TextEditingController(text: '2500');
  final categoryController = TextEditingController();
  final categoryFocusNode = FocusNode();

  final step = 0.obs;
  final selectedCurrency = 'USD'.obs;
  final dailyTaskGoal = 8.0.obs;
  final selectedCategories = <String>['Work', 'Finance'].obs;
  final categoryOptions = <String>['Work', 'Personal', 'Health', 'Finance'].obs;
  final isAddingCategory = false.obs;

  final currencies = const ['USD', 'EUR', 'GBP', 'Other'];

  void next() {
    if (step.value == 1 && categoryController.text.trim().isNotEmpty) {
      addCategory();
    }
    if (step.value < 3) {
      step.value += 1;
      return;
    }
    finish();
  }

  void back() {
    if (step.value == 0) return;
    step.value -= 1;
  }

  Future<void> skip() async {
    await Get.find<OnboardingService>().skip();
    Get.offAllNamed(AppRoutes.home);
  }

  void selectCurrency(String currency) {
    selectedCurrency.value = currency;
  }

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
      return;
    }
    selectedCategories.add(category);
  }

  void showCategoryInput() {
    isAddingCategory.value = true;
    Future<void>.delayed(Duration.zero, categoryFocusNode.requestFocus);
  }

  void hideCategoryInput() {
    categoryController.clear();
    isAddingCategory.value = false;
    categoryFocusNode.unfocus();
  }

  void addCategory() {
    final category = categoryController.text.trim();
    if (category.isEmpty) return;

    final existingCategory = categoryOptions.firstWhereOrNull(
      (option) => option.toLowerCase() == category.toLowerCase(),
    );
    final categoryToSelect = existingCategory ?? category;

    if (existingCategory == null) {
      categoryOptions.add(category);
    }
    if (!selectedCategories.contains(categoryToSelect)) {
      selectedCategories.add(categoryToSelect);
    }
    hideCategoryInput();
  }

  Future<void> finish() async {
    await Get.find<OnboardingService>().saveProfile(
      userName: nameController.text,
      selectedCurrency: selectedCurrency.value,
      taskGoal: dailyTaskGoal.value.round(),
      selectedCategories: selectedCategories.toList(),
      budget: double.tryParse(dailyBudgetController.text.trim()) ?? 45,
      savings: double.tryParse(savingsGoalController.text.trim()) ?? 2500,
    );
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    nameController.dispose();
    dailyBudgetController.dispose();
    savingsGoalController.dispose();
    categoryController.dispose();
    categoryFocusNode.dispose();
    super.onClose();
  }
}
