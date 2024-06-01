import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/services/theme_service.dart';

class UserWaitingPage extends StatelessWidget {
  UserWaitingPage({Key? key}) : super(key: key);

  final TextStyleController textStyleController = Get.find();
  final ThemeService themeService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ERROR 401:",
                  style: textStyleController.errorOnUserWaitingPage.value,
                ),
                Text(
                  "Unauthorized Access",
                  style: textStyleController.errorOnUserWaitingPage.value,
                ),
                SizedBox(height: 8),
                Text(
                  "Request Admin",
                  style: textStyleController.errorOnUserWaitingPage.value,
                ),
                SizedBox(height: 60),
                Center(
                  child: LoadingAnimationWidget.dotsTriangle(
                      color: themeService.isDarkMode.value
                          ? Colors.yellow
                          : Colors.black,
                      size: 50),
                )
              ],
            ),
          ),
        ));
  }
}
