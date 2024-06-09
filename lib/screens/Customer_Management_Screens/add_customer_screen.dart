import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/services/customer_service.dart';

class AddCustomerScreen extends StatelessWidget {
  final CustomerService customerService = Get.find();
  final TextStyleController textStyleController = Get.find();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController areaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Customer',
          style: textStyleController.appBarTextStyle.value,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                keyboardType: TextInputType.name,
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              _buildAreaInput(), // Use dropdown for area selection
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final String enteredArea = areaController.text.trim();
                      if (enteredArea.isEmpty) {
                        Get.snackbar('Error', 'Please enter an area');
                      } else {
                        customerService.addCustomer(
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          area: enteredArea.trim(),
                        );
                        Get.back();
                      }
                    }
                  },
                  child: Text('Add Customer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaInput() {
    return TextField(
      keyboardType: TextInputType.streetAddress,
      controller: areaController,
      decoration: InputDecoration(
        labelText: 'Area',
        border: OutlineInputBorder(),
        suffixIcon: PopupMenuButton<String>(
          icon: Icon(Icons.arrow_drop_down),
          itemBuilder: (BuildContext context) {
            return customerService.areaList.map((String value) {
              return PopupMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList();
          },
          onSelected: (value) {
            areaController.text = value;
          },
        ),
      ),
    );
  }
}
