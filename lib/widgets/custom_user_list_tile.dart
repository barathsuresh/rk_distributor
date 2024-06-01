import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';

import '../models/user.dart';

class CustomUserListTile extends StatelessWidget {
  final User user;
  final Function onTap;

  CustomUserListTile({required this.user, required this.onTap});

  final TextStyleController textStyleController = Get.find();

  Widget _buildAccessIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (user.writeAccess)
          Icon(
            CommunityMaterialIcons.pencil,
            color: Colors.green,
            size: 20,
          ),
        if (user.updateAccess)
          Icon(
            CommunityMaterialIcons.update,
            color: Colors.orange,
            size: 20,
          ),
        if (user.appAccess)
          Icon(
            CommunityMaterialIcons.check,
            color: Colors.blue,
            size: 20,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          Color.lerp(Colors.white, Theme.of(context).colorScheme.primary, 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 2.0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(user.photoUrl ?? ''),
        ),
        title: Row(
          children: [
            Text(
              user.name,
              style: textStyleController.userListTileTitleStyle.value,
            ),
            SizedBox(width: 5,),
            if (user.superSu)
              Icon(
                CommunityMaterialIcons.shield_account,
                color: Colors.red,
                size: 20,
              )
          ],
        ),
        subtitle: Text(
          user.email,
          style: textStyleController.userListTileSubtitleStyle.value,
        ),
        trailing: _buildAccessIcons(),
        // Use the provided trailing widget
        onTap: () {
          // Handle tap action here
          onTap();
        },
      ),
    );
  }
}
