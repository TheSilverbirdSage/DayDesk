import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/auth/login/login_binding.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/auth/signup/signup_binding.dart';
import '../modules/auth/signup/signup_view.dart';
import '../modules/dashboard/charts/charts_binding.dart';
import '../modules/dashboard/charts/charts_view.dart';
import '../modules/dashboard/finance/finance_binding.dart';
import '../modules/dashboard/finance/finance_view.dart';
import '../modules/dashboard/home/home_binding.dart';
import '../modules/dashboard/home/home_view.dart';
import '../modules/dashboard/tasks/tasks_binding.dart';
import '../modules/dashboard/tasks/tasks_view.dart';
import '../modules/onboarding/onboarding_binding.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  static const _transitionDuration = Duration(milliseconds: 260);
  static const _transitionCurve = Curves.easeOutCubic;

  static final routes = <GetPage<dynamic>>[
    _page(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    _page(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    _page(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    _page(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: SignupBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    _page(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    _page(
      name: AppRoutes.tasks,
      page: () => const TasksView(),
      binding: TasksBinding(),
      transition: Transition.fadeIn,
    ),
    _page(
      name: AppRoutes.finance,
      page: () => const FinanceView(),
      binding: FinanceBinding(),
      transition: Transition.fadeIn,
    ),
    _page(
      name: AppRoutes.charts,
      page: () => const ChartsView(),
      binding: ChartsBinding(),
      transition: Transition.fadeIn,
    ),
  ];

  static GetPage<dynamic> _page({
    required String name,
    required GetPageBuilder page,
    required Bindings binding,
    required Transition transition,
  }) {
    return GetPage<dynamic>(
      name: name,
      page: page,
      binding: binding,
      transition: transition,
      transitionDuration: _transitionDuration,
      curve: _transitionCurve,
    );
  }
}
