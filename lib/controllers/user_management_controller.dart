import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/models/user.dart';

import '../services/auth_service.dart';

enum UserFilter {
  all,
  superSu,
  appAccess,
  writeAccess,
  updateAccess,
}

class UserManagementController extends GetxController {
  RxList<User> users = <User>[].obs;
  RxList<User> filteredUsers = <User>[].obs;
  Rx<UserFilter> selectedFilter = UserFilter.all.obs;
  final AuthService _authService = Get.find();
  late StreamSubscription userStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    ever(selectedFilter, (_) => filterUsers()); // Filter users when the selected filter changes
    ever(users, (_) => filterUsers()); // Filter users when the user list changes
  }

  @override
  void onClose() {
    userStreamSubscription.cancel();
    super.onClose();
  }

  void fetchUsers() {
    String? currentUserUid = _authService.user.value?['uid'];

    userStreamSubscription = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((querySnapshot) {
      List<User> userList = querySnapshot.docs
          .where((doc) => doc.id != currentUserUid) // Exclude the current user
          .map((doc) {
        return User.fromFirestore(doc);
      }).toList();

      users.assignAll(userList);
      filterUsers();
    }, onError: (error) {
      print('Error fetching users: $error');
    });
  }

  void filterUsers() {
    switch (selectedFilter.value) {
      case UserFilter.all:
        filteredUsers.assignAll(users);
        break;
      case UserFilter.superSu:
        filteredUsers.assignAll(users.where((user) => user.superSu).toList());
        break;
      case UserFilter.appAccess:
        filteredUsers.assignAll(users.where((user) => user.appAccess).toList());
        break;
      case UserFilter.writeAccess:
        filteredUsers.assignAll(users.where((user) => user.writeAccess).toList());
        break;
      case UserFilter.updateAccess:
        filteredUsers.assignAll(users.where((user) => user.updateAccess).toList());
        break;
    }
  }

  void applyFilter(UserFilter filter) {
    selectedFilter.value = filter;
  }
}
