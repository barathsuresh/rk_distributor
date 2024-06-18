import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rk_distributor/api/barcode_img_link_provider.dart';
import 'package:rk_distributor/services/theme_service.dart';
import 'package:rk_distributor/widgets/custom_search_bar.dart';

import '../../../services/marketplace_service.dart';
import '../../../models/product_model.dart';

class MarketplacePage extends StatelessWidget {
  MarketplacePage({super.key});

  final ThemeService themeService = Get.find();
  final MarketplaceService marketPlaceService = Get.find();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    bool _isScrollingDown = false;
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // User is scrolling down
        if (!_isScrollingDown) {
          _isScrollingDown = true;
        }
      } else {
        // User is scrolling up
        if (_isScrollingDown) {
          _isScrollingDown = false;
        }
      }
      // Check if scroll position is at maximum extent
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
      }
    });

    return Scaffold(
      floatingActionButton: true
          ? FloatingActionButton(
        onPressed: () {},
        child: Badge(label: Text("1"), child: Icon(Icons.shopping_cart)),
      )
          : SizedBox.shrink(),
      body: Column(
        children: [
          _buildSearchBar(marketPlaceService),
          _buildFilterOptions(marketPlaceService, context),
          _buildCustomerSelection(marketPlaceService, context),
          _buildPriceSelection(marketPlaceService, context),
          Expanded(child: _buildProductList(marketPlaceService)),
          Obx(() {
            return marketPlaceService.isLoading.value
                ? LoadingAnimationWidget.staggeredDotsWave(
              color: themeService.isDarkMode.value
                  ? Colors.white
                  : Colors.black,
              size: MediaQuery.of(context).size.width * 0.15,
            )
                : SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar(MarketplaceService service) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomSearchBar(
        searchController: service.searchController,
        searchFocusNode: _focusNode,
        onChanged: service.onSearchChanged,
        onClear: () {
          service.searchController.clear();
          service.onSearchChanged('');
        },
      ),
    );
  }

  Widget _buildFilterOptions(MarketplaceService service, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Filter by Category:'),
          Obx(() {
            return DropdownButton<String>(
              menuMaxHeight: MediaQuery.of(context).size.height * 0.45,
              value: service.selectedCategory.value,
              items: ['All', ...service.productService.categories]
                  .map((category) => DropdownMenuItem<String>(
                value: category,
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ))
                  .toList(),
              onChanged: (String? value) {
                if (value != null) {
                  service.onCategoryChanged(value);
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomerSelection(
      MarketplaceService service, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Select Customer:'),
          Obx(() {
            return DropdownButton<String>(
              menuMaxHeight: MediaQuery.of(context).size.height * 0.45,
              value: service.selectedCustomer.value.isEmpty
                  ? null
                  : service.selectedCustomer.value,
              hint: Text('Select Customer'),
              items: service.customerService.customers.map((customer) {
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
                  service.onCustomerChanged(value);
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriceSelection(
      MarketplaceService service, BuildContext context) {
    return Obx(() {
      return service.selectedCustomer.value.isEmpty
          ? Container()
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('View Price By:'),
          DropdownButton<String>(
            value: service.priceSelection.value,
            items: ['Common', 'Area', 'Customer']
                .map((option) => DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            ))
                .toList(),
            onChanged: (String? value) {
              if (value != null) {
                service.onPriceSelectionChanged(value);
                service
                    .filterProducts(); // Ensure filtering is updated on price selection change
              }
            },
          ),
          service.priceSelection.value == 'Area'
              ? DropdownButton<String>(
            menuMaxHeight:
            MediaQuery.of(context).size.height * 0.45,
            value: service.selectedArea.value.isEmpty
                ? null
                : service.selectedArea.value,
            hint: Text('Select Area'),
            items: service.customerService.areaList.map((area) {
              return DropdownMenuItem<String>(
                value: area,
                child: Text(area),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                service.onAreaChanged(value);
                service
                    .filterProducts(); // Ensure filtering is updated on area change
              }
            },
          )
              : Container(),
        ],
      );
    });
  }

  Widget _buildProductList(MarketplaceService service) {
    return Obx(() {
      return ListView.builder(
        controller: ScrollController()..addListener(() {
          if (service.isLoading.value) return;
          if ((service.displayedProducts.length) <
              service.allProducts.length) {
            service.fetchMoreProducts();
          }
        }),
        itemCount: service.displayedProducts.length,
        itemBuilder: (context, index) {
          final product = service.displayedProducts[index];
          final ourPrice = _getOurPrice(service, product);

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
                      text: '${product.mrp.toStringAsFixed(2)} / ${product.unit}',
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