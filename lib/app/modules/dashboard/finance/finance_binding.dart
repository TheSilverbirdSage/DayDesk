import 'package:get/get.dart';

import 'finance_controller.dart';

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FinanceController>()) {
      Get.lazyPut<FinanceController>(() => FinanceController());
    }
  }
}
