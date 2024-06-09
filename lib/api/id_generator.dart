import 'package:uuid/uuid.dart';

class IdGenerator {
  static const uuid = Uuid();
  static String generateUniqueIdTimeBased() {
    return uuid.v1();
  }
}