import 'package:get/get.dart';

import '../models/user_model.dart';
import 'local_storage_service.dart';

class AuthService extends GetxService {
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  bool get isLoggedIn => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    final user = Get.find<LocalStorageService>().getCurrentUser();
    if (user == null) return;
    currentUser.value = UserModel(
      name: user['name'] as String? ?? 'Alex',
      email: user['email'] as String? ?? '',
    );
  }

  Future<bool> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) return false;
    final user = UserModel(name: _nameFromEmail(email), email: email.trim());
    currentUser.value = user;
    await Get.find<LocalStorageService>().saveCurrentUser(
      name: user.name,
      email: user.email,
    );
    return true;
  }

  Future<bool> register(String name, String email, String password) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      return false;
    }
    final user = UserModel(name: name.trim(), email: email.trim());
    currentUser.value = user;
    await Get.find<LocalStorageService>().saveCurrentUser(
      name: user.name,
      email: user.email,
    );
    return true;
  }

  String _nameFromEmail(String email) {
    final prefix = email.trim().split('@').first;
    if (prefix.isEmpty) return 'Alex';
    return prefix[0].toUpperCase() + prefix.substring(1);
  }
}
