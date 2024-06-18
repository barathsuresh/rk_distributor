import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/api/id_generator.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/screens/Product_Management_Screens/add_product_screen.dart';
import 'package:rk_distributor/screens/Product_Management_Screens/barcode_scanner_screen.dart';
import 'package:rk_distributor/services/product_service.dart';
import 'package:rk_distributor/widgets/custom_list_tile.dart';

import '../../controllers/product_controller.dart';
import '../../utils/product_uploader.dart';
import '../../widgets/nothing_to_be_displayed.dart';

class ProductManagementScreen extends StatelessWidget {
  ProductManagementScreen({super.key});

  final TextStyleController textStyleController = Get.find();
  final ProductController productController = Get.find<ProductController>();
  final ProductService productService = Get.find();

  // todo: experimental
  final ProductUploader uploader = ProductUploader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            // todo: experimental code remove it
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.red)),
                  onPressed: () {
                    uploader.uploadProductsInBackground();
                  },
                  child: Text("Do not Press")),
            )
          ],
          title: Row(
            children: [
              Icon(CommunityMaterialIcons.tag, size: 25),
              SizedBox(width: 8),
              Text(
                'Products',
                style: textStyleController.appBarTextStyle.value,
              ),
            ],
          ),
        ),
        floatingActionButton: SpeedDial(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Icons.add,
          activeIcon: Icons.keyboard_arrow_up,
          children: [
            SpeedDialChild(
              child: Icon(Icons.qr_code_scanner),
              label: 'Scan',
              labelStyle: textStyleController.floatingActionButtonStyle.value,
              onTap: () {
                productController.clearContents();
                Get.to(BarcodeScannerScreen());
              },
            ),
            SpeedDialChild(
                child: Icon(Icons.add),
                label: 'Add',
                labelStyle: textStyleController.floatingActionButtonStyle.value,
                onTap: () {
                  productController.clearContents();
                  Get.to(AddProductScreen(
                      barcode: IdGenerator.generateUniqueIdTimeBased()));
                })
          ],
        ),
        body: Column(
          children: [
            CustomListTile(
              leadingIcon: Icons.straighten,
              title: "Add a Unit",
              subtitle: 'Give unit for your Products',
              onTap: () {
                _showAddUnitModal(context);
              },
            ),
          ],
        ));
  }

  void _showAddUnitModal(BuildContext context) {
    final TextEditingController unitController = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true, // This makes the modal bottom sheet scrollable
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              if (productService.units.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Manage My Units',
                      style: textStyleController.appBarTextStyle.value,
                    ),
                  ),
                ),
              if (productService.units.isNotEmpty) SizedBox(height: 10),
              if (productService.units.isNotEmpty)
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: productService.units.length,
                              itemBuilder: (context, index) {
                                final unit = productService.units[index];
                                return ListTile(
                                  title: Text(unit),
                                  trailing: IconButton(
                                    icon: Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () {
                                      productService.deleteUnit(unit);
                                    },
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a New Unit',
                      style: textStyleController.appBarTextStyle.value,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: unitController,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        final newUnit = unitController.text.trim();
                        if (newUnit.isNotEmpty) {
                          productService.addUnit(newUnit);
                          unitController.clear();
                        } else {
                          // Show some error or validation
                        }
                      },
                      child: Text('Add Unit'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
