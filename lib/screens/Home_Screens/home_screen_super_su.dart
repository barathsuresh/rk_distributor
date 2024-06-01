import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/services/theme_service.dart';
import 'package:rk_distributor/widgets/navigation_drawer.dart';

import '../../services/auth_service.dart';

class HomeScreenSuperSu extends StatelessWidget {
  final GetStorage _storage = GetStorage();
  final AuthService authService = Get.find();
  final TextStyleController textStyleController = Get.find();
  final ThemeService themeService = Get.find();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var user = _storage.read('user');
    return Obx(
      () => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu_sharp),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            if (user != null && user['photoUrl'] != null)
              InkWell(
                onTap: () {
                  // TODO: implement onTap
                  themeService.toggleTheme();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CircleAvatar(
                    radius: 18.0,
                    backgroundImage:
                        CachedNetworkImageProvider(user['photoUrl']),
                  ),
                ),
              )
          ],
          title: Text(
            'RK DISTRIBUTOR',
            style: textStyleController.appBarTextStyle.value,
          ),
        ),
        drawer: CustomNavigationDrawer(),
        body: user != null
            ? Text('Welcome, ${user['email']}')
            : Text('No user signed in'),
      ),
    );
  }
}
