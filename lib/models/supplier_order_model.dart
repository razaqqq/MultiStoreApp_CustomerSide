import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:intl/intl.dart';

class SupplierOrderModel extends StatelessWidget {
  const SupplierOrderModel({super.key, required this.order});

  final dynamic order;

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
                        order['order_image'][0],
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
                        order['order_name'],
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
                            Text('\$ ${order['order_price'].toString()}'),
                            Text('x ${order['order_qty'].toString()}')
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
                Text(order['delivery_status'])
              ],
            ),
            children: [
              Container(
                // height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name : ${order['customer_name']}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Phone No : ${order['phone_number']}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Email Address : ${order['email']}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Address : ${order['address']}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Payment Status : }',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          Text("${order['paymen_method']}",
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
                            '${order['delivery_status']}',
                            style: const TextStyle(
                                color: Colors.green, fontSize: 15),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Order Date : ',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy-MM-dd')
                                .format(order['order_date'].toDate())
                                .toString(),
                            style: const TextStyle(
                                color: Colors.green, fontSize: 15),
                          )
                        ],
                      ),
                      order['delivery_status'] == 'delivered'
                          ? const Text(
                              'This Order Has Been Already Delivered',
                              style: TextStyle(color: Colors.red),
                            )
                          : Row(
                              children: [
                                const Text(
                                  'Change Delivary Status to : ',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                order['delivery_status'] == 'preparing'
                                    ? TextButton(
                                        onPressed: () {
                                          DatePickerBdaya.showDatePicker(
                                            context,
                                            minTime: DateTime.now(),
                                            maxTime: DateTime.now()
                                                .add(const Duration(days: 365)),
                                            onConfirm: (date) async {
                                              await FirebaseFirestore.instance.collection('orders').doc(order['orderid']).update({
                                                'delivery_status' : 'shipping',
                                                'delivery_date' : date
                                              });
                                            },
                                          );
                                        },
                                        child: const Text("Shipping ?"))
                                    : TextButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance.collection('orders').doc(order['orderid']).update({
                                            'delivery_status' : 'delivered',
                                          });
                                        },
                                        child: const Text("Delivered ?"))
                              ],
                            ),
                    ],
                  ),
                ),
              )
            ]),
      ),
    );
  }
}
