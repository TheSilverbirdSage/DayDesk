import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/local_storage_service.dart';
import '../../data/services/onboarding_service.dart';

class SettingsController extends GetxController {
  final nameController = TextEditingController();
  final dailyBudgetController = TextEditingController();
  final savingsGoalController = TextEditingController();
  final categoryController = TextEditingController();
  final categoryFocusNode = FocusNode();

  final selectedCurrency = 'USD'.obs;
  final dailyTaskGoal = 8.0.obs;
  final selectedCategories = <String>[].obs;
  final categoryOptions = <String>[].obs;
  final isAddingCategory = false.obs;
  final isDarkMode = false.obs;

  final currencies = const ['USD', 'EUR', 'GBP', 'Other'];

  OnboardingService get _onboarding => Get.find<OnboardingService>();
  LocalStorageService get _storage => Get.find<LocalStorageService>();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void selectCurrency(String currency) {
    selectedCurrency.value = currency;
  }

  void updateDarkMode(bool value) {
    isDarkMode.value = value;
    _storage.setDarkMode(value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void updateTaskGoal(double value) {
    dailyTaskGoal.value = value;
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

  Future<void> saveSettings() async {
    if (categoryController.text.trim().isNotEmpty) {
      addCategory();
    }

    await _onboarding.saveProfile(
      userName: nameController.text,
      selectedCurrency: selectedCurrency.value,
      taskGoal: dailyTaskGoal.value.round(),
      selectedCategories: selectedCategories.toList(),
      budget: double.tryParse(dailyBudgetController.text.trim()) ?? 45,
      savings: double.tryParse(savingsGoalController.text.trim()) ?? 2500,
    );

    Get.snackbar(
      'Settings saved',
      'Your preferences have been updated.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  void _loadSettings() {
    nameController.text = _onboarding.name.value;
    selectedCurrency.value = _onboarding.currency.value;
    dailyTaskGoal.value = _onboarding.dailyTaskGoal.value.toDouble();
    selectedCategories.assignAll(_onboarding.categories);
    categoryOptions.assignAll(
      {
        'Work',
        'Personal',
        'Health',
        'Finance',
        ..._onboarding.categories,
      },
    );
    dailyBudgetController.text = _onboarding.dailyBudget.value.toStringAsFixed(
      2,
    );
    savingsGoalController.text =
        _onboarding.savingsGoal.value.round().toString();
    isDarkMode.value = _storage.isDarkMode;
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
