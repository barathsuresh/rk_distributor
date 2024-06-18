import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/product_model.dart';
import '../utils/show_snackbar.dart';

class ProductService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<Product> _productBox = Hive.box<Product>('products');

  final RxList<Product> products = <Product>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxList<String> units = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedProducts();
    _startProductListener();
    _startCategoryListener();
    _fetchCategories();
    _startUnitsListener();
  }

  void _loadCachedProducts() {
    products.assignAll(_productBox.values.toList());
  }

  void _startProductListener() {
    _firestore.collection('products').snapshots().listen((querySnapshot) {
      final productList = querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      products.assignAll(productList);
      _cacheProducts(productList);
      _updateCategories(productList);
    });
  }

  void _startCategoryListener() {
    _firestore.collection('categories').doc('categories').snapshots().listen((documentSnapshot) {
      _fetchCategories();
    });
  }

  void _startUnitsListener() {
    _firestore.collection('units').doc('units').snapshots().listen((documentSnapshot) {
      _fetchUnits();
    });
  }

  void _fetchCategories() {
    _firestore.collection('categories').doc('categories').get().then((DocumentSnapshot doc) {
      if (doc.exists) {
        final dynamic data = doc.data();
        if (data != null && data['categories'] != null) {
          final List<dynamic> categoriesList = data['categories'];
          categories.assignAll(categoriesList.map((category) => category.toString()).toList());
        }
      }
    }).catchError((error) {
      print('Failed to fetch categories: $error');
    });
  }

  void _fetchUnits() {
    _firestore.collection('units').doc('units').get().then((DocumentSnapshot doc) {
      if (doc.exists) {
        final dynamic data = doc.data();
        if (data != null && data['units'] != null) {
          final List<dynamic> unitsList = data['units'];
          units.assignAll(unitsList.map((unit) => unit.toString()).toList());
        }
      }
    }).catchError((error) {
      print('Failed to fetch units: $error');
    });
  }

  void _updateCategories(List<Product> productList) {
    Set<String> allCategories = {};
    for (var product in productList) {
      allCategories.add(product.category);
    }
    _updateCategoriesInFirestore(allCategories.toList());
  }

  Future<void> _updateCategoriesInFirestore(List<String> categoriesList) async {
    try {
      DocumentReference categoriesDocRef = _firestore.collection('categories').doc('categories');
      DocumentSnapshot categoriesDoc = await categoriesDocRef.get();

      if (categoriesDoc.exists) {
        await categoriesDocRef.update({
          'categories': categoriesList,
        });
      } else {
        await categoriesDocRef.set({
          'categories': categoriesList,
        });
      }
    } catch (e) {
      print('Error updating categories: $e');
    }
  }

  void _cacheProducts(List<Product> productList) async {
    await _productBox.clear();
    for (var product in productList) {
      await _productBox.put(product.id, product);
    }
  }

  Future<void> addUnit(String unit) async {
    try {
      await _firestore.collection('units').doc('units').update({
        'units': FieldValue.arrayUnion([unit]),
      });
      ShowSnackBar.showSnackBarCRUDSuccess(msg: "Unit Added Successfully");
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to add unit');
    }
  }

  Future<void> deleteUnit(String unit) async {
    try {
      await _firestore.collection('units').doc('units').update({
        'units': FieldValue.arrayRemove([unit]),
      });
      units.remove(unit);
      ShowSnackBar.showSnackBarCRUDSuccess(msg: "Unit Deleted Successfully");
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to delete unit');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).set(product.toJson());
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
      await _firestore.collection('products').doc(product.id).update(product.toJson());
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
    final categoryProducts = products.where((product) => product.category == category).toList();
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
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to remove category');
    }
  }

  Future<void> removeAreaFromProducts(String area) async {
    try {
      QuerySnapshot productsSnapshot = await _firestore.collection('products').where('ourPrice.area.name', isEqualTo: area).get();

      WriteBatch batch = _firestore.batch();

      for (var doc in productsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> areaList = data['ourPrice']['area'];
        List<dynamic> updatedAreaList = areaList.where((a) => a['name'] != area).toList();
        data['ourPrice']['area'] = updatedAreaList;
        batch.update(doc.reference, data);
      }

      await batch.commit();
      ShowSnackBar.showSnackBarCRUDSuccess(msg: 'Updated Products Successfully');
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to update products');
    }
  }

  Future<void> removeCompanyFromProducts(String companyId) async {
    try {
      QuerySnapshot productsSnapshot = await _firestore.collection('products').where('ourPrice.companyPrices.companyId', isEqualTo: companyId).get();

      WriteBatch batch = _firestore.batch();

      for (var doc in productsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> companyPricesList = data['ourPrice']['companyPrices'];
        List<dynamic> updatedCompanyPricesList = companyPricesList.where((c) => c['companyId'] != companyId).toList();
        data['ourPrice']['companyPrices'] = updatedCompanyPricesList;
        batch.update(doc.reference, data);
      }

      await batch.commit();
      ShowSnackBar.showSnackBarCRUDSuccess(msg: 'Updated Products Successfully');
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to update products');
    }
  }

  Future<QuerySnapshot> getProductsPaged(DocumentSnapshot? lastDocument, int limit) {
    Query query = _firestore.collection('products').limit(limit);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return query.get();
  }
}
