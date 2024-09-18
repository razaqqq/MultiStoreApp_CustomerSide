import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../models/product_model.dart';
import '../../widgets/appbar_widgets.dart';

class SubCategoryProduct extends StatefulWidget {
  final String mainCategoryName;
  final String subCategoryName;
  final bool fromOnBoarding;

  const SubCategoryProduct({
    super.key,
    required this.mainCategoryName,
    required this.subCategoryName,
    this.fromOnBoarding = false
  });

  @override
  State<SubCategoryProduct> createState() => _SubCategoryProductState();
}

class _SubCategoryProductState extends State<SubCategoryProduct> {
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productStream = FirebaseFirestore.instance
        .collection('products')
        .where('main_category', isEqualTo: widget.mainCategoryName)
    .where('sub_category', isEqualTo: widget.subCategoryName)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        centerTitle: true,
        leading: widget.fromOnBoarding ? IconButton(onPressed: (){
          Navigator.pushReplacementNamed(context, '/customer_home');
        }, icon: Icon(Icons.arrow_back, color: Colors.black,)) : AppBarBackButton(color: Colors.black,),
        elevation: 0,
        backgroundColor: Colors.white,
        title: AppBarTitle(title: widget.subCategoryName),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            return Center(
              child: Text(
                "This Category Has No Items Here",
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
    );
  }
}
