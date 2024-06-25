import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:rk_distributor/services/customer_service.dart';
import 'package:rk_distributor/services/product_service.dart';

import '../models/product_model.dart';

class MarketplaceService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  var productCount = 0.obs;
  Box<Product> productBox = Hive.box<Product>('products');
  Box lastDocumentBox = Hive.box<Product>('lastDocument');

  @override
  void onInit() {
    super.onInit();
    ever(allProducts, (_) async{
      await filterProducts();
    });
    loadCachedProducts();
    setupRealTimeListeners();
    ever(priceSelection, (_)async{
      await filterProducts();
    });
    ever(selectedArea, (_)async{
      await filterProducts();
    });
    ever(selectedCustomer, (_)async{
      await filterProducts();
    });
  }

  Future<int?> getCollectionLength() async {
    try {
      AggregateQuerySnapshot snapshot = await _firestore.collection('products').count().get();
      return snapshot.count;
    } catch (e) {
      print('Error getting collection length: $e');
      return 0;
    }
  }

  void loadCachedProducts() async {
    var cachedProducts = productBox.values.toList();
    print(cachedProducts.length);
    allProducts.assignAll(cachedProducts.toSet().toList());
    allProducts.sort((a, b) => b.modifiedOn.compareTo(a.modifiedOn));
    if (allProducts.isEmpty) {
      fetchInitialProducts();
    } else {
      await filterProducts();
    }

    if (lastDocumentBox.get('lastDocument') != null) {
      Product lastProduct = allProducts.isEmpty
          ? lastDocumentBox.get('lastDocument') as Product
          : allProducts.last;
      lastDocument =
      await _firestore.collection('products').doc(lastProduct.id).get();
    }

    fetchInitialProducts();
  }

  void fetchInitialProducts() async {
    if (allProducts.isNotEmpty) return;

    try {
      isLoading.value = true;
      QuerySnapshot querySnapshot = await getProductsPaged(productsPerPage);
      lastDocument =
      querySnapshot.docs.isEmpty ? null : querySnapshot.docs.last;
      var fetchedProducts =
      querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      allProducts.value = fetchedProducts.toSet().toList();
      cacheProducts(fetchedProducts);
      await filterProducts();
    } catch (e) {
      print('Error fetching initial products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void fetchMoreProducts() async {

    if (searchQuery.value.isNotEmpty || selectedCategory.value != 'All') {
      return; // Do not fetch more products if search or category filter is active
    }
    // Check if the current number of cached products matches the total count from Firestore
    int? totalProductCount = await getCollectionLength();
    if (totalProductCount != null && allProducts.length >= totalProductCount) {
      return; // All products are already cached, no need to fetch more
    }

    if (lastDocument == null) return;

    try {
      isLoading.value = true;
      QuerySnapshot querySnapshot = await getProductsPaged(productsPerPage);

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
        var newProducts = querySnapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList();
        allProducts.addAll(newProducts);
        allProducts.value =
            allProducts.toSet().toList(); // Ensure no duplicates
        cacheProducts(newProducts);
        await filterProducts();
      } else {
        lastDocument = null; // No more documents left
      }
    } catch (e) {
      print('Error fetching more products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void cacheProducts(List<Product> products) {
    for (var product in products) {
      productBox.put(product.id, product);
    }
    if (lastDocument != null) {
      Product lastProduct = Product.fromFirestore(lastDocument!);
      lastDocumentBox.put('lastDocument', lastProduct);
    }
  }

  Future<void> filterProducts() async{
    if (searchQuery.value.isEmpty && selectedCategory.value == 'All') {
      displayedProducts.assignAll(allProducts);
      return;
    }

    try{
      isLoading.value = true;
      List<Product> filteredProducts = [];

      // Query for search
      if (searchQuery.value.isNotEmpty) {
        QuerySnapshot searchSnapshot = await _firestore.collection('products')
            .where('name', isGreaterThanOrEqualTo: searchQuery.value)
            .where('name', isLessThanOrEqualTo: searchQuery.value + '\uf8ff')
            .get();
        filteredProducts = searchSnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      }

      // Query for category
      if (selectedCategory.value != 'All') {
        QuerySnapshot categorySnapshot = await _firestore.collection('products')
            .where('category', isEqualTo: selectedCategory.value)
            .get();
        List<Product> categoryProducts = categorySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        filteredProducts = filteredProducts.isEmpty ? categoryProducts : filteredProducts.where((p) => categoryProducts.any((c) => c.id == p.id)).toList();
      }
      displayedProducts.assignAll(filteredProducts);
    }catch(e){
      print('Error filtering or searching products: $e');
    }finally{
      isLoading.value = false;
    }
    // displayedProducts.value = allProducts.where((product) {
    //   final matchesSearch = searchQuery.value.isEmpty ||
    //       product.name.toLowerCase().contains(searchQuery.value.toLowerCase());
    //   final matchesCategory = selectedCategory.value == 'All' ||
    //       product.category == selectedCategory.value;
    //   return matchesSearch && matchesCategory;
    // }).toList();
  }

  Future<QuerySnapshot> getProductsPaged(int limit) async {
    Query query = _firestore.collection('products').orderBy('modifiedOn', descending: true).limit(limit);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }
    return query.get();
  }

  void setupRealTimeListeners() {
    _firestore
        .collection('products')
        .orderBy('modifiedOn', descending: true)
        .limit(allProducts.isEmpty ? productsPerPage : allProducts.length)
        .snapshots()
        .listen((snapshot) async {
      snapshot.docChanges.forEach((change) async{
        var changedProduct = Product.fromFirestore(change.doc);
        if (change.type == DocumentChangeType.added) {
          if (!allProducts.any((product) => product.id == changedProduct.id)) {
            allProducts.insert(0, changedProduct);
            productBox.put(changedProduct.id, changedProduct);
          }
        } else if (change.type == DocumentChangeType.modified) {
          var index = allProducts
              .indexWhere((product) => product.id == changedProduct.id);
          if (index != -1) {
            allProducts[index] = changedProduct;
            productBox.put(changedProduct.id, changedProduct);
          }
        } else if (change.type == DocumentChangeType.removed) {
          allProducts.removeWhere((product) => product.id == changedProduct.id);
          productBox.delete(changedProduct.id);
        }
      });
      allProducts.sort((a, b) => b.modifiedOn.compareTo(a.modifiedOn));
      await filterProducts();
    });
  }

  void onSearchChanged(String? query) {
    searchQuery.value = searchController.text ?? '';
    fetchInitialProducts();
    filterProducts();
  }

  void onCategoryChanged(String? category) {
    selectedCategory.value = category ?? 'All';
    fetchInitialProducts();
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
