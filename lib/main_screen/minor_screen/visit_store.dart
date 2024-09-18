import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_store_app_customer/profiders/id_provider.dart';
import 'package:multi_store_app_customer/widgets/alert_dialog.dart';
import 'package:multi_store_app_customer/widgets/appbar_widgets.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';

class VisitStore extends StatefulWidget {
  final String suppId;

  const VisitStore({super.key, required this.suppId});

  @override
  State<VisitStore> createState() => _VisitStoreState();
}

class _VisitStoreState extends State<VisitStore> {
  bool following = false;
  String customerId = '';

  List<String> susscribtionsList = [];

  checkUserSubscriptions() {
    FirebaseFirestore.instance
        .collection('supliers')
        .doc(widget.suppId)
        .collection('subscriptions')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        susscribtionsList.add(doc['customer_id']);
      }
    }).whenComplete(() {
      following =
          susscribtionsList.contains(context.read<IdProvider>().getData);
    });
  }

  unSubscribeFromTopic() {
    FirebaseMessaging.instance.unsubscribeFromTopic('subscribtion_topic');
    FirebaseFirestore.instance
        .collection('supliers')
        .doc(widget.suppId)
        .collection('subscriptions')
        .doc(context.read<IdProvider>().getData)
        .delete();
    setState(() {
      following = false;
    });
  }

  subscribtionToTopic() {
    FirebaseMessaging.instance.subscribeToTopic('subscribtion_topic');
    FirebaseFirestore.instance
        .collection('supliers')
        .doc(widget.suppId)
        .collection('subscriptions')
        .doc(context.read<IdProvider>().getData)
        .set({'customer_id': context.read<IdProvider>().getData});
    setState(() {
      following = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    customerId = context.read<IdProvider>().getData;

    print('Test ${customerId}');

    customerId == '' ? null : checkUserSubscriptions();

    super.initState();
  }

  CollectionReference storesDetails =
      FirebaseFirestore.instance.collection('supliers');

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productStream = FirebaseFirestore.instance
        .collection('products')
        .where('sid', isEqualTo: widget.suppId)
        .snapshots();

    return FutureBuilder(
      future: storesDetails.doc(widget.suppId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("There Something Wrong"),
          );
        } else if (snapshot.hasData && !snapshot.data!.exists) {
          return const Center(
            child: Text("Document Doest Exist"),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            backgroundColor: Colors.blueGrey.shade100,
            appBar: AppBar(
              toolbarHeight: 150,
              flexibleSpace: data['cover_image'] == ''
                  ? Image.asset(
                      'images/inapp/coverimage.jpg',
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      data['cover_image'],
                      fit: BoxFit.cover,
                    ),
              leading: const AppBarBackButton(color: Colors.yellow),
              title: Row(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        border: Border.all(width: 4, color: Colors.teal),
                        borderRadius: BorderRadius.circular(15)),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          data['store_logo'],
                          fit: BoxFit.cover,
                        )),
                  ),
                  SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                data['store_name'].toUpperCase(),
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        customerId == ''
                            ? SizedBox(
                                child: TextButton(
                                    onPressed: () {
                                      MyAlertDialog.showMyDialog(
                                          context: context,
                                          title: "Login",
                                          content:
                                              "Do You You Want to Follow, Please Create Account or Login First",
                                          tabYes: () {
                                            Navigator.pushReplacementNamed(
                                                context, '/customer_login');
                                          },
                                          tabNo: () {
                                            Navigator.pop(context);
                                          });
                                    },
                                    child: Text("Login")))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                      height: 35,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      decoration: BoxDecoration(
                                          color: Colors.teal,
                                          border: Border.all(
                                              width: 3, color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      child: MaterialButton(
                                        onPressed: following == false
                                            ? () {
                                                subscribtionToTopic();
                                              }
                                            : () {
                                                unSubscribeFromTopic();
                                              },
                                        child: following
                                            ? const Text("UNFOLLOW")
                                            : const Text('FOLLOW'),
                                      )),
                                ],
                              ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(8.0),
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
                    return const Center(
                      child: Text(
                        "This Store Has No Items Here",
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 26,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Acme',
                            letterSpacing: 1.5),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: MasonryGridView.count(
                      padding: EdgeInsets.all(5),
                      physics: NeverScrollableScrollPhysics(),
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
                    ),
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.green,
                child: const Icon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 40,
                )),
          );
        } else {
          return Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
