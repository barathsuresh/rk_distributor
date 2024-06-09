import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/screens/Home_Screens/Analytics_Page/analytics_page.dart';
import 'package:rk_distributor/screens/Home_Screens/Home_Page/home_page.dart';
import 'package:rk_distributor/screens/Home_Screens/Marketplace_Page/marketplace_page.dart';
import 'package:rk_distributor/services/theme_service.dart';
import 'package:rk_distributor/widgets/custom_navigation_drawer.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../services/auth_service.dart';

class HomeScreenSuperSu extends StatefulWidget {
  @override
  State<HomeScreenSuperSu> createState() => _HomeScreenSuperSuState();
}

class _HomeScreenSuperSuState extends State<HomeScreenSuperSu> {
  final GetStorage _storage = GetStorage();

  final AuthService authService = Get.find();

  final TextStyleController textStyleController = Get.find();

  final ThemeService themeService = Get.find();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0;

  final List<Widget> _pages = [Homepage(), MarketplacePage(), AnalyticsPage()];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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
        body: _pages[_currentIndex],
        bottomNavigationBar: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (i) => _onItemTapped(i),
            items: [
              SalomonBottomBarItem(
                icon: Icon(Icons.home_outlined),
                selectedColor:
                    themeService.isDarkMode.value ? Colors.white : Colors.black,
                title: Text(
                  "Home",
                  style: textStyleController.bottomNavBarTexStyle.value,
                ),
                activeIcon: Icon(Icons.home),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.store_outlined),
                selectedColor: themeService.isDarkMode.value ? Colors.white : Colors.black,
                title: Text(
                  "Market Place",
                  style: textStyleController.bottomNavBarTexStyle.value,
                ),
                activeIcon: Icon(Icons.store),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.analytics_outlined),
                selectedColor: themeService.isDarkMode.value ? Colors.white : Colors.black,
                title: Text(
                  "Analytics",
                  style: textStyleController.bottomNavBarTexStyle.value,
                ),
                activeIcon: Icon(Icons.analytics),
              )
            ]),
      ),
    );
  }
}
