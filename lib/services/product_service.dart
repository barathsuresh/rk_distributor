import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../utils/show_snackbar.dart';

class ProductService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<String> categories = <String>[].obs;
  final RxList<String> units = <String>[].obs;
  final RxList<String> weightUnits = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _startCategoryListener();
    _fetchCategories();
    _fetchUnits();
    _fetchWeightUnits();
    _startUnitsListener();
    _startWeightUnitsListener();
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

  void _startWeightUnitsListener() {
    _firestore.collection('weightUnits').doc('weightUnits').snapshots().listen((documentSnapshot) {
      _fetchWeightUnits();
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

  void _fetchWeightUnits() {
    _firestore.collection('weightUnits').doc('weightUnits').get().then((DocumentSnapshot doc) {
      if (doc.exists) {
        final dynamic data = doc.data();
        if (data != null && data['weightUnits'] != null) {
          final List<dynamic> unitsList = data['weightUnits'];
          weightUnits.assignAll(unitsList.map((unit) => unit.toString()).toList());
        }
      }
    }).catchError((error) {
      print('Failed to fetch weight units: $error');
    });
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

  Future<void> addWeightUnit(String unit) async {
    try {
      await _firestore.collection('weightUnits').doc('weightUnits').update({
        'weightUnits': FieldValue.arrayUnion([unit]),
      });
      ShowSnackBar.showSnackBarCRUDSuccess(msg: "Weight Unit Added Successfully");
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to add Weight Unit');
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

  Future<void> deleteWeightUnit(String unit) async {
    try {
      await _firestore.collection('weightUnits').doc('weightUnits').update({
        'weightUnits': FieldValue.arrayRemove([unit]),
      });
      units.remove(unit);
      ShowSnackBar.showSnackBarCRUDSuccess(msg: "Weight Unit Deleted Successfully");
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to delete unit');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).set(product.toJson());
      await _updateCategoryIfNecessary(product.category);
      ShowSnackBar.showSnackBarCRUDSuccess(msg: "Product Added Successfully");
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to add product');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('products').doc(product.id).get();
      if (doc.exists) {
        final oldProduct = Product.fromFirestore(doc);
        await _firestore.collection('products').doc(product.id).update(product.toJson());
        if (oldProduct.category != product.category) {
          await _updateCategoryIfNecessary(product.category);
          await _removeCategoryIfEmpty(oldProduct.category);
        }
      } else {
        await _firestore.collection('products').doc(product.id).update(product.toJson());
        await _updateCategoryIfNecessary(product.category);
      }
      ShowSnackBar.showSnackBarCRUDSuccess(msg: 'Updated Product Successfully');
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to update product');
    }
  }

  Future<void> deleteProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).delete();
      await _removeCategoryIfEmpty(product.category);
      ShowSnackBar.showSnackBarCRUDSuccess(msg: 'Deleted Product Successfully');
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to delete product');
    }
  }

  Future<void> _updateCategoryIfNecessary(String category) async {
    if (!categories.contains(category)) {
      await _firestore.collection('categories').doc('categories').update({
        'categories': FieldValue.arrayUnion([category]),
      });
      categories.add(category);
    }
  }

  Future<void> _removeCategoryIfEmpty(String category) async {
    final QuerySnapshot categoryProducts = await _firestore.collection('products').where('category', isEqualTo: category).get();
    if (categoryProducts.docs.isEmpty) {
      await _firestore.collection('categories').doc('categories').update({
        'categories': FieldValue.arrayRemove([category]),
      });
      categories.remove(category);
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
}
