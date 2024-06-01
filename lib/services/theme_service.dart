import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  // Default theme is light
  var isDarkMode = false.obs;
  final _localStorage = GetStorage();

  ThemeMode get theme => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme(){
    isDarkMode.value = _localStorage.read('theme') ?? true;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _localStorage.write('theme', isDarkMode.value);
    Get.changeThemeMode(theme);
  }
}
