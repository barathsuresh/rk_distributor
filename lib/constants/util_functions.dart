import 'package:intl/intl.dart';

final formattedDateFromMicroSecondsSinceEpochString = (String? createdAt){
  final created = DateTime.fromMicrosecondsSinceEpoch(int.parse(createdAt!));
  return DateFormat('dd-MMM-yyyy').format(created);
};