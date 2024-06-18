import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/services/product_service.dart';
import 'package:rk_distributor/services/customer_service.dart';
import '../../models/customer_model.dart';
import '../../models/product_model.dart';
import '../../controllers/product_controller.dart';
import '../../utils/show_snackbar.dart';
import '../../widgets/custom_drop_down_text_field.dart';

class AddProductScreen extends StatelessWidget {
  final String barcode;
  final _formKey = GlobalKey<FormState>();

  AddProductScreen({required this.barcode});

  final TextStyleController textStyleController = Get.find();
  final ProductService productService = Get.find<ProductService>();
  final CustomerService customerService = Get.find<CustomerService>();
  final ProductController productController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: _buildColumn(),
        ),
      ),
    );
  }

  Column _buildColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.sentences,
          controller: productController.nameController,
          decoration: InputDecoration(
            labelText: 'Product Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a Product Name';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.sentences,
          controller: productController.brandController,
          decoration: InputDecoration(
            labelText: 'Brand',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        TextFormField(
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.sentences,
          controller: productController.descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        Obx(() {
          return SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: productController.selectedUnit.value.isEmpty
                  ? null
                  : productController.selectedUnit.value,
              decoration: InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
              ),
              items: productService.units.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: SizedBox(width: 50, child: Text(unit)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                productController.selectedUnit.value = newValue ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Unit';
                }
                return null;
              },
            ),
          );
        }),
        SizedBox(height: 16),
        TextFormField(
          controller: productController.mrpController,
          decoration: InputDecoration(
            labelText: 'MRP',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter MRP';
            }
            return null;
          },
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: productController.commonPriceController,
          decoration: InputDecoration(
            labelText: 'Common Price',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Common Price';
            }
            return null;
          },
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        CustomDropdownTextField(
          keyboardType: TextInputType.name,
          options: productService.categories.toList(),
          hintText: 'Category',
          controller: productController.categoryController,
        ),
        SizedBox(height: 20),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Area Prices',
                style: textStyleController.h2CommonStyleBoldRoboto.value,
              ),
              TextButton(
                onPressed: isAddAreaPriceEnabled()
                    ? productController.addAreaPrice
                    : null,
                child: Text('Add Area Price'),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Obx(() => ListView.separated(
              shrinkWrap: true,
              itemCount: productController.areaPrices.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: DropdownButton<String>(
                          underline: SizedBox.shrink(),
                          value:
                              productController.areaPrices[index].name.isEmpty
                                  ? null
                                  : productController.areaPrices[index].name,
                          hint: Text('Select Area'),
                          items: customerService.areaList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                truncateString(value, 10),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              productController.areaPrices[index] = AreaPrice(
                                  name: value,
                                  price: productController
                                      .areaPrices[index].price);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter area price';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          double? price = double.tryParse(value);
                          if (price != null) {
                            productController.areaPrices[index] = AreaPrice(
                                name: productController.areaPrices[index].name,
                                price: price);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => productController.removeAreaPrice(index),
                    ),
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 8,
                );
              },
            )),
        SizedBox(height: 20),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Prices',
                style: textStyleController.h2CommonStyleBoldRoboto.value,
              ),
              TextButton(
                onPressed: isAddCustomerPriceEnabled()
                    ? productController.addCustomerPrice
                    : null,
                child: Text('Add Customer Price'),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Obx(() => ListView.separated(
              shrinkWrap: true,
              itemCount: productController.customerPrices.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: DropdownButton<String>(
                          value: productController
                                  .customerPrices[index].customerId.isEmpty
                              ? null
                              : productController
                                  .customerPrices[index].customerId,
                          hint: Text('Select Customer'),
                          underline: SizedBox.shrink(),
                          items: customerService.customers
                              .map((Customer customer) {
                            return DropdownMenuItem<String>(
                              value: customer.id,
                              child: Text(
                                truncateString(customer.name, 7),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              productController.customerPrices[index] =
                                  CustomerPrice(
                                      customerId: value,
                                      price: productController
                                          .customerPrices[index].price);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter customer price';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          double? price = double.tryParse(value);
                          if (price != null) {
                            productController.customerPrices[index] =
                                CustomerPrice(
                                    customerId: productController
                                        .customerPrices[index].customerId,
                                    price: price);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                      ),
                      onPressed: () =>
                          productController.removeCustomerPrice(index),
                    ),
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 8,
                );
              },
            )),
        SizedBox(height: 20),
        Align(
            alignment: Alignment.bottomRight,
            child: FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Check for duplicates in area prices
                  if (!hasDuplicateAreaPrices(productController.areaPrices)) {
                    // Check for duplicates in customer prices
                    if (!hasDuplicateCustomerPrices(
                        productController.customerPrices)) {
                      // Add the product
                      Product product = Product(
                        id: barcode,
                        name: productController.nameController.text,
                        brand: productController.brandController.text,
                        description:
                            productController.descriptionController.text,
                        unit: productController.selectedUnit.value,
                        category: productController.categoryController.text,
                        mrp: double.tryParse(
                                productController.mrpController.text) ??
                            0.0,
                        ourPrice: OurPrice(
                          common: double.tryParse(productController
                                  .commonPriceController.text) ??
                              0.0,
                          area: productController.areaPrices,
                          customerPrices: productController.customerPrices,
                        ),
                        orderFrequency: 0,
                        addedOn:
                            DateTime.now().microsecondsSinceEpoch.toString(),
                        modifiedOn:
                            DateTime.now().microsecondsSinceEpoch.toString(),
                      );
                      productService.addProduct(product);
                      Get.back();
                    } else {
                      // Show error message for duplicate customer prices
                      ShowSnackBar.showSnackBar(
                          title: "Error",
                          msg: "Duplicate customer prices are not allowed");
                    }
                  } else {
                    // Show error message for duplicate area prices
                    ShowSnackBar.showSnackBar(
                        title: "Error",
                        msg: "Duplicate area prices are not allowed");
                  }
                }
              },
              child: Text('Add Product'),
            )),
      ],
    );
  }

  String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength) + '...';
    }
  }

  // Helper method to determine if adding an area price is enabled
  bool isAddAreaPriceEnabled() {
    return productController.areaPrices.length <
            customerService.areaList.length &&
        !productController.isAreaPriceAlreadyAdded();
  }

// Helper method to determine if adding a customer price is enabled
  bool isAddCustomerPriceEnabled() {
    return productController.customerPrices.length <
            customerService.customers.length &&
        !productController.isCustomerPriceAlreadyAdded();
  }

  // Helper method to check for duplicate area prices
  bool hasDuplicateAreaPrices(List<AreaPrice> areaPrices) {
    Set<String> uniqueAreaPrices = {};
    for (AreaPrice areaPrice in areaPrices) {
      if (!uniqueAreaPrices.add(areaPrice.name)) {
        return true; // Duplicate found
      }
    }
    return false; // No duplicates
  }

  // Helper method to check for duplicate customer prices
  bool hasDuplicateCustomerPrices(List<CustomerPrice> customerPrices) {
    Set<String> uniqueCustomerPrices = {};
    for (CustomerPrice customerPrice in customerPrices) {
      if (!uniqueCustomerPrices.add(customerPrice.customerId)) {
        return true; // Duplicate found
      }
    }
    return false; // No duplicates
  }
}
