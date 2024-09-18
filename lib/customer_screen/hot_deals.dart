import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/product_model.dart';

class HotDeals extends StatefulWidget {
  const HotDeals(
      {super.key, required this.maxDiscount, required this.fromOnBoarding});

  final String maxDiscount;
  final bool fromOnBoarding;

  @override
  State<HotDeals> createState() => _HotDealsState();
}

class _HotDealsState extends State<HotDeals> {
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productStream = FirebaseFirestore.instance
        .collection('products')
        .where('discount', isNotEqualTo: 0)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: SizedBox(
          height: 160,
          child: Stack(
            children: [
              Positioned(
                  top: 70,
                  left: 0,
                  child: DefaultTextStyle(
                    style: const TextStyle(
                        height: 1.2,
                        color: Colors.yellowAccent,
                        fontSize: 30,
                        fontFamily: 'PressStart2P'),
                    child: AnimatedTextKit(
                      totalRepeatCount: 5,
                      animatedTexts: [
                        TypewriterAnimatedText('Hot Deals',
                            speed: const Duration(microseconds: 60),
                            cursor: '|'),
                        TypewriterAnimatedText(
                            'up to ${widget.maxDiscount} % of',
                            speed: const Duration(microseconds: 60),
                            cursor: '|',
                            textStyle: const TextStyle(fontSize: 20)),
                      ],
                    ),
                  ))
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.yellow),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/customer_home');
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 60,
            color: Colors.black,
          ),
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
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
                        "There are No Hotdeals Available Right Now",
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

                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SingleChildScrollView(
                      child: MasonryGridView.count(
                        padding: const EdgeInsets.all(5),
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
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
