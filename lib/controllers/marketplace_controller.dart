import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class MarketplaceController extends GetxController {
  var showFAB = true.obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
  }

  void showCart(bool value) {
    showFAB.value = value;
  }


  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
