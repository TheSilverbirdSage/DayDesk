import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
          'Missing details', 'Enter an email and password to continue.');
      return;
    }

    isLoading.value = true;
    final success = await Get.find<AuthService>().login(email, password);
    isLoading.value = false;

    if (success) {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}
