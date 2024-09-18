import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/product_model.dart';

class WomanGalleryScreen extends StatefulWidget {
  const WomanGalleryScreen({super.key});

  @override
  State<WomanGalleryScreen> createState() => _WomanGalleryScreenState();
}

class _WomanGalleryScreenState extends State<WomanGalleryScreen> {
  final Stream<QuerySnapshot> _productStream = FirebaseFirestore.instance
      .collection('products')
      .where('main_category', isEqualTo: 'women')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
          return Padding(
              padding: EdgeInsets.all(50),
              child: Center(
                child: Text(
                  "This Category Has No Items Here",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    letterSpacing: 1.5
                  )
                ),
              ));
        }

        return SingleChildScrollView(
          child: MasonryGridView.count(
            padding: const EdgeInsets.all(15),
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
        );
      },
    );
  }
}
