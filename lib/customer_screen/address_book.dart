import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/customer_screen/add_address.dart';
import 'package:multi_store_app_customer/profiders/id_provider.dart';
import 'package:multi_store_app_customer/widgets/appbar_widgets.dart';
import 'package:multi_store_app_customer/widgets/yellow_button.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class AddressBook extends StatefulWidget {
  const AddressBook({super.key});

  @override
  State<AddressBook> createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBook> {
  void showProgress() {
    ProgressDialog progressDialog = ProgressDialog(context: context);
    progressDialog.show(
        max: 100, msg: 'please wait ..', backgroundColor: Colors.red);
  }

  void hideProgress() {
    ProgressDialog progressDialog = ProgressDialog(context: context);
    progressDialog.close();
  }

  @override
  Widget build(BuildContext context) {
    String docId = context.read<IdProvider>().getData;

    final Stream<QuerySnapshot> _addressStream = FirebaseFirestore.instance
        .collection('customers')
        .doc(docId)
        .collection('address')
        .snapshots();

    Future defaultAddressFalse(var item) async {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference documentReference = FirebaseFirestore.instance
            .collection('customers')
            .doc(docId)
            .collection('address')
            .doc(item.id);
        transaction.update(documentReference, {
          'default': false,
        });
      });
    }

    Future defaultAddressTrue(dynamic customer) async {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference documentReference = FirebaseFirestore.instance
            .collection('customers')
            .doc(docId)
            .collection('address')
            .doc(customer['address_id']);
        transaction.update(documentReference, {
          'default': true,
        });
      });
    }

    Future updateProfile(dynamic customer) async {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference documentReference =
            FirebaseFirestore.instance.collection('customers').doc(docId);
        transaction.update(documentReference, {
          'address':
              "${customer['country']}-${customer['state']}-${customer['city']}",
          'phone': customer['phone']
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const AppBarBackButton(
          color: Colors.black,
        ),
        title: const AppBarTitle(
          title: 'Address Book',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
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
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "You Not Have Set and Address Yet",
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

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var customer = snapshot.data!.docs[index];
                    Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) async {
                        await FirebaseFirestore.instance
                            .runTransaction((transaction) async {
                          DocumentReference docReference = FirebaseFirestore
                              .instance
                              .collection('customers')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('address')
                              .doc(customer['address_id']);
                          transaction.delete(docReference);
                        });
                      },
                      child: GestureDetector(
                        onTap: () async {
                          showProgress();
                          for (var item in snapshot.data!.docs) {
                            await defaultAddressFalse(item);
                          }
                          await defaultAddressTrue(customer)
                              .whenComplete(() => updateProfile(customer));
                          Future.delayed(const Duration(microseconds: 100))
                              .whenComplete(() => Navigator.pop(context));
                        },
                        child: Card(
                          color: customer['default']
                              ? Colors.white
                              : Colors.yellow,
                          child: ListTile(
                            trailing: customer['default'] == true
                                ? const Icon(
                                    Icons.home,
                                    color: Colors.brown,
                                  )
                                : const SizedBox(),
                            title: SizedBox(
                              height: 50,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${customer['first_name']} - ${customer['last_name']}"),
                                  Text("${customer['phone']}")
                                ],
                              ),
                            ),
                            subtitle: SizedBox(
                              height: 70,
                              child: Column(
                                children: [
                                  Text(
                                    'countY: ${customer['city']}, state: ${customer['state']}, city: ${customer['city']}',
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            )),
            CustomButton(
              widthPercentage: 0.8,
              label: 'Add New Address',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddAdress(),
                    ));
              },
              color: Theme.of(context).colorScheme.secondary,
            )
          ],
        ),
      ),
    );
  }
}
