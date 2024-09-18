import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/customer_screen/add_address.dart';
import 'package:multi_store_app_customer/customer_screen/address_book.dart';
import 'package:multi_store_app_customer/main_screen/minor_screen/payment_screen.dart';
import 'package:multi_store_app_customer/profiders/cart_profider.dart';
import 'package:multi_store_app_customer/profiders/id_provider.dart';
import 'package:multi_store_app_customer/widgets/appbar_widgets.dart';
import 'package:multi_store_app_customer/widgets/yellow_button.dart';
import 'package:provider/provider.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  late String name;
  late String phone;
  late String address;

  late String docId;

  @override
  void initState() {
    // TODO: implement initState
    docId = context.read<IdProvider>().getData;
    super.initState();
  }

  CollectionReference customers =
      FirebaseFirestore.instance.collection('customers');

  CollectionReference anonymous =
      FirebaseFirestore.instance.collection('anonymous');

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _addressStream = FirebaseFirestore.instance
        .collection('customers')
        .doc(docId)
        .collection('address')
        .where('default', isEqualTo: true)
        .limit(1)
        .snapshots();

    var uid = FirebaseAuth.instance.currentUser!.uid;
    double total_price = context.watch<Cart>().totalPrice;

    return StreamBuilder(
      stream: _addressStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("There Some Thing Wrong");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

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
                title: const AppBarTitle(title: 'Place'),
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                child: Column(
                  children: [
                    snapshot.data!.docs.isEmpty
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddAdress(),
                                  ));
                            },
                            child: Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)),
                                child: const Text(
                                    'Please Set Your Address First Before Purchasing the Product')),
                          )
                        : GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddressBook(),
                                  ));
                            },
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)),
                              child: ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var customer = snapshot.data!.docs[index];
                                  name =
                                      "${customer['first_name']}-${customer['last_name']}";
                                  phone = customer['phone'];
                                  address =
                                      "${customer['country']}-${customer['state']}-${customer['city']}";
                                  return ListTile(
                                    title: SizedBox(
                                      height: 54,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "${customer['first_name']} - ${customer['last_name']}",
                                              style: TextStyle(
                                                  color: Colors.black)),
                                          Text(
                                            "${customer['phone']}",
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    subtitle: SizedBox(
                                      height: 70,
                                      child: Column(
                                        children: [
                                          Text(
                                            'country: ${customer['city']}, state: ${customer['state']}, city: ${customer['city']}',
                                            softWrap: true,
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
                        child: Consumer<Cart>(
                          builder: (context, cart, child) {
                            return ListView.builder(
                              itemCount: cart.Count,
                              itemBuilder: (context, index) {
                                final order = cart.getItems[index];
                                return Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 12),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    bottomLeft:
                                                        Radius.circular(15)),
                                            child: SizedBox(
                                              height: double.infinity,
                                              width: 100,
                                              child: Image.network(
                                                  order.imagesUrl),
                                            ),
                                          ),
                                          Flexible(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  order.productName,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Colors.grey.shade600),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      order.price
                                                          .toStringAsFixed(2),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .grey.shade600),
                                                    ),
                                                    Text(
                                                      'x ${order.qty.toString()}',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .grey.shade600),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottomSheet: Container(
                  color: Colors.grey.shade200,
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CustomButton(
                        label: 'Confirm ${total_price.toStringAsFixed(2)} USD',
                        widthPercentage: 1,
                        onPressed: snapshot.data!.docs.isEmpty
                            ? () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AddAdress(),
                                    ));
                              }
                            : () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentScreen(
                                        name: name,
                                        phone: phone,
                                        address: address,
                                      ),
                                    ));
                              },
                        // onPressed: (){
                        //     Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen(name: "asdasd", phone: "213213", address: "asdasdasd",),));
                        // },
                        color: Theme.of(context).colorScheme.secondary,
                      ))),
            ),
          ),
        );
      },
    );
  }
}
