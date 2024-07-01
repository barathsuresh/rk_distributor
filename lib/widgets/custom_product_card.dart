import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rk_distributor/controllers/marketplace_controller.dart';
import 'package:rk_distributor/services/marketplace_service.dart';
import 'package:rk_distributor/services/theme_service.dart';
import 'package:rk_distributor/utils/show_snackbar.dart';

import '../api/barcode_img_link_provider.dart';
import '../models/product_model.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final double ourPrice;

  const ProductCard({required this.product, required this.ourPrice});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  TextEditingController? _controller;
  MarketplaceController marketplaceController = Get.find();
  ThemeService themeService = Get.find();
  MarketplaceService marketplaceService = Get.find();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final containerQtyColor =
      themeService.isDarkMode.value ? Colors.grey[800] : Colors.grey[300];
      final orderItem = marketplaceController.orderItems
          .firstWhereOrNull((item) => item.prodId == widget.product.id);

      if (orderItem != null) {
        _controller?.text = orderItem.qty.toString();
      }

      return Column(
        children: [
          Card(
            elevation: 4.0,
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: SizedBox(
                    child: CachedNetworkImage(
                      imageUrl: BarcodeImgLinkProvider.barcodeImg(
                          barcode: widget.product.id),
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          LoadingAnimationWidget.fallingDot(
                            color: Colors.black,
                            size: 65,
                          ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  title: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      widget.product.name.capitalize.toString(),
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
                              text: '${widget.product.unit}',
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
                              '${widget.product.weigh.weight.toStringAsFixed(1)} ${widget.product.weigh.unit}',
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
                                '${widget.product.mrp.toStringAsFixed(2)} / ${widget.product.unit}',
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
                              color:
                              Colors.green, // Highlight color for Our Price
                            ),
                            children: [
                              TextSpan(
                                text:
                                '${widget.ourPrice.toStringAsFixed(2)} / ${widget.product.unit}',
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
                  trailing: orderItem == null
                      ? SizedBox(
                    width: 80.0,
                    child: OutlinedButton(
                      onPressed: () {
                        if(marketplaceService.selectedCustomer.isNotEmpty) {
                          marketplaceController.addProductToOrder(
                            widget.product, widget.ourPrice);
                        }else{
                          ShowSnackBar.showSnackBar(title: "Add to Cart Error", msg: "Please Select the Customer first before adding to cart");
                        }
                      },
                      child: Text('Add'),
                    ),
                  )
                      : SizedBox.shrink(),
                ),
                if (orderItem != null)
                  Row(
                    children: [
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: containerQtyColor),
                        margin: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                marketplaceController.updateProductQuantity(
                                    orderItem, orderItem.qty - 1);
                              },
                              icon: Icon(
                                Icons.remove,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                  EdgeInsets.symmetric(horizontal: 8),
                                ),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  final qty = int.tryParse(val);
                                  if (qty != null) {
                                    marketplaceController.updateProductQuantity(
                                        orderItem, qty!);
                                  }
                                },
                                onSubmitted: (val) {
                                  final qty = int.tryParse(val) ?? 1;
                                  marketplaceController.updateProductQuantity(
                                      orderItem, qty!);
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                marketplaceController.updateProductQuantity(
                                    orderItem, orderItem.qty + 1);
                              },
                              icon: Icon(
                                Icons.add,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
