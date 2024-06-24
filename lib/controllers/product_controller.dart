import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/utils/show_snackbar.dart';
import '../models/customer_model.dart';
import '../models/product_model.dart';
import '../services/customer_service.dart';

class ProductController extends GetxController {
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final descriptionController = TextEditingController();
  final mrpController = TextEditingController();
  final commonPriceController = TextEditingController();
  final categoryController = TextEditingController();
  final weightController = TextEditingController();

  final customerService = Get.find<CustomerService>();

  final areaPrices = <AreaPrice>[].obs;
  final customerPrices = <CustomerPrice>[].obs;

  final selectedUnit = ''.obs;
  final selectedWeightUnit = ''.obs;

  void addAreaPrice() {
    // Check if the area price to be added is not already present
    if (!isAreaPriceAlreadyAdded()) {
      areaPrices.add(AreaPrice(name: '', price: 0.0));
    } else {
      ShowSnackBar.showSnackBar(title: "Info", msg: "No Duplicates allowed");
    }
  }

  void removeAreaPrice(int index) {
    areaPrices.removeAt(index);
  }

  void clearContents() {
    // Clear the contents of controllers and lists
    nameController.clear();
    brandController.clear();
    descriptionController.clear();
    mrpController.clear();
    selectedUnit.value = '';
    selectedWeightUnit.value = '';
    commonPriceController.clear();
    categoryController.clear();
    areaPrices.clear();
    customerPrices.clear();
  }

  void addCustomerPrice() {
    // Check if the customer price to be added is not already present
    if (!isCustomerPriceAlreadyAdded()) {
      customerPrices.add(CustomerPrice(customerId: '', price: 0.0));
    } else {
      ShowSnackBar.showSnackBar(title: "Info", msg: "No Duplicates allowed");
    }
  }

  bool isAreaPriceAlreadyAdded() {
    // Check if the area price to be added already exists
    return areaPrices.any((areaPrice) => areaPrice.name.isEmpty);
  }

  bool isCustomerPriceAlreadyAdded() {
    // Check if the customer price to be added already exists
    return customerPrices
        .any((customerPrice) => customerPrice.customerId.isEmpty);
  }

  void removeCustomerPrice(int index) {
    customerPrices.removeAt(index);
  }
}
