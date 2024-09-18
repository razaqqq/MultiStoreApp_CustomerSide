import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_store_app_customer/profiders/id_provider.dart';
import 'package:multi_store_app_customer/profiders/stripe_id.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:uuid/uuid.dart';

import '../../profiders/cart_profider.dart';
import '../../widgets/appbar_widgets.dart';
import '../../widgets/yellow_button.dart';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  const PaymentScreen(
      {super.key,
      required this.name,
      required this.phone,
      required this.address});

  final String name;
  final String phone;
  final String address;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedValue = 1;
  late String orderId;
  CollectionReference customers =
      FirebaseFirestore.instance.collection('customers');

  CollectionReference anonymous =
      FirebaseFirestore.instance.collection('anonymous');

  void showProgress() {
    ProgressDialog progress = ProgressDialog(context: context);
    progress.show(max: 100, msg: "Please Wait", progressBgColor: Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    String docId = context.read<IdProvider>().getData;
    var uid = FirebaseAuth.instance.currentUser!.uid;
    double total_price = context.watch<Cart>().totalPrice;
    double total_paid = context.watch<Cart>().totalPrice + 10.0;

    return FutureBuilder(
      future: customers.doc(docId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Something Was Wrong");
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return Center(
              child: InkWell(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, "/welcome_screen");
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Document Doesnt Exist"),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(uid)
                    ],
                  )));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
        return Material(
          color: Colors.grey.shade200,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.grey.shade200,
              appBar: AppBar(
                backgroundColor: Colors.grey.shade200,
                leading: const AppBarBackButton(
                  color: Colors.black,
                ),
                title: const AppBarTitle(title: 'Payment'),
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  "${total_paid.toStringAsFixed(2)} USD",
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            const Divider(
                              color: Colors.grey,
                              thickness: 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Order Total",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                Text(
                                  "$total_price USD",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Shipping Coast",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                Text(
                                  "10.00 USD",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            LabeledRadio(
                                title: 'Cash On Delivery',
                                widget: const Text('Pay Cash At Home'),
                                groupValue: selectedValue,
                                value: 1,
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value!;
                                  });
                                }),
                            LabeledRadio(
                                title: 'Pay Via Visa / Master Card',
                                widget: const Row(
                                  children: [
                                    Icon(Icons.payment, color: Colors.blue),
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Icon(
                                            FontAwesomeIcons.ccMastercard,
                                            color: Colors.blue)),
                                    Icon(FontAwesomeIcons.ccVisa,
                                        color: Colors.blue)
                                  ],
                                ),
                                groupValue: selectedValue,
                                value: 2,
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value!;
                                  });
                                }),
                            LabeledRadio(
                                title: 'Pay on PayPal',
                                widget: const Row(
                                  children: [
                                    Icon(FontAwesomeIcons.paypal,
                                        color: Colors.blue),
                                    Icon(FontAwesomeIcons.ccPaypal,
                                        color: Colors.blue)
                                  ],
                                ),
                                groupValue: selectedValue,
                                value: 3,
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value!;
                                  });
                                }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottomSheet: Container(
                  color: Colors.grey.shade200,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomButton(
                        label: 'Confirm ${total_price.toStringAsFixed(2)} USD',
                        widthPercentage: 1,
                        onPressed: () async {
                          showProgress();
                          if (selectedValue == 1) {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 100),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Pay At Home ${total_paid.toStringAsFixed(2)} \$",
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: CustomButton(
                                          widthPercentage: 0.9,
                                          label:
                                              "Confirm ${total_paid.toStringAsFixed(2)}",
                                          onPressed: () async {
                                            for (var item in context
                                                .read<Cart>()
                                                .getItems) {
                                              CollectionReference
                                                  orderReference =
                                                  FirebaseFirestore.instance
                                                      .collection("orders");
                                              orderId = const Uuid().v4();
                                              await orderReference
                                                  .doc(orderId)
                                                  .set({
                                                "cid": data['cid'],
                                                'customer_name': widget.name,
                                                'address': widget.address,
                                                'email': data['email'],
                                                'phone_number': widget.phone,
                                                'profile_image':
                                                    data['profile_image'],
                                                'sid': item.suppId,
                                                'pid': item.documentId,
                                                'orderid': orderId,
                                                'order_name': item.productName,
                                                'order_image': item.imagesUrl,
                                                'order_qty': item.qty,
                                                'order_price':
                                                    item.qty * item.price,
                                                'delivery_status': 'preparing',
                                                'delivery_date': '',
                                                'order_date': DateTime.now(),
                                                'paymen_method':
                                                    'cash on delivery',
                                                'order_review': false
                                              }).whenComplete(() => () async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .runTransaction(
                                                                (transaction) async {
                                                          DocumentReference
                                                              documentReference =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'products')
                                                                  .doc(item
                                                                      .documentId);
                                                          DocumentSnapshot
                                                              snapshot2 =
                                                              await transaction.get(
                                                                  documentReference);
                                                          transaction.update(
                                                              documentReference,
                                                              {
                                                                'instock':
                                                                    snapshot2[
                                                                            'in_stock'] -
                                                                        item.qty
                                                              });
                                                        });
                                                      });
                                            }

                                            await Future.delayed(const Duration(
                                                    microseconds: 100))
                                                .whenComplete(() {
                                              context.read<Cart>().clearCart();
                                              Navigator.popUntil(
                                                  context,
                                                  ModalRoute.withName(
                                                      '/customer_home'));
                                            });
                                          },
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else if (selectedValue == 2) {
                            makePayment();
                            // makePayment2();
                          } else if (selectedValue == 3) {}
                        },
                        color: Theme.of(context).colorScheme.secondary,
                      ))),
            ),
          ),
        );
      },
    );
  }

  // Future<Map<String, dynamic>> _createTestPaymentSheet() async {
  //   final url = Uri.parse('$kApiUrl/payment-sheet');
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: json.encode({
  //       'a': 'a',
  //     }),
  //   );
  //   final body = json.decode(response.body);
  //   if (body['error'] != null) {
  //     throw Exception(body['error']);
  //   }
  //   return body;
  // }

  Map<String, dynamic>? paymentIntentData;

  void makePayment() async {
    try {
      // Create Payment Intent
      paymentIntentData = await _createPaymnetIntent();

      var gpay =
          const PaymentSheetGooglePay(merchantCountryCode: "US", testEnv: true);
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            background: Colors.lightBlue,
            primary: Colors.blue,
            componentBorder: Colors.red,
          ),
          shapes: PaymentSheetShape(
            borderWidth: 4,
            shadow: PaymentSheetShadowParams(color: Colors.red),
          ),
          primaryButton: PaymentSheetPrimaryButtonAppearance(
            shapes: PaymentSheetPrimaryButtonShape(blurRadius: 8),
            colors: PaymentSheetPrimaryButtonTheme(
              light: PaymentSheetPrimaryButtonThemeColors(
                background: Color.fromARGB(255, 231, 235, 30),
                text: Color.fromARGB(255, 235, 92, 30),
                border: Color.fromARGB(255, 235, 92, 30),
              ),
            ),
          ),
        ),

        // customFlow: true,
        merchantDisplayName: "TestFlutter",
        // paymentIntentClientSecret: paymentIntentData!["paymentIntent"],
        paymentIntentClientSecret: paymentIntentData!['client_secret'],
        // customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
        customerId: paymentIntentData!['customer'],
        googlePay: gpay,
        style: ThemeMode.dark,
      ));

      displayPaymentSheet();
      print("Anjinggggggggggggggggggggggggg");
      // // InitPaymentSheet
      // await Stripe.instance.initPaymentSheet(
      //     paymentSheetParameters: SetupPaymentSheetParameters(
      //   paymentIntentClientSecret: paymentIntentData['client_secret'],
      //   allowsDelayedPaymentMethods: true,
      //   merchantDisplayName: 'FLutter Stripe Test',
      // ));
      // DisplayPaymentSheet
    } catch (e) {
      print(e.toString());
    }
  }

  _createPaymnetIntent() async {
    try {
      Map<String, dynamic> body = {
        "payment_method": null,
        'amount': '100',
        'currency': 'USD'
      };

      print(body);

      http.Response response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer $stripeSecretKey',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      // await Stripe.instance.confirmPaymentSheetPayment();
      print("done");
    } catch (e) {
      print("Failed");
      print(e);
    }
  }
}

class LabeledRadio extends StatelessWidget {
  const LabeledRadio(
      {super.key,
      required this.title,
      required this.widget,
      required this.groupValue,
      required this.value,
      required this.onChanged});

  final String title;
  final Widget widget;
  final int groupValue;
  final int value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) {
          onChanged(value);
        }
      },
      child: ListTile(
        leading: const Icon(Icons.attach_money, color: Colors.blue, size: 35),
        title: Text(
          title,
          style: TextStyle(color: Colors.black),
        ),
        subtitle: widget,
        trailing: Radio<int>(
          groupValue: groupValue,
          value: value,
          onChanged: (newValue) {
            onChanged(newValue!);
          },
          activeColor: Colors.black,
        ),
      ),
    );
  }
}
