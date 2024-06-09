import 'dart:async';
import 'dart:isolate';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/utils/show_snackbar.dart';
import '../api/id_generator.dart';
import '../models/customer_model.dart';
import '../models/product_model.dart';

class CustomerService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Customer> customers = <Customer>[].obs;
  final RxList<Customer> filteredCustomers = <Customer>[].obs;
  final RxList<String> areaList = <String>[].obs; // Add this line
  final RxString selectedArea = ''.obs;
  late StreamSubscription _customerSubscription;

  @override
  void onInit() {
    super.onInit();
    _startCustomerListener();
  }

  void _startCustomerListener() {
    _customerSubscription =
        _firestore.collection('customers').snapshots().listen((querySnapshot) {
      final customerList =
          querySnapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList();
      customers.assignAll(customerList);
      _updateAreaList(); // Update area list whenever customers list is updated
      filterCustomersByArea();
    });
  }

  Future<void> addCustomer(
      {required String name, String? description, required String area}) async {
    if (name.isEmpty || area.isEmpty) {
      ShowSnackBar.showSnackBar(
          title: "Error", msg: "Name or Area cannot be empty");
      return;
    }
    try {
      final String id = IdGenerator.generateUniqueIdTimeBased();
      final customer = Customer(
        id: id,
        name: name,
        description: description,
        area: area,
        orderFrequency: 0,
      );
      await _firestore.collection('customers').doc(id).set(customer.toJson());
      ShowSnackBar.showSnackBarCRUDSuccess(msg: "Customer Added Successfully");
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(e: e, msg: 'Failed to add customer');
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _firestore
          .collection('customers')
          .doc(customer.id)
          .update(customer.toJson());
      ShowSnackBar.showSnackBarCRUDSuccess(
          msg: 'Updated Customer Successfully');
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(
          e: e, msg: 'Failed to update customer');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _firestore.collection('customers').doc(id).delete();
      ShowSnackBar.showSnackBarCRUDSuccess(
          msg: 'Deleted Customer Successfully');
    } on Exception catch (e) {
      ShowSnackBar.showSnackBarException(
          e: e, msg: 'Failed to Delete customer');
    }
  }

  void filterCustomers(String query) {
    final lowerQuery = query.toLowerCase();
    filteredCustomers.assignAll(customers.where((customer) {
      return customer.name.toLowerCase().contains(lowerQuery) ||
          customer.area.toLowerCase().contains(lowerQuery);
    }).toList());
  }

  void filterByArea(String area) {
    selectedArea.value = area;
    filterCustomersByArea();
  }

  void filterCustomersByArea() {
    if (selectedArea.isEmpty) {
      filteredCustomers.assignAll(customers);
    } else {
      filteredCustomers.assignAll(customers.where((customer) {
        return customer.area == selectedArea.value;
      }).toList());
    }
  }

  void clearFilter() {
    selectedArea.value = '';
    filteredCustomers.assignAll(customers);
  }

  void _updateAreaList() {
    final areas = customers.map((customer) => customer.area).toSet().toList();
    areaList.assignAll(areas);
  }

  Customer? getCustomerById(String id) {
    return customers.firstWhere((customer) => customer.id == id);
  }

  @override
  void onClose() {
    _customerSubscription.cancel();
    super.onClose();
  }
}
