import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BarcodeScanController extends GetxController{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> productExists(String barcode) async {
    final querySnapshot = await _firestore.collection('products').doc(barcode).get();
    return querySnapshot.exists;
  }
}