import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/models/user_model.dart';

import '../services/auth_service.dart';

enum UserFilter {
  all,
  superSu,
  appAccess,
  writeAccess,
  updateAccess,
}

class UserManagementController extends GetxController {
  RxList<UserModel> users = <UserModel>[].obs;
  RxList<UserModel> filteredUsers = <UserModel>[].obs;
  Rx<UserFilter> selectedFilter = UserFilter.all.obs;
  final AuthService _authService = Get.find();
  late StreamSubscription userStreamSubscription;
  RxList<UserModel> appAccessRequests = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    ever(selectedFilter,
        (_) => filterUsers()); // Filter users when the selected filter changes
    ever(users, (_) {
      filterUsers();
    }); // Filter users when the user list changes
  }

  @override
  void onClose() {
    userStreamSubscription.cancel();
    super.onClose();
  }

  void removeFromAppAccess(UserModel user){
    appAccessRequests.remove(user);
  }

  Future<void> removeFromFireStore(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      Get.snackbar("Success", "Deleted the user",
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          snackStyle: SnackStyle.FLOATING,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          animationDuration: Duration(milliseconds: 300),
          margin: EdgeInsets.all(10));
    } on Exception catch (e) {
      Get.snackbar("Error", "Unable to delete the user: $e",
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          snackStyle: SnackStyle.FLOATING,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          animationDuration: Duration(milliseconds: 300),
          margin: EdgeInsets.all(10));
    }
  }

  void fetchAppAccessRequests() {
    // userStreamSubscription = FirebaseFirestore.instance
    //     .collection('users')
    //     .where('appAccess', isEqualTo: false)
    //     .snapshots()
    //     .listen((querySnapshot) {
    //   List<User> appAccessRequestList =
    //       querySnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    //   print('Fetched app access requests: $appAccessRequestList');
    //   appAccessRequests.assignAll(appAccessRequestList);
    // }, onError: (error) {
    //   print('Error fetching app access requests: $error');
    // });
    appAccessRequests
        .assignAll(users.where((user) => !user.appAccess).toList());
  }

  void fetchUsers() {
    String? currentUserUid = _authService.user.value?['uid'];

    userStreamSubscription = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((querySnapshot) {
      List<UserModel> userList = querySnapshot.docs
          .where((doc) => doc.id != currentUserUid) // Exclude the current user
          .map((doc) {
        return UserModel.fromFirestore(doc);
      }).toList();

      users.assignAll(userList);
      filterUsers();
      fetchAppAccessRequests();
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
        filteredUsers
            .assignAll(users.where((user) => user.writeAccess).toList());
        break;
      case UserFilter.updateAccess:
        filteredUsers
            .assignAll(users.where((user) => user.updateAccess).toList());
        break;
    }
  }

  void applyFilter(UserFilter filter) {
    selectedFilter.value = filter;
  }
}
