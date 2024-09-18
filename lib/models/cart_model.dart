import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../profiders/cart_profider.dart';
import '../profiders/product_class.dart';
import '../profiders/wish_provider.dart';

class CartModel extends StatelessWidget {
  CartModel(
      {super.key,
      required this.product,
      required this.cart,
      required this.index});

  final Product product;
  final Cart cart;
  final int index;

  late String productQuantity;

  @override
  Widget build(BuildContext context) {
    productQuantity = product.qty.toString();

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        child: SizedBox(
            height: 100,
            width: 120,
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10)),
                    child: Image.network(
                      product.imagesUrl.toString(),
                      width: 120,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cart.getItems[index].productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700),
                        ),
                        Row(
                          children: [
                            Text(product.price.toStringAsFixed(2),
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                            Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  product.qty == 0 || product.qty < 0
                                      ? IconButton(
                                          onPressed: () {
                                            CupertinoActionSheet(
                                              title: const Text("Remove Item"),
                                              message: const Text(
                                                  "Are You Sure Want to Remove This Item ?"),
                                              actions: <CupertinoActionSheetAction>[
                                                CupertinoActionSheetAction(
                                                    onPressed: () async {
                                                      context
                                                                  .read<Wish>()
                                                                  .getWishItems
                                                                  .firstWhereOrNull(
                                                                      (product) =>
                                                                          product
                                                                              .documentId ==
                                                                          product
                                                                              .documentId) !=
                                                              null
                                                          ? context
                                                              .read<Cart>()
                                                              .removeItem(
                                                                  product)
                                                          : await context
                                                              .read<Wish>()
                                                              .addWishItem(
                                                                  product
                                                                      .productName,
                                                                  product.price,
                                                                  1,
                                                                  product.qntty,
                                                                  product
                                                                      .imagesUrl,
                                                                  product
                                                                      .documentId,
                                                                  product
                                                                      .suppId);
                                                      context
                                                          .read<Cart>()
                                                          .removeItem(product);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      "Move To Wish List",
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.red),
                                                    )),
                                                CupertinoActionSheetAction(
                                                    onPressed: () {
                                                      context
                                                          .read<Cart>()
                                                          .removeItem(product);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                        "Delete Item"))
                                              ],
                                              cancelButton: TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Cancel"),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.delete_forever,
                                            size: 18,
                                          ),
                                        )
                                      : IconButton(
                                          disabledColor: Colors.black45,
                                          onPressed: () {
                                            cart.decrease(product);
                                          },
                                          icon: const Icon(
                                            FontAwesomeIcons.minus,
                                            size: 18,
                                          ),
                                        ),
                                  Text(
                                    product.qty.toString(),
                                    style: product.qty == product.qntty ||
                                            product.qty > product.qntty
                                        ? const TextStyle(
                                            fontSize: 20,
                                            color: Colors.red,
                                            fontFamily: 'Acme')
                                        : const TextStyle(
                                            fontSize: 20, fontFamily: 'Acme'),
                                  ),
                                  product.qty == product.qntty ||
                                          product.qty > product.qntty
                                      ? const IconButton(
                                          onPressed: null,
                                          icon: Icon(
                                            FontAwesomeIcons.plus,
                                            size: 18,
                                          ),
                                        )
                                      : IconButton(
                                          disabledColor: Colors.red,
                                          onPressed: () {
                                            cart.increment(product);
                                          },
                                          icon: const Icon(
                                            FontAwesomeIcons.plus,
                                            size: 18,
                                          ),
                                        ),
                                  product.qty > product.qntty ||
                                          product.qty == product.qntty
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  print(
                                                      "I Want TO Reset The Text to 0 WHen Click Icon Reset");
                                                },
                                                icon: Icon(
                                                  Icons.lock_reset,
                                                  color: Colors.black,
                                                ))
                                          ],
                                        )
                                      : const SizedBox()
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
