import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShowSnackBar {
  static void showSnackBarException(
      {required Exception e, required String msg}) {
    Get.snackbar("Error", "$msg: $e",
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 1,milliseconds: 500),
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        animationDuration: Duration(milliseconds: 300),
        margin: EdgeInsets.all(10));
  }

  static void showSnackBarCRUDSuccess({required String msg}){
    Get.snackbar("Success", msg,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 1,milliseconds: 500),
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        animationDuration: Duration(milliseconds: 300),
        margin: EdgeInsets.all(10));
  }

  static void showSnackBar({required String title, required String msg}){
    Get.snackbar(title, msg,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 1,milliseconds: 500),
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
        dismissDirection: DismissDirection.none,
        animationDuration: Duration(milliseconds: 300),
        margin: EdgeInsets.all(10));
  }
}
