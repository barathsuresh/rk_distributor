import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/services/theme_service.dart';

class CustomUserTile extends StatelessWidget {
  final String photoUrl;
  final String title;
  final String subtitle;
  final Widget? trailing; // Make trailing optional
  final Function onTap;
  final TextStyle? titleTextStyle;
  final TextStyle? subTitleTextStyle;

  CustomUserTile({
    required this.photoUrl,
    required this.title,
    required this.subtitle,
    this.trailing, // Make trailing optional
    required this.onTap,
    this.titleTextStyle,
    this.subTitleTextStyle,
  });

  final TextStyleController textStyleController = Get.find();
  final ThemeService themeService = Get.find();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: CachedNetworkImageProvider(photoUrl ?? ''),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
        titleTextStyle ?? GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.bold,color: themeService.isDarkMode.value?Colors.white:Colors.black ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: subTitleTextStyle ??
            GoogleFonts.roboto(fontSize: 10,fontWeight: FontWeight.bold,color: Colors.grey ),
      ),
      trailing: trailing,
      // Use the provided trailing widget
      onTap: () {
        // Handle tap action here
        onTap();
      },
    );
  }
}
