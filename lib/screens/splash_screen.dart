import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rk_distributor/services/auth_service.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import '../services/theme_service.dart';
import 'Home_Screens/home_screen_norm.dart';
import 'Home_Screens/home_screen_super_su.dart';
import 'login_screen.dart';
import 'user_waiting_page.dart';

class SplashScreen extends StatelessWidget {
  final AuthService authService = Get.find();
  final TextStyleController textStyleController = Get.find();
  final ThemeService themeService = Get.find();

  @override
  Widget build(BuildContext context) {
    // Check if user is already logged in
    Future.delayed(Duration(seconds: 2, milliseconds: 50), () {
      if (authService.user.value != null &&
          authService.appAccess.value == true && authService.superSu.value == false) {
        Get.off(() => HomeScreenNorm());
      } else if (authService.user.value != null &&
          authService.appAccess.value == false) {
        Get.off(() => UserWaitingPage());
      } else if (authService.user.value != null &&
          authService.appAccess.value == true && authService.superSu.value == true) {
        Get.off(() => HomeScreenSuperSu());
      } else {
        Get.off(() => LoginScreen());
      }
    });

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: EdgeInsets.all(20.0), // Add padding for better spacing
            child: Text(
              "RK DISTRIBUTOR",
              style: textStyleController.loginTextStyle.value,
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: LoadingAnimationWidget.inkDrop(
                color:
                    themeService.isDarkMode.value ? Colors.white : Colors.black,
                size: 50),
          ), // Adding a loading indicator
        ],
      ),
    );
  }
}
