import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';

class CustomListTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final Widget? trailing; // Make trailing optional
  final Function onTap;
  final Color? color;
  final TextStyle? titleTextStyle;
  final TextStyle? subTitleTextStyle;

  CustomListTile({
    this.color,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    this.trailing, // Make trailing optional
    required this.onTap,
    this.titleTextStyle,
    this.subTitleTextStyle,
  });

  final TextStyleController textStyleController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ??
          Color.lerp(Colors.white, Theme.of(context).colorScheme.primary, 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 2.0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        leading: CircleAvatar(
          child: Icon(leadingIcon),
        ),
        title: Text(
          title,
          style:
              titleTextStyle ?? textStyleController.listTileTextMainStyle.value,
        ),
        subtitle: Text(
          subtitle,
          style: subTitleTextStyle ??
              textStyleController.listTileTextSubtitleStyle.value,
        ),
        trailing: trailing,
        // Use the provided trailing widget
        onTap: () {
          // Handle tap action here
          onTap();
        },
      ),
    );
  }
}
