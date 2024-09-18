import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/profiders/cart_profider.dart';
import 'package:multi_store_app_customer/profiders/id_provider.dart';
import 'package:multi_store_app_customer/widgets/alert_dialog.dart';
import 'package:multi_store_app_customer/widgets/appbar_widgets.dart';
import 'package:multi_store_app_customer/widgets/snackbar_widget.dart';
import 'package:provider/provider.dart';

import '../../models/cart_model.dart';
import '../../widgets/yellow_button.dart';
import '../minor_screen/place_oreder_screen.dart';

class CartScreen extends StatefulWidget {
  final Widget? back;

  const CartScreen({Key? key, this.back}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late double total_price = context.watch<Cart>().totalPrice;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  late String docId;

  @override
  void initState() {
    docId = context.read<IdProvider>().getData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: ScaffoldMessenger(
          key: _scaffoldKey,
          child: Scaffold(
            backgroundColor:
                Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            appBar: AppBar(
                elevation: 0,
                leading: widget.back,
                backgroundColor: Theme.of(context).colorScheme.primary,
                title: const AppBarTitle(
                  title: 'Cart',
                ),
                actions: [
                  context.watch<Cart>().getItems.isEmpty
                      ? const SizedBox()
                      : IconButton(
                          onPressed: () {
                            MyAlertDialog.showMyDialog(
                                context: context,
                                title: 'Clear Product',
                                content: 'Do You Want to Empty Your Cart? ',
                                tabYes: () {
                                  context.read<Cart>().clearCart();
                                  Navigator.pop(context);
                                },
                                tabNo: () {
                                  Navigator.pop(context);
                                });
                          },
                          icon: Icon(Icons.delete_forever,
                              color: Theme.of(context).iconTheme.color))
                ]),
            body: context.watch<Cart>().getItems.isNotEmpty
                ? const CartItems()
                : const EmptyCart(),
            bottomSheet: BottomSheetCart(
              total_price: total_price,
              scaffolKey: _scaffoldKey,
              docId: docId,
              context: context,
            ),
          ),
        ),
      ),
    );
  }
}

class CartItems extends StatelessWidget {
  const CartItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, cart, child) {
        return ListView.builder(
          itemCount: cart.Count,
          itemBuilder: (context, index) {
            final product = cart.getItems[index];
            return CartModel(
                product: product, cart: context.read<Cart>(), index: index);
          },
        );
      },
    );
  }
}

void logInDialog(BuildContext context) {
  showCupertinoDialog<void>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('Please Login'),
        content: const Text('You Should Be Logged in To Take Action'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/customer_login');
            },
          ),
          CupertinoDialogAction(
            child: const Text('Log In'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}

class BottomSheetCart extends StatelessWidget {
  const BottomSheetCart(
      {super.key,
      required this.total_price,
      required this.scaffolKey,
      required this.docId,
      required this.context});

  final double total_price;
  final GlobalKey<ScaffoldMessengerState> scaffolKey;
  final String docId;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(
          children: [
            const Text(
              "Total: \$  ",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              total_price.toStringAsFixed(2),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        CustomButton(
            onPressed: total_price == 0.0
                ? () {
                    MyMessageHandler.showSnackBar(scaffolKey,
                        "Please Make an Order Before You Check Out");
                  }
                : docId == ''
                    ? () {
                        logInDialog(context);
                      }
                    : () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlaceOrderScreen(),
                            ));
                      },
            widthPercentage: 0.45,
            label: "CHECK OUT",
            color: Theme.of(context).colorScheme.secondary)
      ]),
    );
  }
}

class EmptyCart extends StatelessWidget {
  const EmptyCart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Your Cart is Empty !",
            softWrap: true,
            style: TextStyle(fontSize: 30),
          ),
          const SizedBox(
            height: 50,
          ),
          Material(
            color: Colors.lightBlueAccent,
            borderRadius: BorderRadius.circular(25),
            child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width * 0.6,
              onPressed: () {
                Navigator.canPop(context)
                    ? Navigator.pop(context)
                    : Navigator.pushReplacementNamed(context, "/customer_home");
              },
              child: const Text("Continue Shopping",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
