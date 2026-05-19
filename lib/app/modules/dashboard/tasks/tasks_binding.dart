import 'package:get/get.dart';

import 'tasks_controller.dart';

class TasksBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TasksController>()) {
      Get.lazyPut<TasksController>(() => TasksController());
    }
  }
}
