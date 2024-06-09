import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id;
  String name;
  String? brand;
  String? description;
  String category;
  double mrp;
  OurPrice ourPrice;
  int orderFrequency;
  String? createdBy;
  String? modifiedBy;
  String? lastOrderedOrderId;
  String addedOn;
  String modifiedOn;

  Product({
    required this.id,
    required this.name,
    this.brand,
    this.description,
    required this.category,
    required this.mrp,
    required this.ourPrice,
    required this.orderFrequency,
    this.createdBy,
    this.modifiedBy,
    this.lastOrderedOrderId,
    required this.addedOn,
    required this.modifiedOn,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      description: json['description'],
      category: json['category'],
      mrp: json['MRP']?.toDouble() ?? 0.0,
      ourPrice: OurPrice.fromJson(json['ourPrice']),
      orderFrequency: json['orderFrequency']?.toInt() ?? 0,
      createdBy: json['createdBy'],
      modifiedBy: json['modifiedBy'],
      lastOrderedOrderId: json['lastOrderedOrderId'],
      addedOn: json['addedOn'],
      modifiedOn: json['modifiedOn'],
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
      'category':category,
      'MRP': mrp,
      'ourPrice': ourPrice.toJson(),
      'orderFrequency': orderFrequency,
      'createdBy': createdBy,
      'modifiedBy': modifiedBy,
      'lastOrderedOrderId': lastOrderedOrderId,
      'addedOn': addedOn,
      'modifiedOn': modifiedOn,
    };
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}

class OurPrice {
  double common;
  List<AreaPrice> area;
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

class AreaPrice {
  String name;
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

class CustomerPrice {
  String customerId;
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
