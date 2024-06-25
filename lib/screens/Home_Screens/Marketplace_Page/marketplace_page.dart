import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rk_distributor/controllers/marketplace_controller.dart';
import 'package:rk_distributor/models/product_model.dart';
import 'package:rk_distributor/services/marketplace_service.dart';
import 'package:rk_distributor/services/theme_service.dart';
import 'package:rk_distributor/widgets/custom_search_bar.dart';

import '../../../api/barcode_img_link_provider.dart';

class MarketPlacePage extends StatelessWidget {
  final MarketplaceService marketPlaceService = Get.find();
  final ThemeService themeService = Get.find();
  final MarketplaceController marketplaceController = Get.find();
  int? len = 0;
  void getCollectionLength()async{
    len = await marketPlaceService.getCollectionLength();
  }

  @override
  Widget build(BuildContext context) {
    getCollectionLength();
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
    return Obx(
      () => Scaffold(
        floatingActionButton: marketplaceController.showFAB.value
            ? FloatingActionButton(
                onPressed: () {},
                child:
                    Badge(label: Text("1"), child: Icon(Icons.shopping_cart)),
              )
            : SizedBox.shrink(),
        body: Column(
          children: [
            Text("${marketPlaceService.displayedProducts.length.toString()} firebase $len"),
            _buildSearchBar(),
            _buildFilterOptions(context),
            _buildCustomerSelection(context),
            _buildPriceSelection(context),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomSearchBar(
        searchController: marketPlaceService.searchController,
        onChanged: marketPlaceService.onSearchChanged,
        onClear: () {
          marketPlaceService.searchController.clear();
          marketPlaceService.onSearchChanged('');
        },
        searchFocusNode: FocusNode(),
      ),
    );
  }

  Widget _buildFilterOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Filter by Category:'),
          Obx(() {
            return DropdownButton<String>(
              value: marketPlaceService.selectedCategory.value,
              items: ['All', ...marketPlaceService.productService.categories]
                  .map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (String? value) {
                if (value != null) {
                  marketPlaceService.onCategoryChanged(value);
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomerSelection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Select Customer:'),
          Obx(() {
            return DropdownButton<String>(
              value: marketPlaceService.selectedCustomer.value.isEmpty
                  ? null
                  : marketPlaceService.selectedCustomer.value,
              hint: Text('Select Customer'),
              items:
                  marketPlaceService.customerService.customers.map((customer) {
                return DropdownMenuItem<String>(
                  value: customer.id,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Text(customer.name),
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  marketPlaceService.onCustomerChanged(value);
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriceSelection(BuildContext context) {
    return Obx(() {
      return marketPlaceService.selectedCustomer.value.isEmpty
          ? Container()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('View Price By:'),
                DropdownButton<String>(
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
                if (marketPlaceService.priceSelection.value == 'Area')
                  DropdownButton<String>(
                    value: marketPlaceService.selectedArea.value.isEmpty
                        ? null
                        : marketPlaceService.selectedArea.value,
                    hint: Text('Select Area'),
                    items: marketPlaceService.customerService.areaList
                        .map((area) => DropdownMenuItem<String>(
                              value: area,
                              child: Text(area),
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

  Widget _buildProductList() {
    return Obx(() {
      return ListView.builder(
        controller: marketplaceController.scrollController,
        itemCount: marketPlaceService.displayedProducts.length,
        itemBuilder: (context, index) {
          final product = marketPlaceService.displayedProducts[index];
          final ourPrice = _getOurPrice(marketPlaceService, product);

          return _buildProductCard(product, ourPrice);
        },
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
