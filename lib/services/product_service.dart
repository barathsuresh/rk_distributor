import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../utils/show_snackbar.dart';

class ProductService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Product> products = <Product>[].obs;
  final RxList<String> categories = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _startProductListener();
    _startCategoryListener();
    _fetchCategories();
  }

  void _startProductListener() {
    _firestore.collection('products').snapshots().listen((querySnapshot) {
      final productList =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      products.assignAll(productList);
      // _generateCategories(productList);
      _updateCategories(productList);
    });
  }

  void _startCategoryListener() {
    _firestore
        .collection('categories')
        .doc('categories')
        .snapshots()
        .listen((documentSnapshot) {
      _fetchCategories();
    });
  }

  // void _generateCategories(List<Product> productList) {
  //   Set<String> categorySet = Set();
  //   productList.forEach((product) {
  //     categorySet.add(product.category);
  //   });
  //   categories.assignAll(categorySet.toList());
  // }

  void _updateCategories(List<Product> productList) {
    // Collect all unique categories from the productList
    Set<String> allCategories = {};
    for (var product in productList) {
      allCategories.add(product.category);
    }

    // Update the categories collection
    _updateCategoriesInFirestore(allCategories.toList());
  }

  Future<void> _updateCategoriesInFirestore(List<String> categoriesList) async {
    try {
      // Get the categories document
      DocumentReference categoriesDocRef =
          _firestore.collection('categories').doc('categories');
      DocumentSnapshot categoriesDoc = await categoriesDocRef.get();

      if (categoriesDoc.exists) {
        // Update the categories array in the document
        await categoriesDocRef.update({
          'categories': categoriesList,
        });
      } else {
        // Create the categories document if it doesn't exist
        await categoriesDocRef.set({
          'categories': categoriesList,
        });
      }
    } catch (e) {
      print('Error updating categories: $e');
    }
  }

  void _fetchCategories() {
    _firestore
        .collection('categories')
        .doc('categories')
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        final dynamic data = doc.data();
        if (data != null && data['categories'] != null) {
          final List<dynamic> categoriesList = data['categories'];
          categories.assignAll(
              categoriesList.map((category) => category.toString()).toList());
        }
      }
    }).catchError((error) {
      print('Failed to fetch categories: $error');
    });
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .set(product.toJson());
      if (!categories.contains(product.category)) {
        await _addCategory(product.category);
      }
      ShowSnackBar.showSnackBarCRUDSuccess(msg: "Product Added Successfully");
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to add product');
    }
  }

  Future<void> _addCategory(String category) async {
    try {
      await _firestore.collection('categories').doc('categories').update({
        'categories': FieldValue.arrayUnion([category]),
      });
      categories.add(category);
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to add category');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toJson());
      ShowSnackBar.showSnackBarCRUDSuccess(msg: 'Updated Product Successfully');
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to update product');
    }
  }

  Future<void> deleteProduct(String id, String category) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      _removeCategoryIfEmpty(category);
      ShowSnackBar.showSnackBarCRUDSuccess(msg: 'Deleted Product Successfully');
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to delete product');
    }
  }

  Future<void> _removeCategoryIfEmpty(String category) async {
    final categoryProducts =
        products.where((product) => product.category == category).toList();
    if (categoryProducts.isEmpty) {
      await _removeCategory(category);
    }
  }

  Future<void> _removeCategory(String category) async {
    try {
      await _firestore.collection('categories').doc('categories').update({
        'categories': FieldValue.arrayRemove([category]),
      });
      categories.remove(category);
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(
          e: e, msg: 'Failed to remove category');
    }
  }

  Future<void> removeAreaFromProducts(String area) async {
    try {
      // Get all products that have the area in their ourPrice area list
      QuerySnapshot productsSnapshot = await _firestore
          .collection('products')
          .where('ourPrice.area.name', isEqualTo: area)
          .get();

      WriteBatch batch = _firestore.batch();

      // Update each product's OurPrice area
      for (var doc in productsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> areaList = data['ourPrice']['area'];
        List<dynamic> updatedAreaList =
            areaList.where((a) => a['name'] != area).toList();
        data['ourPrice']['area'] = updatedAreaList;
        batch.update(doc.reference, data);
      }

      // Commit the batch
      await batch.commit();
      ShowSnackBar.showSnackBarCRUDSuccess(
          msg: 'Updated Products Successfully');
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(
          e: e, msg: 'Failed to update products');
    }
  }

  Future<void> removeCompanyFromProducts(String companyId) async {
    // todo: try to use it later
    try {
      // Get all products that have the company in their ourPrice company list
      QuerySnapshot productsSnapshot = await _firestore
          .collection('products')
          .where('ourPrice.companyPrices.companyId', isEqualTo: companyId)
          .get();

      WriteBatch batch = _firestore.batch();

      // Update each product's OurPrice companyPrices
      productsSnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> companyPricesList = data['ourPrice']['companyPrices'];
        List<dynamic> updatedCompanyPricesList = companyPricesList
            .where((c) => c['companyId'] != companyId)
            .toList();
        data['ourPrice']['companyPrices'] = updatedCompanyPricesList;
        batch.update(doc.reference, data);
      });

      // Commit the batch
      await batch.commit();
      ShowSnackBar.showSnackBarCRUDSuccess(
          msg: 'Updated Products Successfully');
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(
          e: e, msg: 'Failed to update products');
    }
  }
}
