import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:rk_distributor/controllers/user_management_controller.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/models/user_model.dart';
import 'package:rk_distributor/screens/User_Management_Screens/about_user_screen.dart';
import 'package:rk_distributor/screens/app_access_request_screen.dart';
import 'package:rk_distributor/widgets/custom_search_bar.dart';
import 'package:rk_distributor/widgets/custom_user_list_tile_mgmnt.dart';

import '../../widgets/nothing_to_be_displayed.dart';

class UserManagementScreen extends StatelessWidget {
  UserManagementScreen({Key? key});

  final TextEditingController _searchController = TextEditingController();
  final TextStyleController textStyleController = Get.find();
  final FocusNode _searchFocusNode = FocusNode();
  final UserManagementController userManagementController =
  Get.find<UserManagementController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Obx(() {
            int pendingRequests = userManagementController.users
                .where((user) => !user.appAccess)
                .length;
            return IconButton(
              onPressed: () {
                Get.to(AppAccessRequestScreen());
              },
              icon: badges.Badge(
                showBadge: pendingRequests == 0 ? false : true,
                badgeStyle: badges.BadgeStyle(padding: EdgeInsets.all(4)),
                badgeContent: Text(
                  '$pendingRequests',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                child: Icon(Icons.person_add),
              ),
            );
          }),
        ],
        title: Row(
          children: [
            Icon(Icons.security, size: 25),
            SizedBox(width: 8),
            Text(
              'Manage Users',
              style: textStyleController.appBarTextStyle.value,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: Obx(
                  () {
                return userManagementController.users.isEmpty
                    ? NothingToBeDisplayed()
                    : userManagementController.filteredUsers.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 40,
                      ),
                      SizedBox(
                        height: 9,
                      ),
                      Text("No results")
                    ],
                  ),
                )
                    : ListView.separated(
                  separatorBuilder: (context, index) =>
                  const Divider(),
                  itemCount:
                  userManagementController.filteredUsers.length,
                  itemBuilder: (context, index) {
                    UserModel user =
                    userManagementController.filteredUsers[index];
                    return CustomUserListTileMgmnt(
                        user: user,
                        onTap: () {
                          _searchFocusNode.unfocus();
                          Get.to(AboutUserScreen(
                            user: user,
                          ));
                        });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: CustomSearchBar(
              searchController: _searchController,
              searchFocusNode: _searchFocusNode,
              onChanged: (value) {
                String query = value.toLowerCase();
                userManagementController.filteredUsers.assignAll(
                  userManagementController.users.where((user) {
                    return user.name.toLowerCase().contains(query) ||
                        user.email.toLowerCase().contains(query);
                  }).toList(),
                );
              },
              onClear: () {
                _searchController.clear();
                userManagementController.filteredUsers.assignAll(
                  userManagementController.users,
                );
              },
            ),
          ),
          SizedBox(width: 8.0), // Space between search bar and filter
          _buildFilterPopupMenu(),
        ],
      ),
    );
  }

  Widget _buildFilterPopupMenu() {
    return Obx(() {
      Widget currentFilter = _getFilterName(userManagementController.selectedFilter.value);
      return PopupMenuButton<UserFilter>(
        icon: Row(
          children: [
            Icon(Icons.filter_list),
            SizedBox(width: 4),
            currentFilter,
          ],
        ),
        onSelected: (UserFilter value) {
          userManagementController.applyFilter(value);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<UserFilter>>[
          PopupMenuItem<UserFilter>(
            value: UserFilter.all,
            child: Text('All'),
          ),
          PopupMenuItem<UserFilter>(
            value: UserFilter.superSu,
            child: Wrap(
              children: [
                Icon(
                  CommunityMaterialIcons.shield_account,
                  color: Colors.red,
                ),
                Text(' Super User'),
              ],
            ),
          ),
          PopupMenuItem<UserFilter>(
            value: UserFilter.appAccess,
            child: Wrap(
              children: [
                Icon(
                  CommunityMaterialIcons.check,
                  color: Colors.blue,
                ),
                Text(' App Access'),
              ],
            ),
          ),
          PopupMenuItem<UserFilter>(
            value: UserFilter.writeAccess,
            child: Wrap(
              children: [
                Icon(
                  CommunityMaterialIcons.pencil,
                  color: Colors.green,
                ),
                Text(' Write Access'),
              ],
            ),
          ),
          PopupMenuItem<UserFilter>(
            value: UserFilter.updateAccess,
            child: Wrap(
              children: [
                Icon(
                  CommunityMaterialIcons.update,
                  color: Colors.orange,
                ),
                Text(' Update Access'),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _getFilterName(UserFilter filter) {
    switch (filter) {
      case UserFilter.all:
        return SizedBox();
      case UserFilter.superSu:
        return Icon(CommunityMaterialIcons.shield_account,color: Colors.red,);
      case UserFilter.appAccess:
        return Icon(CommunityMaterialIcons.check,color: Colors.blue,);
      case UserFilter.writeAccess:
        return Icon(CommunityMaterialIcons.pencil,color: Colors.green,);
      case UserFilter.updateAccess:
        return Icon(CommunityMaterialIcons.update,color: Colors.orange,);
      default:
        return SizedBox();
    }
  }
}
