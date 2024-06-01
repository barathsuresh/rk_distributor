import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rk_distributor/constants/themes.dart';
import 'package:rk_distributor/controllers/user_controller.dart';
import 'package:rk_distributor/controllers/user_management_controller.dart';
import 'package:rk_distributor/screens/Home_Screens/home_screen_norm.dart';
import 'package:rk_distributor/screens/Home_Screens/home_screen_super_su.dart';
import 'package:rk_distributor/screens/user_management_screen.dart';
import 'package:rk_distributor/screens/user_waiting_page.dart';
import 'package:rk_distributor/services/auth_service.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/services/theme_service.dart';

import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeGetStorage();
  _startAppServices();
  await GetStorage.init();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// initialize the GetStorage
void _initializeGetStorage() async {
  await GetStorage.init('theme');
  await GetStorage.init('userInfo');
}

// Get put services initializing
void _startAppServices() {
  Get.lazyPut(() => AuthService(), fenix: true);
  Get.lazyPut(() => ThemeService(), fenix: true);
  Get.lazyPut(() => TextStyleController(), fenix: true);
  Get.lazyPut(() => UserManagementController(), fenix: true);
  Get.lazyPut(() => UserController(), fenix: true);
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeService themeService = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeService.theme,
      routes: {
        '/loginScreen': (context) => LoginScreen(),
        '/splashScreen':(context) => SplashScreen(),
        '/userWaitingPage':(context)=>UserWaitingPage(),
        '/homeScreenNorm':(context)=>HomeScreenNorm(),
        '/homeScreenSuperSu':(context)=>HomeScreenSuperSu(),
        '/userManagementScreen':(context)=>UserManagementScreen(),
      },
      initialRoute: '/splashScreen',
    );
  }
}
