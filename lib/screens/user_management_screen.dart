import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:rk_distributor/controllers/user_management_controller.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/models/user.dart';
import 'package:rk_distributor/widgets/custom_user_list_tile.dart';

class UserManagementScreen extends StatelessWidget {
  UserManagementScreen({Key? key});

  final TextStyleController textStyleController = Get.find();
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
                // TODO: Implement Requests function
              },
              icon: badges.Badge(
                badgeContent: Text(
                  '$pendingRequests',
                  style: TextStyle(color: Colors.white),
                ),
                child: Icon(Icons.person_add),
              ),
            );
          }),
          IconButton(
            onPressed: () {
              // TODO: Implement Search function
            },
            icon: Icon(Icons.search),
          )
        ],
        title: Row(
          children: [
            Icon(Icons.people, size: 25),
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
          _buildFilterChips(),
          Expanded(
            child: Obx(
              () {
                return userManagementController.users.isEmpty
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
                            Text("Nothing To Be Displayed")
                          ],
                        ),
                      )
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
                        : ListView.builder(
                            itemCount:
                                userManagementController.filteredUsers.length,
                            itemBuilder: (context, index) {
                              User user =
                                  userManagementController.filteredUsers[index];
                              return CustomUserListTile(
                                  user: user, onTap: () {});
                            },
                          );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(
      () => Align(
        alignment: Alignment.topLeft,
        child: Container(
          padding: EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text('All'),
                selected: userManagementController.selectedFilter.value ==
                    UserFilter.all,
                onSelected: (selected) {
                  userManagementController.applyFilter(UserFilter.all);
                },
              ),
              FilterChip(
                label: Text('Super User'),
                selected: userManagementController.selectedFilter.value ==
                    UserFilter.superSu,
                onSelected: (selected) {
                  userManagementController.applyFilter(UserFilter.superSu);
                },
              ),
              FilterChip(
                label: Text('App Access'),
                selected: userManagementController.selectedFilter.value ==
                    UserFilter.appAccess,
                onSelected: (selected) {
                  userManagementController.applyFilter(UserFilter.appAccess);
                },
              ),
              FilterChip(
                label: Text('Write Access'),
                selected: userManagementController.selectedFilter.value ==
                    UserFilter.writeAccess,
                onSelected: (selected) {
                  userManagementController.applyFilter(UserFilter.writeAccess);
                },
              ),
              FilterChip(
                label: Text('Update Access'),
                selected: userManagementController.selectedFilter.value ==
                    UserFilter.updateAccess,
                onSelected: (selected) {
                  userManagementController.applyFilter(UserFilter.updateAccess);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
