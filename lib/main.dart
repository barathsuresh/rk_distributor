import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_distributor/constants/themes.dart';
import 'package:rk_distributor/controllers/barcode_scan_controller.dart';
import 'package:rk_distributor/controllers/marketplace_controller.dart';
import 'package:rk_distributor/controllers/product_controller.dart';
import 'package:rk_distributor/controllers/user_controller.dart';
import 'package:rk_distributor/controllers/user_management_controller.dart';
import 'package:rk_distributor/screens/Home_Screens/home_screen_norm.dart';
import 'package:rk_distributor/screens/Home_Screens/home_screen_super_su.dart';
import 'package:rk_distributor/screens/User_Management_Screens/user_management_screen.dart';
import 'package:rk_distributor/screens/user_waiting_page.dart';
import 'package:rk_distributor/services/auth_service.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/services/customer_service.dart';
import 'package:rk_distributor/services/marketplace_service.dart';
import 'package:rk_distributor/services/product_service.dart';
import 'package:rk_distributor/services/theme_service.dart';
import 'package:rk_distributor/utils/product_uploader.dart';
import 'package:rk_distributor/utils/show_snackbar.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'models/product_model.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(OurPriceAdapter());
  Hive.registerAdapter(AreaPriceAdapter());
  Hive.registerAdapter(CustomerPriceAdapter());
  Hive.registerAdapter(WeightAdapter());

  await Hive.openBox<Product>('products');
  await Hive.openBox<Product>('lastDocument');
  await Hive.openBox('categoryBox');
  await Hive.openBox('unitBox');

  await Firebase.initializeApp();
  _initializeGetStorage();
  _startAppServices();
  await GetStorage.init();
  // todo: experimental code remove it
  Workmanager().initialize(callbackDispatcher);
  runApp(MyApp());
}
// todo: experimental code remove it
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    if (task == 'uploadProductsTask') {
      // await Get.putAsync(() => CustomerService().init());
      await addProductsInBatches(100);
      ShowSnackBar.showSnackBarCRUDSuccess(msg: "500 random products added");
      return Future.value(true);
    }
    return Future.value(false);
  });
}
// todo: experimental code remove it
Future<void> addProductsInBatches(int count) async {
  final productUploader = ProductUploader();
  List<Product> products = await productUploader.generateProducts(count);
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  WriteBatch batch = firestore.batch();
  int counter = 0;

  for (Product product in products) {
    DocumentReference docRef = firestore.collection('products').doc(product.id);
    batch.set(docRef, product.toFirestore());

    counter++;

    if (counter == 500) {
      await batch.commit();
      batch = firestore.batch();
      counter = 0;
    }
  }

  if (counter > 0) {
    await batch.commit();
  }
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
  Get.lazyPut(() => ProductService(), fenix: true);
  Get.lazyPut(() => CustomerService(), fenix: true);
  Get.lazyPut(() => MarketplaceService(), fenix: true);

  Get.lazyPut(() => TextStyleController(), fenix: true);
  Get.lazyPut(() => UserManagementController(), fenix: true);
  Get.lazyPut(() => UserController(), fenix: true);
  Get.lazyPut(() => BarcodeScanController(), fenix: true);
  Get.lazyPut(() => ProductController(), fenix: true);
  Get.lazyPut(() => MarketplaceController(), fenix: true);
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
