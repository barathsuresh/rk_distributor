import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  String id;
  String name;
  String? description;
  String area;
  int orderFrequency;
  Customer({
    required this.id,
    required this.name,
    this.description,
    required this.area,
    required this.orderFrequency
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      area: json['area'],
      orderFrequency: json['orderFrequency']
    );
  }

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;
    return Customer.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'area': area,
      'orderFrequency':orderFrequency
    };
  }
}
