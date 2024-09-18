import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main_screen/minor_screen/product_details.dart';
import '../profiders/wish_provider.dart';
import '../widgets/alert_dialog.dart';

class ProductModel extends StatefulWidget {
  final dynamic products;

  const ProductModel(
      {super.key, required this.productData, required this.products});

  final QueryDocumentSnapshot<Object?> productData;

  @override
  State<ProductModel> createState() => _ProductModelState();
}

class _ProductModelState extends State<ProductModel> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailsScreen(proList: widget.productData),
            ));
      },
      child: ProductBody(widget: widget),
    );
  }
}

class ProductBody extends StatelessWidget {
  const ProductBody({super.key, required this.widget});

  final ProductModel widget;

  @override
  Widget build(BuildContext context) {
    var onSale = widget.products['discount'];
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  child: Container(
                    width: double.infinity,
                    constraints:
                        const BoxConstraints(minHeight: 100, maxHeight: 250),
                    child: Image(
                        image: NetworkImage(
                            widget.productData['product_images'][0]),
                        fit: BoxFit.cover),
                  )),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    Text(
                      widget.products['product_name'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '\$',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              widget.products['price'].toStringAsFixed(2),
                              style: widget.products['discount'] != 0
                                  ? const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                      decoration: TextDecoration.lineThrough,
                                      fontWeight: FontWeight.w600)
                                  : const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            widget.products['discount'] != 0
                                ? Text(
                                    ((1 - (widget.products['discount'] / 100)) *
                                            widget.products['price'])
                                        .toStringAsFixed(2),
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  )
                                : const Text(''),
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              if (FirebaseAuth
                                  .instance.currentUser!.isAnonymous) {
                                MyAlertDialog.showMyDialog(
                                    context: context,
                                    title: 'Please Login',
                                    content:
                                        "If You Want To Like This Product and Add This Product to WishList (Please Login), You Are Using Guest Account for Now ?",
                                    tabYes: () {
                                      Navigator.pop(context);
                                      FirebaseAuth.instance.signOut();
                                      Navigator.pushReplacementNamed(
                                          context, '/welcome_screen');
                                    },
                                    tabNo: () {
                                      Navigator.pop(context);
                                    });
                              } else {
                                var existingItemsWishList = context
                                    .read<Wish>()
                                    .getWishItems
                                    .firstWhereOrNull((product) =>
                                        product.documentId ==
                                        widget.products['pid']);
                                existingItemsWishList != null
                                    ? context
                                        .read<Wish>()
                                        .removeThis(widget.products['pid'])
                                    : context.read<Wish>().addWishItem(
                                        widget.products['product_name'],
                                        onSale != 0
                                            ? ((1 -
                                                    (widget.products[
                                                            'discount'] /
                                                        100)) *
                                                widget.products['price'])
                                            : widget.products['price'],
                                        1,
                                        widget.products['in_stock'],
                                        widget.products['product_images'][0],
                                        widget.products['pid'],
                                        widget.products['sid']);
                              }
                            },
                            icon: context
                                        .watch<Wish>()
                                        .getWishItems
                                        .firstWhereOrNull((product) =>
                                            product.documentId ==
                                            widget.products['pid']) !=
                                    null
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 30,
                                  )
                                : const Icon(
                                    Icons.favorite_border_outlined,
                                    color: Colors.red,
                                    size: 30,
                                  ))
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        onSale != 0
            ? Positioned(
                left: 0,
                top: 0,
                child: Container(
                  height: 25,
                  width: 80,
                  decoration: const BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                          topLeft: Radius.circular(15))),
                  child: Center(
                    child: Text(
                      'Save ${onSale.toString()}%',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            : const SizedBox()
      ],
    );
  }
}
