import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rk_distributor/models/order_model.dart';
import 'package:rk_distributor/services/marketplace_service.dart';

import '../models/product_model.dart';

class MarketplaceController extends GetxController {
  var orderItems = <OrderItem>[].obs;
  final MarketplaceService marketPlaceService = Get.find();
  final Map<String, double> originalPrices = {}; // To keep track of original prices
  var selectedArea = ''.obs; // Observable to track the selected area

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in area selection
    selectedArea.listen((area) {
      updateAllOriginalPrices();
    });
  }

  void addProductToOrder(Product product, double price) {
    var existingItem = orderItems.firstWhereOrNull((item) => item.prodId == product.id);
    if (existingItem != null) {
      existingItem.qty++;
      existingItem.total = existingItem.qty * existingItem.price;
    } else {
      orderItems.add(OrderItem(
        prodId: product.id,
        name: product.name,
        qty: 1,
        price: price,
        isPriceChange: false,
        total: price,
      ));
      originalPrices[product.id] = price; // Store original price
    }
    orderItems.refresh();
  }

  void updateProductQuantity(OrderItem item, int qty) {
    if (qty <= 0) {
      orderItems.remove(item);
    } else {
      item.qty = qty;
      item.total = item.qty * item.price;
    }
    orderItems.refresh();
  }

  void updateProductPrice(OrderItem item, double price) {
    item.isPriceChange = true;
    item.price = price;
    item.total = item.qty * price;
    orderItems.refresh();
  }

  void resetProductPrice(OrderItem item) {
    final originalPrice = originalPrices[item.prodId];
    if (originalPrice != null) {
      item.price = originalPrice;
      item.total = item.qty * originalPrice;
      item.isPriceChange = false;
    }
    orderItems.refresh();
  }

  void updateAllOriginalPrices() async {
    for (var item in orderItems) {
      final product = await marketPlaceService.getProductById(item.prodId);
      if (product != null) {
        final newPrice = getPriceForProduct(product);
        originalPrices[item.prodId] = newPrice;
        // Reset to the new original price if it's different from the current one
        if (!item.isPriceChange) {
          item.price = newPrice;
          item.total = item.qty * newPrice;
        }
      }
    }
    orderItems.refresh();
  }

  double getPriceForProduct(Product product) {
    if (selectedArea.value.isNotEmpty) {
      final areaPrice = product.ourPrice.area.firstWhere(
            (area) => area.name == selectedArea.value,
        orElse: () => AreaPrice(name: '', price: product.ourPrice.common),
      );
      return areaPrice.price;
    }
    return product.ourPrice.common;
  }
}
