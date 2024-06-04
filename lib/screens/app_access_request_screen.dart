import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/controllers/user_controller.dart';
import 'package:rk_distributor/controllers/user_management_controller.dart';
import 'package:rk_distributor/screens/about_user_screen.dart';
import 'package:rk_distributor/widgets/custom_boxed_button.dart';
import 'package:rk_distributor/widgets/custom_user_tile.dart';

import '../api/local_auth_api.dart';
import '../models/user_model.dart';
import '../widgets/custom_dialog_box.dart';

class AppAccessRequestScreen extends StatelessWidget {
  AppAccessRequestScreen({super.key});

  final TextStyleController textStyleController = Get.find();
  final UserManagementController userManagementController = Get.find();
  final UserController userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      int pendingRequests = userManagementController.appAccessRequests.length;
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "App Access Requests",
            style: textStyleController.appBarTextStyle.value,
          ),
        ),
        body: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Requests ($pendingRequests)",
                  style: textStyleController.h2CommonStyleBold.value,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pendingRequests,
                itemBuilder: (context, index) {
                  UserModel user = userManagementController.appAccessRequests[index];
                  return CustomUserTile(
                    title: user.name,
                    subtitle: user.email,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomBoxedButton(
                            text: 'Accept',
                            onPressed: () async {
                              bool auth = await LocalAuthApi.authenticate();
                              if (auth) {
                                userController.setUser(user);
                                userController.toggleAppAccess();
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => CustomDialogBox(
                                    title: 'Authentication Required',
                                    content: 'Biometric is required to perform this action',
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: Text(
                                          'OK',
                                          style: GoogleFonts.roboto(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }),
                        CustomBoxedButton(
                          text: 'Decline',
                          onPressed: () {
                            userManagementController.removeFromFireStore(user);
                          },
                          isFilled: false,
                          borderColor: Colors.red,
                        ),
                      ],
                    ),
                    photoUrl: user.photoUrl,
                    onTap: () {
                      Get.to(AboutUserScreen(user: user));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
