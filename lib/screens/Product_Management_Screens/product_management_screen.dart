import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:rk_distributor/api/id_generator.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/screens/Product_Management_Screens/add_product_screen.dart';
import 'package:rk_distributor/screens/Product_Management_Screens/barcode_scanner_screen.dart';

import '../../controllers/product_controller.dart';
import '../../widgets/nothing_to_be_displayed.dart';

class ProductManagementScreen extends StatelessWidget {
  ProductManagementScreen({super.key});

  final TextStyleController textStyleController = Get.find();
  final ProductController productController = Get.find<ProductController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
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
      body: Center(
        child: NothingToBeDisplayed(text: "Go to Market Place to View all Products",icon: Icon(CommunityMaterialIcons.store),),
      ),
    );
  }
}
