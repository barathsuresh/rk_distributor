import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/controllers/barcode_scan_controller.dart';
import 'package:rk_distributor/screens/Product_Management_Screens/add_product_screen.dart';
import 'package:rk_distributor/utils/show_snackbar.dart';

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BarcodeScanController barcodeScannerController = Get.find();

    return AiBarcodeScanner(
        hideTitle: true,
        hideDragHandler: true,
        onDetect: (BarcodeCapture barcode) async {
          final List<dynamic> rawList = barcode.raw as List<dynamic>;
          final rawValue = rawList.first['rawValue'];
          // Check if the product exists
          bool exists = await barcodeScannerController.productExists(rawValue);
          if (!exists) {
            // Navigate to Add Product page with the scanned barcode
            Get.off(() => AddProductScreen(barcode: rawValue));
          } else {
            ShowSnackBar.showSnackBar(title: "Info", msg: "Product already exists in Database");
            // TODO: go to product info page if it exists
          }
        },
      );
  }
}
