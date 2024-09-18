import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/search_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchInput = '';

  final Stream<QuerySnapshot> _searchStream =
      FirebaseFirestore.instance.collection('products').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade300,
        title: CupertinoSearchTextField(
          autofocus: true,
          backgroundColor: Colors.white,
          onChanged: (value) {
            setState(() {
              searchInput = value;
            });
          },
        ),
      ),
      body: searchInput == ''
          ? Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(25)),
                height: 50,
                width: MediaQuery.of(context).size.width * 0.7,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Icon(Icons.search, color: Colors.white),
                    Text(
                      'Search For Anithing ..',
                      style: TextStyle(color: Colors.white),
                    ),

                  ],
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _searchStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Material(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Material(
                    child: Center(
                      child: Text("There Something Wrong"),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return Text("Fuckyou Bitch");
                }

                final result = snapshot.data!.docs
                    .where((e) => e['product_name'.toLowerCase()].contains(searchInput.toLowerCase()));


                return ListView(
                  // children: [Text(snapshot.data!.docs.length.toString())],
                  children: result.map((e) => SearchModel(product: e)).toList(),

                  // children: snapshot.data!.docs.map((e) => Text(e['product_name'].toString())).toList(),
                  // children: result.
                  //     .map((product) => SearchModel(product: product))
                  //     .toList(),
                );
              },
            ),
    );
  }
}
