import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/profiders/wish_provider.dart';
import 'package:multi_store_app_customer/widgets/alert_dialog.dart';
import 'package:multi_store_app_customer/widgets/appbar_widgets.dart';
import 'package:provider/provider.dart';

import '../models/wish_model.dart';

class WishListScreen extends StatefulWidget {
  final Widget? back;

  const WishListScreen({Key? key, this.back}) : super(key: key);

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade200,
          appBar: AppBar(
              elevation: 0,
              leading: widget.back,
              backgroundColor: Colors.white,
              title: const AppBarTitle(
                title: 'WishList',
              ),
              actions: [
                context.watch<Wish>().getWishItems.isEmpty
                    ? const SizedBox()
                    : IconButton(
                        onPressed: () {
                          MyAlertDialog.showMyDialog(
                              context: context,
                              title: 'Clear Product',
                              content: 'Do You Want to Empty Your WishListt? ',
                              tabYes: () {
                                context.read<Wish>().clearWishList();
                                Navigator.pop(context);
                              },
                              tabNo: () {
                                Navigator.pop(context);
                              });
                        },
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.black))
              ]),
          body: context.watch<Wish>().getWishItems.isNotEmpty
              ? const WishListItems()
              : const EmptyWishs(),
        ),
      ),
    );
  }
}

class WishListItems extends StatelessWidget {
  const WishListItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Wish>(
      builder: (context, wish, child) {
        return ListView.builder(
          itemCount: wish.Count,
          itemBuilder: (context, index) {
            final product = wish.getWishItems[index];
            return WishModel(product: product, wish: wish, index: index);
          },
        );
      },
    );
  }
}

class EmptyWishs extends StatelessWidget {
  const EmptyWishs({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Your WishList is Empty !",
            softWrap: true,
            style: TextStyle(fontSize: 30),
          ),
        ],
      ),
    );
  }
}
