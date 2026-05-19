import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
          'Missing details', 'Fill in all fields to create your account.');
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
          'Password mismatch', 'Password and confirmation must match.');
      return;
    }

    isLoading.value = true;
    final success =
        await Get.find<AuthService>().register(name, email, password);
    isLoading.value = false;

    if (success) {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}
