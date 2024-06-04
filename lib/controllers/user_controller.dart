import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rk_distributor/models/user_model.dart';

class UserController extends GetxController {
  var user = Rxn<UserModel>(); // User object to store user data
  UserModel? userBackup; // Backup of the original user data
  var isEditing = false.obs;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  var showFAB = true.obs;
  late StreamSubscription<DocumentSnapshot> userSubscription;

  void showEditing(bool value) {
    showFAB.value = value;
  }

  // Method to initialize the user data
  void setUser(UserModel newUser) {
    user.value = newUser;
    _startUserListener(newUser.uid);
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    userSubscription.cancel();
    super.onClose();
  }

  // Method to start listening to Firestore changes
  void _startUserListener(String userId) {
    userSubscription =
        usersCollection.doc(userId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        user.value = UserModel.fromFirestore(snapshot);
      }
    });
  }

  // Method to update user data in Firebase
  void updateUser() async {
    try {
      await usersCollection.doc(user.value!.uid).update({
        'name': user.value!.name,
        'email': user.value!.email,
        'superSu': user.value!.superSu,
      });
      Get.snackbar("Success", "User updated successfully",
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          snackStyle: SnackStyle.FLOATING,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          animationDuration: Duration(milliseconds: 300),
          margin: EdgeInsets.all(10));
    } catch (e) {
      Get.snackbar("Error", "Failed to update user: $e",
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          snackStyle: SnackStyle.FLOATING,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          animationDuration: Duration(milliseconds: 300),
          margin: EdgeInsets.all(10));
    }
  }

  Future<bool> toggleWriteAccess() async {
    try {
      user.value!.writeAccess = !user.value!.writeAccess;
      await usersCollection
          .doc(user.value!.uid)
          .update({'access.writeAccess': user.value!.writeAccess});
      if (user.value!.writeAccess) {
        Get.snackbar(user.value!.name, "Granted Write Access",
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 2),
            snackStyle: SnackStyle.FLOATING,
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            animationDuration: Duration(milliseconds: 300),
            margin: EdgeInsets.all(10));
      } else {
        Get.snackbar(user.value!.name, "Revoked Write Access",
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 2),
            snackStyle: SnackStyle.FLOATING,
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            animationDuration: Duration(milliseconds: 300),
            margin: EdgeInsets.all(10));
      }
      return true;
    } on Exception catch (e) {
      Get.snackbar(user.value!.name, "Unable to change Write Access: $e",
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          snackStyle: SnackStyle.FLOATING,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          animationDuration: Duration(milliseconds: 300),
          margin: EdgeInsets.all(10));
      return false;
    }
  }

  Future<bool> toggleSuperSuAccess() async {
    try {
      user.value!.superSu = !user.value!.superSu;
      await usersCollection
          .doc(user.value!.uid)
          .update({'access.superSu': user.value!.superSu});
      if (user.value!.superSu) {
        Get.snackbar(user.value!.name, "Granted SuperSu Access",
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 2),
            snackStyle: SnackStyle.FLOATING,
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            animationDuration: Duration(milliseconds: 300),
            margin: EdgeInsets.all(10));
      } else {
        Get.snackbar(user.value!.name, "Revoked SuperSu Access",
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 2),
            snackStyle: SnackStyle.FLOATING,
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            animationDuration: Duration(milliseconds: 300),
            margin: EdgeInsets.all(10));
      }
      return true;
    } on Exception catch (e) {
      Get.snackbar(user.value!.name, "Unable to change SuperSu Access: $e",
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          snackStyle: SnackStyle.FLOATING,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          animationDuration: Duration(milliseconds: 300),
          margin: EdgeInsets.all(10));
      return false;
    }
  }

  Future<bool> toggleAppAccess() async {
    try {
      user.value!.appAccess = !user.value!.appAccess;
      await usersCollection
          .doc(user.value!.uid)
          .update({'appAccess': user.value!.appAccess});
      if (user.value!.appAccess) {
        Get.snackbar(user.value!.name, "Granted App Access",
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 2),
            snackStyle: SnackStyle.FLOATING,
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            animationDuration: Duration(milliseconds: 300),
            margin: EdgeInsets.all(10));
      } else {
        Get.snackbar(user.value!.name, "Revoked App Access",
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 2),
            snackStyle: SnackStyle.FLOATING,
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            animationDuration: Duration(milliseconds: 300),
            margin: EdgeInsets.all(10));
      }
      return true;
    } on Exception catch (e) {
      Get.snackbar(user.value!.name, "Unable to change App Access: $e",
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          snackStyle: SnackStyle.FLOATING,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          animationDuration: Duration(milliseconds: 300),
          margin: EdgeInsets.all(10));
      return false;
    }
  }

  Future<bool> toggleUpdateAccess() async {
    try {
      user.value!.updateAccess = !user.value!.updateAccess;
      await usersCollection
          .doc(user.value!.uid)
          .update({'access.updateAccess': user.value!.updateAccess});
      if (user.value!.updateAccess) {
        Get.snackbar(user.value!.name, "Granted Write Access",
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 2),
            snackStyle: SnackStyle.FLOATING,
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            animationDuration: Duration(milliseconds: 300),
            margin: EdgeInsets.all(10));
      } else {
        Get.snackbar(user.value!.name, "Revoked Write Access",
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 2),
            snackStyle: SnackStyle.FLOATING,
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
            animationDuration: Duration(milliseconds: 300),
            margin: EdgeInsets.all(10));
      }
      return true;
    } on Exception catch (e) {
      Get.snackbar(user.value!.name, "Unable to change Update Access: $e",
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          snackStyle: SnackStyle.FLOATING,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          animationDuration: Duration(milliseconds: 300),
          margin: EdgeInsets.all(10));
      return false;
    }
  }

  // Toggle editing mode
  void toggleEditing({bool saveChanges = true}) {
    if (isEditing.value && saveChanges) {
      updateUser();
    } else if (!saveChanges) {
      // Restore the backup if not saving changes
      if (userBackup != null) {
        user.value!.name = userBackup!.name;
        user.value!.email = userBackup!.email;
        user.value!.superSu = userBackup!.superSu;
      }
    } else {
      // Create a backup when starting to edit
      userBackup = UserModel(
        uid: user.value!.uid,
        name: user.value!.name,
        email: user.value!.email,
        photoUrl: user.value!.photoUrl,
        superSu: user.value!.superSu,
        updateAccess: user.value!.updateAccess,
        writeAccess: user.value!.writeAccess,
        appAccess: user.value!.appAccess,
        createdAt: user.value!.createdAt,
        lastLoginAt: user.value!.lastLoginAt,
        loggedIn: user.value!.loggedIn,
      );
    }
    isEditing.value = !isEditing.value;
  }
}
