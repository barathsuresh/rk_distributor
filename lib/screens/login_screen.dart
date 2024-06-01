import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/services/theme_service.dart';
import '../services/auth_service.dart';
import 'Home_Screens/home_screen_norm.dart';
import 'Home_Screens/home_screen_super_su.dart';
import 'user_waiting_page.dart';

class LoginScreen extends StatelessWidget {
  final AuthService authService = Get.find();
  final TextStyleController textStyleController = Get.find();
  final ThemeService themeService = Get.find();

  @override
  Widget build(BuildContext context) {
    // this is for already logged in
    if (authService.user.value != null &&
        authService.appAccess.value == true && authService.superSu.value == false) {
      Get.off(() => HomeScreenNorm());
    } else if (authService.user.value != null &&
        authService.appAccess.value == false) {
      Get.off(() => UserWaitingPage());
    } else if (authService.user.value != null &&
        authService.appAccess.value == true && authService.superSu.value == true) {
      Get.off(() => HomeScreenSuperSu());
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.05,
              child: Center(
                child: Hero(
                  tag: 'cmp_name',
                  child: AnimatedTextKit(totalRepeatCount: 1, animatedTexts: [
                    TypewriterAnimatedText("RK DISTRIBUTOR",
                        speed: Duration(milliseconds: 95),
                        textStyle: textStyleController.loginTextStyle.value)
                  ]),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Obx(() {
              return Container(
                width: MediaQuery.of(context).size.width - 100,
                child: OutlinedButton(
                  onPressed: () async {
                    await authService.signInWithGoogle();
                    if (authService.user.value != null &&
                        authService.appAccess.value == true && authService.superSu.value == false) {
                      Get.off(() => HomeScreenNorm());
                    } else if (authService.user.value != null &&
                        authService.appAccess.value == false) {
                      Get.off(() => UserWaitingPage());
                    } else if (authService.user.value != null &&
                        authService.appAccess.value == true && authService.superSu.value == true) {
                      Get.off(() => HomeScreenSuperSu());
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CommunityMaterialIcons.google,
                        color: themeService.isDarkMode.value
                            ? Colors.white
                            : Colors.black,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Sign in with Google",
                        style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeService.isDarkMode.value
                                ? Colors.white
                                : Colors.black),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
