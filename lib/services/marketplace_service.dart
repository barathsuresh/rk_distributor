import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/services/customer_service.dart';
import 'package:rk_distributor/services/product_service.dart';

import '../models/product_model.dart';

class MarketplaceService extends GetxService {
  final ProductService productService = Get.find<ProductService>();
  final CustomerService customerService = Get.find<CustomerService>();

  final TextEditingController searchController = TextEditingController();

  var searchQuery = ''.obs;
  var selectedCategory = 'All'.obs;
  var selectedCustomer = ''.obs;
  var selectedArea = ''.obs;
  var priceSelection = 'Common'.obs;

  var isLoading = false.obs;
  var allProducts = <Product>[].obs;
  var displayedProducts = <Product>[].obs;
  var productsPerPage = 20;
  DocumentSnapshot? lastDocument;

  @override
  void onInit() {
    super.onInit();
    // Observing the product list from ProductService for real-time updates
    ever(productService.products, (_) {
      allProducts.assignAll(productService.products);
      filterProducts();
    });
    fetchInitialProducts();

    // Observe changes in priceSelection and selectedArea
    ever(priceSelection, (_) => filterProducts());
    ever(selectedArea, (_) => filterProducts());
    ever(selectedCustomer, (_) => filterProducts());
  }

  // @override
  // void onClose() {
  //   // TODO: implement onClose
  //   super.onClose();
  //   lastDocument=null;
  // }

  void fetchInitialProducts() async {
    try {
      isLoading.value = true;
      QuerySnapshot querySnapshot = await productService.getProductsPaged(null, 20);
      lastDocument = querySnapshot.docs.isEmpty ? null : querySnapshot.docs.last;
      allProducts.value = querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      filterProducts();
    } catch (e) {
      print('Error fetching initial products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void fetchMoreProducts() async {
    if (lastDocument == null) return;

    try {
      isLoading.value = true;
      QuerySnapshot querySnapshot = await productService.getProductsPaged(lastDocument, 20);

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
        allProducts.addAll(querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
        filterProducts();
      } else {
        lastDocument = null; // No more documents left
      }
    } catch (e) {
      print('Error fetching more products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterProducts() {
    displayedProducts.value = allProducts.where((product) {
      final matchesSearch = searchQuery.value.isEmpty || product.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesCategory = selectedCategory.value == 'All' || product.category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void onSearchChanged(String? query) {
    searchQuery.value = searchController.text ?? '';
    filterProducts();
  }

  void onCategoryChanged(String? category) {
    selectedCategory.value = category ?? 'All';
    filterProducts();
  }

  void onCustomerChanged(String? customerId) {
    selectedCustomer.value = customerId ?? '';
  }

  void onPriceSelectionChanged(String? selection) {
    priceSelection.value = selection ?? 'Common';
  }

  void onAreaChanged(String? area) {
    selectedArea.value = area ?? '';
  }

}