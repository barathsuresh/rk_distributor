import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../services/auth_service.dart';

class HomeScreenNorm extends StatelessWidget {
  final GetStorage _storage = GetStorage();
  final AuthService authService = Get.find();

  @override
  Widget build(BuildContext context) {
    var user = _storage.read('user');
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
    );
  }
}