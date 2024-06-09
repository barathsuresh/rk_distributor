import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/models/customer_model.dart';

class CustomCustomerListTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final Widget? trailing;

  CustomCustomerListTile({
    required this.customer,
    required this.onTap,
    this.trailing
  });
  final TextStyleController textStyleController = Get.find();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(customer.name,style: textStyleController.userListTileTitleStyle.value,),
      leading: CircleAvatar(
        child: Icon(Icons.account_circle),
      ),
      subtitle: Text(customer.area,style: textStyleController.userListTileSubtitleStyle.value,),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
