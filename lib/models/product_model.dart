import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? brand;

  @HiveField(3)
  String? description;

  @HiveField(4)
  String unit;

  @HiveField(5)
  String category;

  @HiveField(6)
  double mrp;

  @HiveField(7)
  OurPrice ourPrice;

  @HiveField(8)
  int orderFrequency;

  @HiveField(9)
  String? createdBy;

  @HiveField(10)
  String? modifiedBy;

  @HiveField(11)
  String? lastOrderedOrderId;

  @HiveField(12)
  String addedOn;

  @HiveField(13)
  String modifiedOn;

  @HiveField(14)
  Weight weigh;

  Product({
    required this.id,
    required this.name,
    this.brand,
    this.description,
    required this.unit,
    required this.category,
    required this.mrp,
    required this.ourPrice,
    required this.orderFrequency,
    this.createdBy,
    this.modifiedBy,
    this.lastOrderedOrderId,
    required this.addedOn,
    required this.modifiedOn,
    required this.weigh,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      description: json['description'],
      unit: json['unit'],
      category: json['category'],
      mrp: json['MRP']?.toDouble() ?? 0.0,
      ourPrice: OurPrice.fromJson(json['ourPrice'] ?? {}),
      orderFrequency: json['orderFrequency']?.toInt() ?? 0,
      createdBy: json['createdBy'],
      modifiedBy: json['modifiedBy'],
      lastOrderedOrderId: json['lastOrderedOrderId'],
      addedOn: json['addedOn'],
      modifiedOn: json['modifiedOn'],
      weigh: Weight.fromJson(json['weigh'] ?? {}), // Handle null case
    );
  }


  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;
    return Product.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'description': description,
      'unit': unit,
      'category': category,
      'MRP': mrp,
      'ourPrice': ourPrice.toJson(),
      'orderFrequency': orderFrequency,
      'createdBy': createdBy,
      'modifiedBy': modifiedBy,
      'lastOrderedOrderId': lastOrderedOrderId,
      'addedOn': addedOn,
      'modifiedOn': modifiedOn,
      'weigh': weigh.toJson(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}

@HiveType(typeId: 1)
class OurPrice {
  @HiveField(0)
  double common;

  @HiveField(1)
  List<AreaPrice> area;

  @HiveField(2)
  List<CustomerPrice> customerPrices;

  OurPrice({
    required this.common,
    required this.area,
    required this.customerPrices,
  });

  factory OurPrice.fromJson(Map<String, dynamic> json) {
    var areaFromJson = json['area'] as List;
    var companyPricesFromJson = json['customerPrices'] as List;

    List<AreaPrice> areaList =
    areaFromJson.map((i) => AreaPrice.fromJson(i)).toList();
    List<CustomerPrice> companyPriceList =
    companyPricesFromJson.map((i) => CustomerPrice.fromJson(i)).toList();

    return OurPrice(
      common: json['common']?.toDouble() ?? 0.0,
      area: areaList,
      customerPrices: companyPriceList,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> areaToJson =
    area.map((i) => i.toJson()).toList();
    List<Map<String, dynamic>> companyPricesToJson =
    customerPrices.map((i) => i.toJson()).toList();

    return {
      'common': common,
      'area': areaToJson,
      'customerPrices': companyPricesToJson,
    };
  }
}

@HiveType(typeId: 2)
class AreaPrice {
  @HiveField(0)
  String name;

  @HiveField(1)
  double price;

  AreaPrice({
    required this.name,
    required this.price,
  });

  factory AreaPrice.fromJson(Map<String, dynamic> json) {
    return AreaPrice(
      name: json['name'],
      price: json['price']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}

@HiveType(typeId: 3)
class CustomerPrice {
  @HiveField(0)
  String customerId;

  @HiveField(1)
  double price;

  CustomerPrice({
    required this.customerId,
    required this.price,
  });

  factory CustomerPrice.fromJson(Map<String, dynamic> json) {
    return CustomerPrice(
      customerId: json['customerId'],
      price: json['price']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'price': price,
    };
  }
}

@HiveType(typeId:4)
class Weight{
  @HiveField(0)
  double weight;
  @HiveField(1)
  String unit;

  Weight({required this.weight,required this.unit});

  factory Weight.fromJson(Map<String, dynamic> json) {
    return Weight(
      weight: json['weight']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'unit': unit,
    };
  }

}
// @HiveType(typeId: 4)
// class Weight {
//   @HiveField(0)
//   double weight;
//
//   @HiveField(1)
//   String unit;
//
//   Weight({
//     required this.weight,
//     required this.unit,
//   });
//
//   factory Weight.fromJson(Map<String, dynamic> json) {
//     return Weight(
//       weight: json['weight']?.toDouble() ?? 0.0,
//       unit: json['unit'] ?? '', // Provide a default unit value or handle null case
//     );
//   }
//
//
//   Map<String, dynamic> toJson() {
//     return {
//       'weight': weight,
//       'unit': unit,
//     };
//   }
// }
