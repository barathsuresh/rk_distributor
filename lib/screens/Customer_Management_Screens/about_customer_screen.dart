import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rk_distributor/models/customer_model.dart';
import 'package:rk_distributor/controllers/customer_controller.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/widgets/custom_dialog_box.dart';

import '../../services/marketplace_service.dart';

class AboutCustomerScreen extends StatelessWidget {
  AboutCustomerScreen({required this.customer});

  final Customer customer;
  final TextStyleController textStyleController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MarketplaceService marketplaceService = Get.find();

  @override
  Widget build(BuildContext context) {
    final CustomerController customerController =
        Get.put(CustomerController(customer));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => CustomDialogBox(
                          title: "Confirm Delete",
                          content:
                              "All Data Related to this will be deleted forever this is irreversible !!!",
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.roboto(),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                marketplaceService.reset();
                                customerController.deleteCustomer(customer);
                                Get.back();
                                Get.back();
                              },
                              child: Text(
                                "Delete",
                                style: GoogleFonts.roboto(color: Colors.red),
                              ),
                            )
                          ],
                        ));
              },
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ))
        ],
        title: Text(
          'About Customer',
          style: textStyleController.appBarTextStyle.value,
        ),
      ),
      floatingActionButton: Obx(() {
        return customerController.isEditing.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.extended(
                    label: Row(
                      children: [
                        Icon(CommunityMaterialIcons.cancel),
                        SizedBox(width: 5),
                        Text(
                          "Cancel",
                          style: textStyleController
                              .floatingActionButtonStyle.value,
                        )
                      ],
                    ),
                    onPressed: customerController.toggleEdit,
                    backgroundColor: Colors.red,
                  ),
                  SizedBox(width: 10),
                  FloatingActionButton.extended(
                    label: Row(
                      children: [
                        Icon(CommunityMaterialIcons.content_save),
                        SizedBox(width: 5),
                        Text(
                          "Save",
                          style: textStyleController
                              .floatingActionButtonStyle.value,
                        )
                      ],
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        customerController.updateCustomer();
                        customerController.toggleEdit();
                        Get.back();
                      }
                    },
                  ),
                ],
              )
            : FloatingActionButton(
                onPressed: customerController.toggleEdit,
                child: Icon(CommunityMaterialIcons.pencil),
              );
      }),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return customerController.isEditing.value
              ? Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      CircleAvatar(
                        child: Icon(
                          Icons.edit,
                          size: 55,
                        ),
                        radius: 64,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        controller: customerController.nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        controller: customerController.descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        keyboardType: TextInputType.streetAddress,
                        controller: customerController.areaController,
                        decoration: InputDecoration(
                          labelText: 'Area',
                          border: OutlineInputBorder(),
                          suffixIcon: PopupMenuButton<String>(
                            icon: Icon(Icons.arrow_drop_down),
                            itemBuilder: (BuildContext context) {
                              return customerController.customerService.areaList
                                  .map((String value) {
                                return PopupMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList();
                            },
                            onSelected: (value) {
                              customerController.areaController.text = value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    CircleAvatar(
                      child: Text(
                        "${customer.name[0].toUpperCase()}${customer.name[1].isNotEmpty ? customer.name[1].toUpperCase() : ""}",
                        style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold, fontSize: 55),
                      ),
                      radius: 64,
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Name',
                          style:
                              textStyleController.listTileTextTileStyle.value),
                      subtitle: Text(
                        customerController.nameController.text,
                        style:
                            textStyleController.listTileTextSubtitleStyle.value,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Description',
                          style:
                              textStyleController.listTileTextTileStyle.value),
                      subtitle: customerController
                              .descriptionController.text.isNotEmpty
                          ? Text(
                              customerController.descriptionController.text,
                              style: textStyleController
                                  .listTileTextSubtitleStyle.value,
                            )
                          : Text(
                              'No Description Provided',
                              style: textStyleController
                                  .italicListSubtitleStyle.value,
                            ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Area',
                          style:
                              textStyleController.listTileTextTileStyle.value),
                      subtitle: Text(
                        customerController.areaController.text,
                        style:
                            textStyleController.listTileTextSubtitleStyle.value,
                      ),
                    ),
                  ],
                );
        }),
      ),
    );
  }
}
