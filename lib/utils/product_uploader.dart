import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';
import '../models/product_model.dart';

class ProductUploader {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Faker faker = Faker();

  Future<void> uploadProductsInBackground() async {
    Workmanager().registerOneOffTask(
      'uploadProductsTask',
      'uploadProductsTask',
    );
  }

  Future<List<Product>> generateProducts(int count) async {
    List<Product> products = [];
    for (int i = 0; i < count; i++) {
      products.add(
        Product(
            id: faker.guid.guid(),
            name: faker.food.dish(),
            unit: faker.randomGenerator.element(['kg', 'ltr', 'pcs', 'box']),
            category: faker.food.cuisine(),
            mrp: faker.randomGenerator.decimal(min: 100, scale: 1000),
            ourPrice: await generateRandomOurPrice(),
            orderFrequency: faker.randomGenerator.integer(100),
            addedOn: DateTime.now().microsecondsSinceEpoch.toString(),
            modifiedOn: DateTime.now().microsecondsSinceEpoch.toString(),
            weigh: generateWeight(),
      ));
    }
    return products;
  }

  Weight generateWeight() {
    return Weight(
        weight: faker.randomGenerator.decimal(min: 1, scale: 999),
        unit: faker.randomGenerator.element(['kg', 'ltr', 'mg', 'ml']));
  }

  Future<OurPrice> generateRandomOurPrice() async {
    final customers = await _fetchCustomersFromFirestore();

    // Check if the lists are populated
    if (customers.isEmpty) {
      print("Customer list is empty");
    } else {
      print("Customer list is populated with ${customers.length} items");
    }

    final areaList = customers
        .map((customer) => customer['area'] as String)
        .toSet()
        .toList();

    if (areaList.isEmpty) {
      print("Area list is empty");
    } else {
      print("Area list is populated with ${areaList.length} items");
    }

    List<AreaPrice> areaPrices = areaList
        .map((area) => AreaPrice(
              name: area,
              price: faker.randomGenerator.decimal(min: 100, scale: 1000),
            ))
        .toList();

    List<CustomerPrice> customerPrices = customers
        .map((customer) => CustomerPrice(
              customerId: customer['id'],
              price: faker.randomGenerator.decimal(min: 100, scale: 1000),
            ))
        .toList();

    print(
        "Generated ${areaPrices.length} area prices and ${customerPrices.length} customer prices");

    return OurPrice(
      common: faker.randomGenerator.decimal(min: 100, scale: 1000),
      area: areaPrices,
      customerPrices: customerPrices,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCustomersFromFirestore() async {
    final customerQuerySnapshot = await firestore.collection('customers').get();
    return customerQuerySnapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();
  }
}
