import 'package:get/get.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class HomeController extends GetxController {
  final UserService _userService = UserService();

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers =
      <UserModel>[].obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;

      final result =
          await _userService.getUsers();

      users.assignAll(result);
      filteredUsers.assignAll(result);
    } catch (e) {
      print('HOME USERS ERROR: $e');

      Get.snackbar(
        'Error',
        'Unable to load users.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchUsers(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      filteredUsers.assignAll(users);
      return;
    }

    final result = users.where((user) {
      final name =
          user.name.toLowerCase();

      final email =
          user.email.toLowerCase();

      return name.contains(search) ||
          email.contains(search);
    }).toList();

    filteredUsers.assignAll(result);
  }
}