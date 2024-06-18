import 'package:get/get.dart';

class MarketplaceController extends GetxController{
  var showFAB = true.obs;

  void showCart(bool value) {
    showFAB.value = value;
  }
}