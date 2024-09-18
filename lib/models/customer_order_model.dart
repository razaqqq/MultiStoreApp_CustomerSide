import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:multi_store_app_customer/widgets/yellow_button.dart';

class CustomerOrderModel extends StatefulWidget {
  const CustomerOrderModel({super.key, required this.order});

  final dynamic order;

  @override
  State<CustomerOrderModel> createState() => _CustomerOrderModelState();
}

class _CustomerOrderModelState extends State<CustomerOrderModel> {
  late double rate;
  late String comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.teal,
            ),
            borderRadius: BorderRadius.circular(15)),
        child: ExpansionTile(
            title: Container(
              constraints: const BoxConstraints(maxHeight: 80),
              width: double.infinity,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Container(
                      constraints:
                          const BoxConstraints(maxHeight: 80, maxWidth: 80),
                      child: Image.network(
                        widget.order['order_image'],
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Flexible(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.order['order_name'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$ ${widget.order['order_price'].toString()}',
                              style: TextStyle(color: Colors.black),
                            ),
                            Text('x ${widget.order['order_qty'].toString()}',
                                style: TextStyle(color: Colors.black))
                          ],
                        ),
                      )
                    ],
                  ))
                ],
              ),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('See More ...'),
                Text(widget.order['delivery_status'],
                    style: TextStyle(color: Colors.black))
              ],
            ),
            children: [
              Container(
                // height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.order['delivery_status'] == 'delivered'
                      ? Colors.brown.withOpacity(0.2)
                      : Colors.teal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name : ${widget.order['customer_name']}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Phone No : ${widget.order['phone_number']}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Email Address : ${widget.order['email']}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Address : ${widget.order['address']}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Payment Status : }',
                            style: TextStyle(fontSize: 15),
                          ),
                          Text("${widget.order['paymen_method']}",
                              style: const TextStyle(
                                  color: Colors.teal, fontSize: 15))
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Delivery Status : ',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${widget.order['delivery_status']}',
                            style: const TextStyle(
                                color: Colors.green, fontSize: 15),
                          )
                        ],
                      ),
                      widget.order['delivery_status'] == 'shipping'
                          ? Text(
                              'Estimated Delivery Date: ${DateFormat('yyyy-MM-dd').format(widget.order['delivery_date'].toDate()).toString()}',
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            )
                          : const Text(''),
                      widget.order['delivery_status'] == 'delivered' &&
                              widget.order['order_review'] == false
                          ? TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Material(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 150),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            RatingBar.builder(
                                              allowHalfRating: true,
                                              initialRating: 1,
                                              minRating: 1,
                                              itemBuilder: (context, index) {
                                                return const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                );
                                              },
                                              onRatingUpdate: (value) {
                                                rate = value;
                                              },
                                            ),
                                            TextField(
                                              decoration: InputDecoration(
                                                hintText: 'Enter Your Review',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey,
                                                      width: 1),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .amber),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
                                              ),
                                              onChanged: (value) {
                                                comment = value;
                                              },
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                CustomButton(
                                                  widthPercentage: 0.3,
                                                  label: 'Cancel',
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                CustomButton(
                                                  widthPercentage: 0.3,
                                                  label: 'Ok',
                                                  onPressed: () async {
                                                    CollectionReference collRef =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'products')
                                                            .doc(widget
                                                                .order['pid'])
                                                            .collection(
                                                                'reviews');

                                                    await collRef
                                                        .doc(FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid)
                                                        .set({
                                                      'cid': FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid,
                                                      'orderid': widget
                                                          .order['orderid'],
                                                      'name': widget.order[
                                                          'customer_name'],
                                                      'email':
                                                          widget.order['email'],
                                                      'rate': rate,
                                                      'comment': comment,
                                                      'profile_image':
                                                          widget.order[
                                                              'profile_image']
                                                    }).whenComplete(() async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .runTransaction(
                                                              (transaction) async {
                                                        DocumentReference
                                                            documentReference =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'orders')
                                                                .doc(widget
                                                                        .order[
                                                                    'orderid']);

                                                        transaction.update(
                                                            documentReference, {
                                                          'order_review': true
                                                        });
                                                      });
                                                      await Future.delayed(
                                                              const Duration(
                                                                  microseconds:
                                                                      100))
                                                          .whenComplete(() {
                                                        Navigator.pop(context);
                                                      });
                                                    });
                                                  },
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Text("Write Review"))
                          : Text(''),
                      widget.order['delivery_status'] == 'delivered' &&
                              widget.order['order_review'] == true
                          ? const Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Colors.blue,
                                ),
                                Text(
                                  "Review Added",
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.blue),
                                )
                              ],
                            )
                          : const Text('')
                    ],
                  ),
                ),
              )
            ]),
      ),
    );
  }
}
