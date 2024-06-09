import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:rk_distributor/models/customer_model.dart';
import 'package:rk_distributor/services/customer_service.dart';

class CustomerController extends GetxController {
  final CustomerService customerService = Get.find();
  final Customer customer;

  CustomerController(this.customer);

  var isEditing = false.obs;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final areaController = TextEditingController();

  late String originalName;
  late String originalDescription;
  late String originalArea;

  @override
  void onInit() {
    super.onInit();
    originalName = customer.name;
    originalDescription = customer.description ?? '';
    originalArea = customer.area;

    nameController.text = originalName;
    descriptionController.text = originalDescription;
    areaController.text = originalArea;
  }

  void toggleEdit() {
    if (isEditing.value) {
      // Revert to original values
      nameController.text = originalName;
      descriptionController.text = originalDescription;
      areaController.text = originalArea;
    }
    isEditing.value = !isEditing.value;
  }

  void updateCustomer() {
    final updatedCustomer = Customer(
      id: customer.id,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      area: areaController.text.trim(),
      orderFrequency: customer.orderFrequency,
    );
    customerService.updateCustomer(updatedCustomer).then((_) {
      customer.name = updatedCustomer.name;
      customer.description = updatedCustomer.description!;
      customer.area = updatedCustomer.area;

      // Update original values
      originalName = updatedCustomer.name;
      originalDescription = updatedCustomer.description!;
      originalArea = updatedCustomer.area;

      toggleEdit();
    });
  }

  Future<void> deleteCustomer(Customer customer) async {
    await customerService.deleteCustomer(customer.id);
  }
}
