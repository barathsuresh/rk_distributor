import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:rk_distributor/controllers/user_management_controller.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/models/user.dart';
import 'package:rk_distributor/screens/about_user_screen.dart';
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
                badgeStyle: badges.BadgeStyle(padding: EdgeInsets.all(4)),
                badgeContent: Text(
                  '$pendingRequests',
                  style: TextStyle(color: Colors.white, fontSize: 12),
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
          _buildFilterDropdownMenu(),
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
                                  user: user, onTap: () {
                                  Get.to(AboutUserScreen(user: user,));
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

  Widget _buildFilterDropdownMenu() {
    return Obx(
      () => Row(
        children: [
          IconButton(
            onPressed: () {
              // Implement filter action here
            },
            icon: Icon(Icons.filter_list),
          ),
          DropdownButton(
            value: userManagementController.selectedFilter.value,
            onChanged: (value) {
              userManagementController.applyFilter(value!);
            },
            items: [
              DropdownMenuItem(
                value: UserFilter.all,
                child: Text('All'),
              ),
              DropdownMenuItem(
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
              DropdownMenuItem(
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
              DropdownMenuItem(
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
              DropdownMenuItem(
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
          ),
        ],
      ),
    );
  }
}
