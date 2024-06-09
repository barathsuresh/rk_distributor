import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'product_service.dart';
import 'customer_service.dart';

class MarketplaceService extends GetxService {
  final ProductService productService = Get.find<ProductService>();
  final CustomerService customerService = Get.find<CustomerService>();

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

  void fetchInitialProducts() async {
    isLoading.value = true;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .limit(productsPerPage)
        .get();
    lastDocument = querySnapshot.docs.isEmpty ? null : querySnapshot.docs.last;
    allProducts.value = querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    filterProducts();
    isLoading.value = false;
  }

  void fetchMoreProducts() async {
    if (isLoading.value || lastDocument == null) return;

    isLoading.value = true;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .startAfterDocument(lastDocument!)
        .limit(productsPerPage)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
      allProducts.addAll(querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
      filterProducts();
    } else {
      lastDocument = null; // No more documents left
    }

    isLoading.value = false;
  }

  void filterProducts() {
    displayedProducts.value = allProducts.where((product) {
      final matchesSearch = searchQuery.value.isEmpty || product.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesCategory = selectedCategory.value == 'All' || product.category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void onSearchChanged(String? query) {
    searchQuery.value = query ?? '';
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
