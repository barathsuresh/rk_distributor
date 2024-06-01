import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/screens/user_management_screen.dart';
import 'package:rk_distributor/services/theme_service.dart';

import 'custom_list_tile.dart';

class CustomNavigationDrawer extends StatelessWidget {
  CustomNavigationDrawer({super.key});

  final TextStyleController textStyleController = Get.find();
  final ThemeService themeService = Get.find();
  final GetStorage _localStorage = GetStorage();
  @override
  Widget build(BuildContext context) {
    var user = _localStorage.read('user');
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.lerp(
                  themeService.isDarkMode.value ? Colors.black : Colors.white,
                  Theme.of(context).colorScheme.primary,
                  0.4),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'RK DISTRIBUTOR',
                style: textStyleController.appBarTextStyle.value,
              ),
            ),
          ),
          CustomListTile(
            leadingIcon: Icons.person,
            title: 'User Management',
            onTap: () {
              Navigator.of(context).pop();
              Get.to(UserManagementScreen());
            },
            subtitle: 'Manage Users',
          ),
          CustomListTile(
            leadingIcon: Icons.settings,
            title: 'Settings',
            onTap: () {
              // TODO: Implement navigation to Settings
            },
            subtitle: 'Tailor Your Preferences',
          ),
        ],
      ),
    );
  }
}
