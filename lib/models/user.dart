import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final bool superSu;
  final bool updateAccess;
  final bool writeAccess;
  final bool appAccess;
  final String createdAt;
  final String email;
  final String lastLoginAt;
  final bool loggedIn;
  final String photoUrl;
  final String uid;
  final String name;

  User(
      {required this.superSu,
      required this.updateAccess,
      required this.writeAccess,
      required this.appAccess,
      required this.createdAt,
      required this.email,
      required this.lastLoginAt,
      required this.loggedIn,
      required this.photoUrl,
      required this.uid,
      required this.name});

  // Factory method to create a UserModel from a Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return User(
        superSu: data['access']['superSu'] ?? false,
        updateAccess: data['access']['updateAccess'] ?? false,
        writeAccess: data['access']['writeAccess'] ?? false,
        appAccess: data['appAccess'] ?? false,
        createdAt: data['createdAt'] ?? '',
        email: data['email'] ?? '',
        lastLoginAt: data['lastLoginAt'] ?? '',
        loggedIn: data['loggedIn'] ?? false,
        photoUrl: data['photoUrl'] ?? '',
        uid: data['uid'] ?? '',
        name: data['name'] ?? '');
  }

  // Method to convert UserModel to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'access': {
        'superSu': superSu,
        'updateAccess': updateAccess,
        'writeAccess': writeAccess,
        'appAccess': appAccess,
      },
      'createdAt': createdAt,
      'email': email,
      'lastLoginAt': lastLoginAt,
      'loggedIn': loggedIn,
      'photoUrl': photoUrl,
      'uid': uid,
      'name': name,
    };
  }
}
