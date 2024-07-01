import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rk_distributor/controllers/marketplace_controller.dart';
import 'package:rk_distributor/controllers/text_style_controller.dart';
import 'package:rk_distributor/models/product_model.dart';
import 'package:rk_distributor/services/marketplace_service.dart';
import 'package:rk_distributor/services/theme_service.dart';
import 'package:rk_distributor/widgets/custom_product_card.dart';
import 'package:rk_distributor/widgets/custom_search_bar.dart';

import '../../../api/barcode_img_link_provider.dart';

class MarketPlacePage extends StatelessWidget {
  final MarketplaceService marketPlaceService = Get.find();
  final ThemeService themeService = Get.find();
  final MarketplaceController marketplaceController = Get.find();
  final TextStyleController textStyleController = Get.find();

  // int? len = 0;
  //
  // void getCollectionLength() async {
  //   len = await marketPlaceService.getCollectionLength();
  // }

  @override
  Widget build(BuildContext context) {
    // getCollectionLength();
    bool _isScrollingDown = false;
    marketplaceController.scrollController.addListener(() {
      if (marketplaceController.scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // User is scrolling down
        if (!_isScrollingDown) {
          _isScrollingDown = true;
          marketplaceController.showCart(false);
        }
      } else {
        // User is scrolling up
        if (_isScrollingDown) {
          _isScrollingDown = false;
          marketplaceController.showCart(true);
        }
      }
      // Check if scroll position is at maximum extent
      if (marketplaceController.scrollController.position.pixels ==
          marketplaceController.scrollController.position.maxScrollExtent) {
        marketPlaceService.fetchMoreProducts();
      }
    });

    ever(marketPlaceService.priceSelection, (_) {
      marketplaceController.updateCartPrices();
    });

    ever(marketPlaceService.selectedArea, (_) {
      marketplaceController.updateCartPrices();
    });

    ever(marketPlaceService.selectedCustomer, (_) {
      marketplaceController.updateCartPrices();
    });
    return Obx(
      () => Scaffold(
        // floatingActionButton: marketplaceController.showFAB.value
        //     ? FloatingActionButton(
        //         onPressed: () {},
        //         child:
        //             Badge(label: Text("1"), child: Icon(Icons.shopping_cart)),
        //       )
        //     : SizedBox.shrink(),
        body: Column(
          children: [
            _buildSearchBarAndFilter(),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Wrap(
                    children: [
                      if (marketPlaceService.selectedCategory.value != 'All')
                        Chip(
                          label: Text(
                            marketPlaceService.selectedCategory.value,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          // backgroundColor: Colors.blue,
                          deleteIcon: Icon(Icons.clear),
                          onDeleted: () {
                            marketPlaceService.onCategoryChanged(null);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              color: Color.lerp(
                  themeService.isDarkMode.value ? Colors.black : Colors.white,
                  Theme.of(context).colorScheme.primary,
                  0.8),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Customer",
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
                    _buildCustomerSelection(context)
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "View Price By",
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
                    _buildPriceSelection(context)
                  ],
                ),
              ),
            ),
            Divider(
              color: Color.lerp(
                  themeService.isDarkMode.value ? Colors.black : Colors.white,
                  Theme.of(context).colorScheme.primary,
                  0.8),
            ),
            Expanded(child: _buildProductList()),
            marketPlaceService.isLoading.value
                ? LoadingAnimationWidget.staggeredDotsWave(
                    color: themeService.isDarkMode.value
                        ? Colors.white
                        : Colors.black,
                    size: MediaQuery.of(context).size.width * 0.15,
                  )
                : SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarAndFilter() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8, top: 5),
      child: Row(
        children: [
          Expanded(
            child: CustomSearchBar(
              searchController: marketPlaceService.searchController,
              onChanged: marketPlaceService.onSearchChanged,
              onClear: () {
                marketPlaceService.searchController.clear();
                marketPlaceService.onSearchChanged('');
              },
              searchFocusNode: FocusNode(),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          _buildFilterDropDown()
        ],
      ),
    );
  }

  Widget _buildFilterDropDown() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.filter_list),
      onSelected: (String? newValue) {
        if (newValue != null) {
          marketPlaceService.onCategoryChanged(newValue);
        }
      },
      itemBuilder: (BuildContext context) {
        return marketPlaceService.productService.categories.map((String value) {
          return PopupMenuItem<String>(
            value: value,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildCustomerSelection(BuildContext context) {
    return Obx(() {
      return DropdownButton<String>(
        underline: SizedBox.shrink(),
        value: marketPlaceService.selectedCustomer.value.isEmpty
            ? null
            : marketPlaceService.selectedCustomer.value,
        selectedItemBuilder: (BuildContext context) {
          return marketPlaceService.customerService.customers.map((customer) {
            return Container(
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width *
                  0.3, // Adjust the width as needed
              child: Text(
                customer.name,
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList();
        },
        items: marketPlaceService.customerService.customers.map((customer) {
          return DropdownMenuItem<String>(
            value: customer.id,
            child: Container(
              width: MediaQuery.of(context).size.width *
                  0.6, // Adjust the width as needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    customer.area,
                    style: TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            marketPlaceService.onCustomerChanged(value);
          }
        },
      );
    });
  }

  Widget _buildPriceSelection(BuildContext context) {
    return Obx(() {
      return marketPlaceService.selectedCustomer.value.isEmpty
          ? Container()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  underline: SizedBox.shrink(),
                  value: marketPlaceService.priceSelection.value,
                  items: ['Common', 'Area', 'Customer']
                      .map((option) => DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      marketPlaceService.onPriceSelectionChanged(value);
                    }
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                if (marketPlaceService.priceSelection.value == 'Area')
                  DropdownButton<String>(
                    underline: SizedBox.shrink(),
                    value: marketPlaceService.selectedArea.value.isEmpty
                        ? null
                        : marketPlaceService.selectedArea.value,
                    hint: Text('Select Area'),
                    items: marketPlaceService.customerService.areaList
                        .map((area) => DropdownMenuItem<String>(
                              value: area,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Text(
                                  area,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        marketPlaceService.onAreaChanged(value);
                      }
                    },
                  ),
              ],
            );
    });
  }
  Widget _buildProductCard(Product product, double ourPrice) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: SizedBox(
          child: CachedNetworkImage(
            imageUrl: BarcodeImgLinkProvider.barcodeImg(barcode: product.id),
            fit: BoxFit.cover,
            placeholder: (context, url) => LoadingAnimationWidget.fallingDot(
              color: Colors.black,
              size: 65,
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            product.name.capitalize.toString(),
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
            overflow: TextOverflow.clip,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.0),
            Text.rich(
              TextSpan(
                text: 'Unit: ',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w900,
                ),
                children: [
                  TextSpan(
                    text: '${product.unit}',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.clip,
            ),
            SizedBox(height: 4.0),
            Text.rich(
              TextSpan(
                text: 'Weight: ',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w900,
                ),
                children: [
                  TextSpan(
                    text:
                    '${product.weigh.weight.toStringAsFixed(1)} ${product.weigh.unit}',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.clip,
            ),
            SizedBox(height: 4.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text.rich(
                TextSpan(
                  text: 'MRP: ₹',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w900,
                    color: Colors.blue, // Highlight color for MRP
                  ),
                  children: [
                    TextSpan(
                      text:
                      '${product.mrp.toStringAsFixed(2)} / ${product.unit}',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                overflow: TextOverflow.clip,
              ),
            ),
            SizedBox(height: 4.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text.rich(
                TextSpan(
                  text: 'Our Price: ₹',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w900,
                    color: Colors.green, // Highlight color for Our Price
                  ),
                  children: [
                    TextSpan(
                      text: '${ourPrice.toStringAsFixed(2)} / ${product.unit}',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                overflow: TextOverflow.clip,
              ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 80.0,
          child: OutlinedButton(
            onPressed: () {},
            child: Text(
              'Add',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Obx(() {
      return ListView.builder(
        controller: marketplaceController.scrollController,
        itemCount: marketPlaceService.displayedProducts.length,
        itemBuilder: (context, index) {
          final product = marketPlaceService.displayedProducts[index];
          final ourPrice = _getOurPrice(marketPlaceService, product);

          return ProductCard(product: product, ourPrice: ourPrice);
        },
      );
    });
  }

  double _getOurPrice(MarketplaceService service, Product product) {
    if (service.priceSelection.value == 'Common') {
      return product.ourPrice.common;
    } else if (service.priceSelection.value == 'Area' &&
        service.selectedArea.value.isNotEmpty) {
      final areaPrice = product.ourPrice.area.firstWhere(
        (area) => area.name == service.selectedArea.value,
        orElse: () => AreaPrice(name: '', price: product.ourPrice.common),
      );
      return areaPrice.price;
    } else if (service.priceSelection.value == 'Customer' &&
        service.selectedCustomer.value.isNotEmpty) {
      final customerPrice = product.ourPrice.customerPrices.firstWhere(
        (cp) => cp.customerId == service.selectedCustomer.value,
        orElse: () => CustomerPrice(
            customerId: '', price: _getAreaOrCommonPrice(service, product)),
      );
      return customerPrice.price;
    }
    return product.ourPrice.common;
  }

  double _getAreaOrCommonPrice(MarketplaceService service, Product product) {
    final customer = service.customerService.customers.firstWhere(
        (customer) => customer.id == service.selectedCustomer.value);
    final areaPrice = product.ourPrice.area.firstWhere(
      (area) => area.name == customer.area,
      orElse: () => AreaPrice(name: '', price: product.ourPrice.common),
    );
    return areaPrice.price;
  }
}
