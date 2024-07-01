import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/models/customer_model.dart';
import 'package:rk_distributor/screens/Customer_Management_Screens/about_customer_screen.dart';
import 'package:rk_distributor/screens/Customer_Management_Screens/add_customer_screen.dart';
import 'package:rk_distributor/services/customer_service.dart';
import 'package:rk_distributor/services/marketplace_service.dart';
import 'package:rk_distributor/widgets/custom_search_bar.dart';
import 'package:rk_distributor/widgets/custom_customer_list_tile.dart';
import 'package:rk_distributor/widgets/nothing_to_be_displayed.dart';

class CustomerManagementScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final TextStyleController textStyleController = Get.find();
  final CustomerService customerService = Get.find();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.account_circle, size: 25),
              SizedBox(width: 8),
              Text(
                'Customer Management',
                style: textStyleController.appBarTextStyle.value,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _searchFocusNode.unfocus();
            Get.to(AddCustomerScreen());
          },
          child: Icon(Icons.add),
        ),
        body: Column(
          children: [
            _buildSearchAndFilterBar(),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Wrap(
                    children: [
                      if (customerService.selectedArea.value.isNotEmpty)
                        Chip(
                          label: Text(
                            customerService.selectedArea.value,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          // backgroundColor: Colors.blue,
                          deleteIcon: Icon(Icons.clear),
                          onDeleted: () {
                            _searchController.clear();
                            customerService.clearFilter();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            customerService.customers.length == 0
                ? NothingToBeDisplayed()
                : Expanded(
                    child: ListView.builder(
                      itemCount: customerService.filteredCustomers.length,
                      itemBuilder: (context, index) {
                        Customer customer =
                            customerService.filteredCustomers[index];
                        return CustomCustomerListTile(
                          customer: customer,
                          trailing: Icon(Icons.arrow_forward),
                          onTap: () {
                            _searchFocusNode.unfocus();
                            Get.to(AboutCustomerScreen(customer: customer));
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: CustomSearchBar(
              searchController: _searchController,
              onChanged: (value) {
                if (customerService.selectedArea.value.isNotEmpty) {
                  customerService.clearFilter();
                }
                customerService.filterCustomers(value);
              },
              onClear: () {
                _searchController.clear();
                customerService.clearFilter();
              },
              hintText: 'Search by name or area',
              searchFocusNode: _searchFocusNode,
            ),
          ),
          SizedBox(width: 8.0), // Space between search bar and filter
          _buildFilterDropdown(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.filter_list),
      onSelected: (String? newValue) {
        if (newValue != null) {
          customerService.filterByArea(newValue);
        } else {
          customerService.clearFilter();
        }
      },
      itemBuilder: (BuildContext context) {
        return customerService.areaList.map((String value) {
          return PopupMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList();
      },
    );
  }
}
