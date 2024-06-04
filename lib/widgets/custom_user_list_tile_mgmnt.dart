import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/services/theme_service.dart';

import '../models/user_model.dart';

class CustomUserListTileMgmnt extends StatelessWidget {
  final UserModel user;
  final Function? onTap;
  final Widget? trailing;

  CustomUserListTileMgmnt({required this.user, this.onTap, this.trailing});

  final TextStyleController textStyleController = Get.find();
  final ThemeService themeService = Get.find();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: CachedNetworkImageProvider(user.photoUrl ?? ''),
      ),
      title: Row(
        children: [
          Text(
            user.name,
            style: textStyleController.userListTileTitleStyle.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            width: 5,
          ),
          if (user.superSu)
            Icon(
              CommunityMaterialIcons.shield_account,
              color: Colors.red,
              size: 16,
            ),
          if (user.writeAccess)
            Icon(
              CommunityMaterialIcons.pencil,
              color: Colors.green,
              size: 16,
            ),
          if (user.updateAccess)
            Icon(
              CommunityMaterialIcons.update,
              color: Colors.orange,
              size: 16,
            ),
          if (user.appAccess)
            Icon(
              CommunityMaterialIcons.check,
              color: Colors.blue,
              size: 16,
            )
        ],
      ),
      subtitle: Text(
        user.email,
        style: textStyleController.userListTileSubtitleStyle.value,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: trailing,
      // Use the provided trailing widget
      onTap: () {
        // Handle tap action here
        onTap!();
      },
    );
  }
}
