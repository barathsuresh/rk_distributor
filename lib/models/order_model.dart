import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'enums/order_status.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  List<OrderItem> orderItems;
  double totalPrice;
  final String orderBy;
  OrderStatus status;
  final Timestamp timestamp;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.orderItems,
    required this.totalPrice,
    required this.orderBy,
    required this.status,
    required this.timestamp,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItem> orderItems = (json['orderItems'] as List<dynamic>)
        .map((item) => OrderItem.fromJson(item))
        .toList();

    return OrderModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      orderItems: orderItems,
      totalPrice: json['totalPrice']?.toDouble() ?? 0.0,
      orderBy: json['orderBy'] ?? '',
      status: OrderStatus.values.firstWhere(
              (e) => e.name == json['status'], orElse: () => OrderStatus.pending),
      timestamp: json['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> orderItemsJson =
    orderItems.map((item) => item.toJson()).toList();

    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'orderItems': orderItemsJson,
      'totalPrice': totalPrice,
      'orderBy': orderBy,
      'status': status.name,
      'timestamp': timestamp,
    };
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;
    return OrderModel.fromJson(json);
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}

class OrderItem {
  final String prodId;
  final String name;
  int qty;
  double price;
  bool isPriceChange;
  double total;

  OrderItem({
    required this.prodId,
    required this.name,
    required this.qty,
    required this.price,
    required this.isPriceChange,
    required this.total,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      prodId: json['prodId'] ?? '',
      name: json['name'] ?? '',
      qty: json['qty'] ?? 0,
      price: json['price']?.toDouble() ?? 0.0,
      isPriceChange: json['isPriceChange'] ?? false,
      total: json['total']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prodId': prodId,
      'name':name,
      'qty': qty,
      'price': price,
      'isPriceChange': isPriceChange,
      'total': total,
    };
  }
}
