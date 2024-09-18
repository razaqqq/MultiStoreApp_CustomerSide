import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../profiders/cart_profider.dart';
import '../profiders/product_class.dart';
import '../profiders/wish_provider.dart';
import '../widgets/alert_dialog.dart';

class WishModel extends StatefulWidget {
  const WishModel(
      {super.key,
      required this.product,
      required this.wish,
      required this.index});

  final Product product;
  final Wish wish;
  final int index;

  @override
  State<WishModel> createState() => _WishModelState();
}

class _WishModelState extends State<WishModel> {
  @override
  Widget build(BuildContext context) {
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
                      widget.product.imagesUrl.toString(),
                      width: 120,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 3.0, horizontal: 6.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.wish.getWishItems[widget.index].productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.product.price.toStringAsFixed(2),
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      MyAlertDialog.showMyDialog(
                                          context: context,
                                          title: "Delete WishList",
                                          content:
                                              "Are You Sure Want to Delete This WishList",
                                          tabYes: () {
                                            context
                                                .read<Wish>()
                                                .removeItem(widget.product);
                                            Navigator.pop(context);
                                          },
                                          tabNo: () {
                                            Navigator.pop(context);
                                          });
                                    },
                                    icon: const Icon(Icons.delete_forever)),
                                context.watch<Cart>().getItems.firstWhereOrNull(
                                                (element) =>
                                                    element.documentId ==
                                                    widget
                                                        .product.documentId) !=
                                            null ||
                                        widget.product.qntty == 0
                                    ? const SizedBox()
                                    : IconButton(
                                        onPressed: () {
                                          context.read<Cart>().addItem(
                                              widget.product.productName,
                                              widget.product.price,
                                              1,
                                              widget.product.qntty,
                                              widget.product.imagesUrl,
                                              widget.product.documentId,
                                              widget.product.suppId);
                                        },
                                        icon:
                                            const Icon(Icons.add_shopping_cart))
                              ],
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
