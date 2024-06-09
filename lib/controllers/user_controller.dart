import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rk_distributor/models/user_model.dart';
import 'package:rk_distributor/utils/show_snackbar.dart';

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
      ShowSnackBar.showSnackBarCRUDSuccess(msg: "User updated successfully");
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: "Failed to update user");
    }
  }

  Future<bool> toggleWriteAccess() async {
    try {
      user.value!.writeAccess = !user.value!.writeAccess;
      await usersCollection
          .doc(user.value!.uid)
          .update({'access.writeAccess': user.value!.writeAccess});
      if (user.value!.writeAccess) {
        ShowSnackBar.showSnackBarCRUDSuccess(msg: "Granted Write Access");
      } else {
        ShowSnackBar.showSnackBarCRUDSuccess(msg: "Revoked Write Access");
      }
      return true;
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(
          e: e, msg: "Unable to change Write Access");
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
        ShowSnackBar.showSnackBarCRUDSuccess(msg: "Granted SuperSu Access");
      } else {
        ShowSnackBar.showSnackBarCRUDSuccess(msg: "Revoked SuperSu Access");
      }
      return true;
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(
          e: e, msg: "Unable to change SuperSu Access");
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
        ShowSnackBar.showSnackBarCRUDSuccess(msg: "Granted App Access");
      } else {
        ShowSnackBar.showSnackBarCRUDSuccess(msg: "Revoked App Access");
      }
      return true;
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: "Unable to change App Access");
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
       ShowSnackBar.showSnackBarCRUDSuccess(msg: "Granted Write Access");
      } else {
        ShowSnackBar.showSnackBarCRUDSuccess(msg: "Revoked Write Access");
      }
      return true;
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: "Unable to change Update Access");
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
