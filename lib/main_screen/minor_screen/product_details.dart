import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:multi_store_app_customer/main_screen/cart/cart_screen.dart';
import 'package:multi_store_app_customer/main_screen/minor_screen/visit_store.dart';
import 'package:multi_store_app_customer/profiders/cart_profider.dart';
import 'package:multi_store_app_customer/profiders/product_class.dart';
import 'package:multi_store_app_customer/widgets/alert_dialog.dart';
import 'package:multi_store_app_customer/widgets/appbar_widgets.dart';
import 'package:multi_store_app_customer/widgets/snackbar_widget.dart';
import 'package:multi_store_app_customer/widgets/yellow_button.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../profiders/wish_provider.dart';
import 'full_screen_view.dart';
import 'package:collection/collection.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.proList});

  final dynamic proList;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  late final Stream<QuerySnapshot> _productStream = FirebaseFirestore.instance
      .collection('products')
      .where('main_category', isEqualTo: widget.proList['main_category'])
      .where('sub_category', isEqualTo: widget.proList['sub_category'])
      .snapshots();

  late final Stream<QuerySnapshot> _reviewsStream = FirebaseFirestore.instance
      .collection('products')
      .doc(widget.proList['pid'])
      .collection('reviews')
      .snapshots();

  late List<dynamic> imageList = widget.proList['product_images'];

  @override
  Widget build(BuildContext context) {
    var existingItemsCart = context.read<Cart>().getItems.firstWhereOrNull(
        (product) => product.documentId == widget.proList['pid']);

    var onsale = widget.proList['in_stock'];

    return Material(
      child: SafeArea(
        child: ScaffoldMessenger(
          key: _scaffoldKey,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Theme.of(context).iconTheme.color,
              ),
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.share,
                        color: Theme.of(context).iconTheme.color)),
                IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.more_vert,
                        color: Theme.of(context).iconTheme.color))
              ],
            ),
            body: ProductDetailsBodey(
              widget: widget,
              productStream: _productStream,
              onsale: onsale,
              reviewsStream: _reviewsStream,
              imageList: imageList,
            ),
            bottomSheet: BottomSheet(
              widget: widget,
              scaffoldKey: _scaffoldKey,
              existingItemsCart: existingItemsCart,
              onsale: onsale,
              imageList: imageList,
            ),
          ),
        ),
      ),
    );
  }
}

class ProductDetailsBodey extends StatelessWidget {
  ProductDetailsBodey(
      {super.key,
      required this.widget,
      required Stream<QuerySnapshot<Object?>> productStream,
      required this.onsale,
      required this.reviewsStream,
      required this.imageList})
      : _productStream = productStream;

  final ProductDetailsScreen widget;

  final Stream<QuerySnapshot<Object?>> _productStream;
  final int onsale;
  var reviewsStream;
  final List<dynamic> imageList;

  @override
  Widget build(BuildContext context) {
    var existingItemsWishList = context
        .read<Wish>()
        .getWishItems
        .firstWhereOrNull(
            (product) => product.documentId == widget.proList['pid']);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FullScreenView(
                              imageList: imageList,
                            )));
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: Swiper(
                  pagination:
                      const SwiperPagination(builder: SwiperPagination.dots),
                  itemCount: widget.proList['product_images'].length,
                  itemBuilder: (context, index) {
                    return Image(
                      width: double.infinity,
                      height: double.infinity,
                      image:
                          NetworkImage(widget.proList['product_images'][index]),
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                widget.proList['product_name'],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Text(
                            'USD',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            widget.proList['price'].toStringAsFixed(2),
                            style: widget.proList['discount'] != 0
                                ? Theme.of(context).textTheme.bodyMedium
                                : Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          widget.proList['discount'] != 0
                              ? Text(
                                  ((1 - (widget.proList['discount'] / 100)) *
                                          widget.proList['price'])
                                      .toStringAsFixed(2),
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                )
                              : const Text(''),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        if (FirebaseAuth.instance.currentUser!.isAnonymous) {
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
                          existingItemsWishList != null
                              ? context
                                  .read<Wish>()
                                  .removeThis(widget.proList['pid'])
                              : context.read<Wish>().addWishItem(
                                  widget.proList['product_name'],
                                  onsale != 0
                                      ? ((1 -
                                              (widget.proList['discount'] /
                                                  100)) *
                                          widget.proList['price'])
                                      : widget.proList['price'],
                                  1,
                                  widget.proList['in_stock'],
                                  widget.proList['product_images'][0],
                                  widget.proList['pid'],
                                  widget.proList['sid']);
                        }
                      },
                      icon: context.watch<Wish>().getWishItems.firstWhereOrNull(
                                  (product) =>
                                      product.documentId ==
                                      widget.proList['pid']) !=
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
              ),
            ),
            widget.proList['in_stock'] == 0
                ? Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'This item is Out of Stock',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '${widget.proList['in_stock']} pieces available in stock',
                      style: Theme.of(context).textTheme.displaySmall,
                    )),
            const ProductDetailsHeader(
              label: "Item Description",
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                widget.proList['product_description'],
                textScaler: const TextScaler.linear(1.1),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Stack(
              children: [
                const Positioned(right: 50, top: 15, child: Text('Total')),
                ExpandableTheme(
                    data: const ExpandableThemeData(
                      iconColor: Colors.blue,
                      iconSize: 24,
                    ),
                    child: reviews(reviewsStream, context)),
              ],
            ),
            const ProductDetailsHeader(label: 'Similar Items'),
            SizedBox(
                child: StreamBuilder(
              stream: _productStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text("There Some Thing Wrong");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "This Category Has No Items Here",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      // style: TextStyle(
                      //     fontSize: 26,
                      //     color: Colors.blueGrey,
                      //     fontWeight: FontWeight.bold,
                      //     fontFamily: 'Acme',
                      //     letterSpacing: 1.5),
                      style:
                          Theme.of(context).textTheme.displayMedium!.copyWith(
                                letterSpacing: 1.5,
                              ),
                    ),
                  );
                }
                return MasonryGridView.count(
                  padding: const EdgeInsets.all(10),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  itemBuilder: (context, index) {
                    var productData = snapshot.data!.docs[index];
                    return ProductModel(
                      productData: productData,
                      products: productData,
                    );
                  },
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}

class BottomSheet extends StatelessWidget {
  const BottomSheet({
    super.key,
    required this.widget,
    required GlobalKey<ScaffoldMessengerState> scaffoldKey,
    required this.existingItemsCart,
    required this.onsale,
    required this.imageList,
  }) : _scaffoldKey = scaffoldKey;

  final ProductDetailsScreen widget;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey;
  final Product? existingItemsCart;
  final int onsale;
  final List<dynamic> imageList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                VisitStore(suppId: widget.proList['sid'])));
                  },
                  icon: const Icon(
                    Icons.store,
                    color: Colors.black,
                  )),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(
                              back: AppBarBackButton(
                            color: Colors.black,
                          )),
                        ));
                  },
                  icon: Badge(
                    isLabelVisible:
                        context.read<Cart>().getItems.isEmpty ? false : true,
                    padding: const EdgeInsets.all(2),
                    label: Text(
                      context.watch<Cart>().getItems.length.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    backgroundColor: Colors.yellow,
                    child: const Icon(
                      Icons.shopping_cart,
                      color: Colors.black,
                    ),
                  )),
            ],
          ),
          CustomButton(
            widthPercentage: 0.5,
            label: existingItemsCart != null ? 'added to cart' : 'ADD TO CART',
            onPressed: () {
              if (FirebaseAuth.instance.currentUser == null) {
                MyAlertDialog.showMyDialog(
                    context: context,
                    title: 'Please Login',
                    content: "Please Login If You Want Buy This Product",
                    tabYes: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                          context, "/customer_login");
                    },
                    tabNo: () {
                      Navigator.pop(context);
                    });
              } else {
                if (widget.proList['in_stock'] == 0) {
                  MyMessageHandler.showSnackBar(
                      _scaffoldKey, "This Product is Out of Stock");
                } else {
                  existingItemsCart != null
                      ? MyMessageHandler.showSnackBar(
                          _scaffoldKey, "This Item ALready in Your Cart")
                      : context.read<Cart>().addItem(
                          widget.proList['product_name'],
                          onsale != 0
                              ? ((1 - widget.proList['discount'] / 100) *
                                  widget.proList['price'])
                              : widget.proList['price'],
                          1,
                          widget.proList['in_stock'],
                          imageList.first,
                          widget.proList['pid'],
                          widget.proList['sid']);
                }
              }
            },
            color: Theme.of(context).colorScheme.secondary,
          )
        ],
      ),
    );
  }
}

class ProductDetailsHeader extends StatelessWidget {
  final String label;

  const ProductDetailsHeader({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 40,
          width: 50,
          child: Divider(
            color: Colors.teal.shade900,
            thickness: 1,
          ),
        ),
        Text(
          '  $label  ',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(
          height: 40,
          width: 50,
          child: Divider(
            color: Theme.of(context).colorScheme.secondary,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

Widget reviews(var reviewsStream, BuildContext context) {
  return ExpandablePanel(
      header: Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          'Reviews',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      collapsed: SizedBox(
        height: 230,
        child: reviewsAll(reviewsStream),
      ),
      expanded: reviewsAll(reviewsStream));
}

Widget reviewsAll(var reviewsStream) {
  return StreamBuilder<QuerySnapshot>(
    stream: reviewsStream,
    builder: (context, snapshot2) {
      if (snapshot2.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (snapshot2.data!.docs.isEmpty) {
        return Center(
          child: Text(
            "This Product Doesnt Has Preview yet",
            softWrap: true,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(letterSpacing: 1.5),
          ),
        );
      }

      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: snapshot2.data!.docs.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  NetworkImage(snapshot2.data!.docs[index]['profile_image']),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(snapshot2.data!.docs[index]['name']),
                Row(
                  children: [
                    Text(snapshot2.data!.docs[index]['rate'].toString()),
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                    )
                  ],
                )
              ],
            ),
            subtitle: Text(snapshot2.data!.docs[index]['comment']),
          );
        },
      );
    },
  );
}
