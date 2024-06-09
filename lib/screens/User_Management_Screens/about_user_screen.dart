import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rk_distributor/api/local_auth_api.dart';
import 'package:rk_distributor/constants/util_functions.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/controllers/user_controller.dart';
import 'package:rk_distributor/services/theme_service.dart';
import 'package:rk_distributor/widgets/custom_dialog_box.dart';
import 'package:rk_distributor/widgets/custom_list_tile.dart';

import '../../models/user_model.dart';

class AboutUserScreen extends StatelessWidget {
  AboutUserScreen({required this.user});

  UserModel user;

  final TextStyleController textStyleController = Get.find();
  final UserController userController = Get.put(UserController());
  final ThemeService themeService = Get.find();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    userController.setUser(user);
    final ScrollController _scrollController = ScrollController();
    bool _isScrollingDown = false;

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // User is scrolling down
        if (!_isScrollingDown) {
          _isScrollingDown = true;
          userController.showEditing(false); // Hide FAB
        }
      } else {
        // User is scrolling up
        if (_isScrollingDown) {
          _isScrollingDown = false;
          userController.showEditing(true); // Show FAB
        }
      }

      // Check if scroll position is at maximum extent
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        userController.showEditing(false); // Hide FAB
      }
    });
    return Obx(
      () => WillPopScope(
        onWillPop: () async {
          if (userController.isEditing.value) {
            userController.toggleEditing(saveChanges: false);
            return false; // Prevent navigation
          }
          return true; // Allow navigation
        },
        child: Scaffold(
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          appBar: AppBar(
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    userController.user.value!.name,
                    style: textStyleController.appBarTextStyle.value,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  if (userController.user.value!.superSu)
                    Icon(
                      CommunityMaterialIcons.shield_account,
                      color: Colors.red,
                      size: 20,
                    )
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: userController.isEditing.value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton.extended(
                      label: Row(
                        children: [
                          Icon(CommunityMaterialIcons.cancel),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Cancel",
                            style: textStyleController
                                .floatingActionButtonStyle.value,
                          )
                        ],
                      ),
                      onPressed: () {
                        userController.toggleEditing(saveChanges: false);
                      },
                      backgroundColor: Colors.red,
                    ),
                    SizedBox(width: 10),
                    FloatingActionButton.extended(
                      label: Row(
                        children: [
                          Icon(CommunityMaterialIcons.content_save),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Save",
                            style: textStyleController
                                .floatingActionButtonStyle.value,
                          )
                        ],
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Form is valid, save changes
                          userController.toggleEditing();
                        }
                      },
                    ),
                  ],
                )
              : userController.showFAB.value
                  ? FloatingActionButton(
                      onPressed: () {
                        userController.toggleEditing();
                      },
                      child: Icon(CommunityMaterialIcons.pencil),
                    )
                  : null,
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: userController.isEditing.value
                      ? _buildUserProfileEditing()
                      : _buildUserProfile(context),
                ),
                if (!userController.isEditing.value)
                  Divider(
                    color: Color.lerp(
                        themeService.isDarkMode.value
                            ? Colors.black
                            : Colors.white,
                        Theme.of(context).colorScheme.primary,
                        0.8),
                  ),
                if (!userController.isEditing.value)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3.0, left: 8.0),
                      child: Text(
                        "Manage Access",
                        style: GoogleFonts.roboto(
                            fontSize: 20,
                            color: Color.lerp(
                                themeService.isDarkMode.value
                                    ? Colors.black
                                    : Colors.white,
                                Theme.of(context).colorScheme.primary,
                                0.8),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (!userController.isEditing.value) _buildListItems(context),
                if (!userController.isEditing.value)
                  Divider(
                    color: Color.lerp(
                        themeService.isDarkMode.value
                            ? Colors.black
                            : Colors.white,
                        Theme.of(context).colorScheme.primary,
                        0.8),
                  ),
                if (!userController.isEditing.value)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3.0, left: 8.0),
                      child: Text(
                        "Actions",
                        style: GoogleFonts.roboto(
                            fontSize: 20,
                            color: Color.lerp(
                                themeService.isDarkMode.value
                                    ? Colors.black
                                    : Colors.white,
                                Theme.of(context).colorScheme.primary,
                                0.8),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (!userController.isEditing.value)
                  _buildListItemsActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItemsActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 5), // Spacing between list items

        // Logout User
        CustomListTile(
          titleTextStyle: textStyleController.userListTileTitleStyle.value,
          subTitleTextStyle:
              textStyleController.userListTileSubtitleStyle.value,
          title: 'Logout This User',
          trailing: Icon(
            CommunityMaterialIcons.logout,
          ),
          onTap: () {
            // TODO: Implement logout functionality here

          },
          leadingIcon: CommunityMaterialIcons.logout,
          subtitle: 'Remotely log out the user.',
        ),

        SizedBox(height: 5), // Spacing between list items

        // Delete User
        CustomListTile(
          titleTextStyle: textStyleController.userListTileTitleStyle.value,
          subTitleTextStyle:
              textStyleController.userListTileSubtitleStyle.value,
          title: 'Delete User',
          onTap: () {
            // TODO: Implement delete functionality here

          },
          leadingIcon: CommunityMaterialIcons.account_remove,
          subtitle: 'All Data Related to this user will be deleted.',
          trailing: Icon(
            CommunityMaterialIcons.delete,
            color: Colors.red,
          ),
        )
      ],
    );
  }

  Widget _buildListItems(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          SizedBox(height: 5), // Spacing between list items

          // SuperSu Access
          CustomListTile(
            title: 'SuperSu Access',
            trailing: Switch(
              value: userController.user.value!.superSu,
              onChanged: (value) async {
                bool auth = await LocalAuthApi.authenticate();
                if (auth) {
                  userController.toggleSuperSuAccess();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => CustomDialogBox(
                      title: 'Authentication Required',
                      content: 'Biometric is required to perform this action',
                      actions: [
                        TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text(
                            'OK',
                            style: GoogleFonts.roboto(),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            leadingIcon: CommunityMaterialIcons.shield_account,
            subtitle: 'Grant administrator rights selectively to users.',
            onTap: () {},
            titleTextStyle: textStyleController.userListTileTitleStyle.value,
            subTitleTextStyle:
                textStyleController.userListTileSubtitleStyle.value,
          ),

          SizedBox(height: 5), // Spacing between list items

          // Write Access
          CustomListTile(
            titleTextStyle: textStyleController.userListTileTitleStyle.value,
            subTitleTextStyle:
                textStyleController.userListTileSubtitleStyle.value,
            title: 'Write Access',
            trailing: Switch(
              value: userController.user.value!.writeAccess,
              onChanged: (value) {
                userController.toggleWriteAccess();
              },
            ),
            leadingIcon: CommunityMaterialIcons.pencil,
            subtitle: 'Grant access to create new Products',
            onTap: () {},
          ),

          SizedBox(height: 5), // Spacing between list items

          // Update Access
          CustomListTile(
            titleTextStyle: textStyleController.userListTileTitleStyle.value,
            subTitleTextStyle:
                textStyleController.userListTileSubtitleStyle.value,
            title: 'Update Access',
            trailing: Switch(
              value: userController.user.value!.updateAccess,
              onChanged: (value) {
                userController.toggleUpdateAccess();
              },
            ),
            leadingIcon: CommunityMaterialIcons.update,
            subtitle: 'Grant access to update Products',
            onTap: () {},
          ),

          SizedBox(height: 5), // Spacing between list items

          // App Access
          CustomListTile(
            titleTextStyle: textStyleController.userListTileTitleStyle.value,
            subTitleTextStyle:
                textStyleController.userListTileSubtitleStyle.value,
            title: 'App Access',
            trailing: Switch(
              value: userController.user.value!.appAccess,
              onChanged: (value) async {
                bool auth = await LocalAuthApi.authenticate();
                if (auth) {
                  userController.toggleAppAccess();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => CustomDialogBox(
                      title: 'Authentication Required',
                      content: 'Biometric is required to perform this action',
                      actions: [
                        TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text(
                            'OK',
                            style: GoogleFonts.roboto(),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            leadingIcon: CommunityMaterialIcons.check,
            subtitle: 'User access restricted when enabled.',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: Card(
        color: Color.lerp(
            themeService.isDarkMode.value ? Colors.black : Colors.white,
            Theme.of(context).colorScheme.primary,
            0.4),
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              // Profile Picture
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                    userController.user.value!.photoUrl ?? ''),
                radius: 64,
              ),
              SizedBox(width: 16),
              // Name and Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userController.user.value!.name,
                      style: textStyleController.userProfileNameStyle.value,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          size: 15,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          userController.user.value!.email,
                          style:
                              textStyleController.userProfileEmailStyle.value,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 15,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          formattedDateFromMicroSecondsSinceEpochString(
                              userController.user.value!.createdAt),
                          style:
                              textStyleController.userProfileEmailStyle.value,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileEditing() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: Card(
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile Picture
                    Hero(
                      tag: "prof",
                      child: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            userController.user.value!.photoUrl ?? ''),
                        radius: 64,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Name (editable when editing mode is on)
                TextFormField(
                  controller: TextEditingController(
                      text: userController.user.value!.name),
                  enabled: userController.isEditing.value,
                  keyboardType: TextInputType.name,
                  onChanged: (value) {
                    userController.user.value!.name = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // Email (editable when editing mode is on)
                TextFormField(
                  controller: TextEditingController(
                      text: userController.user.value!.email),
                  keyboardType: TextInputType.emailAddress,
                  enabled: userController.isEditing.value,
                  onChanged: (value) {
                    userController.user.value!.email = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    // Regular expression for email validation
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // No Save Button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
