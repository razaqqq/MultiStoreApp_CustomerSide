import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_store_app_customer/utilities/categ_list.dart';
import 'package:multi_store_app_customer/widgets/snackbar_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';


class UploadProductScreen extends StatefulWidget {
  const UploadProductScreen({super.key});

  @override
  State<UploadProductScreen> createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  GlobalKey<ScaffoldMessengerState>();

  late double price;
  late int quantity;
  late String productName;
  late String description;
  late String productId;
  int? discount = 0;

  String mainCategoryValue = "select category";
  String subCategValue = "sub category";
  final ImagePicker imagePicker = ImagePicker();
  bool processing = false;

  List<String> subCategList = [];
  List<String> imageUrlList = [];
  List<XFile> _imagesFileList = [];

  dynamic _pickedImageError;

  void _pickProductImages() async {
    try {
      final pickImages = await imagePicker.pickMultiImage(
          maxWidth: 300, maxHeight: 300, imageQuality: 95);
      setState(() {
        _imagesFileList = pickImages!;
      });
    } catch (e) {
      setState(() {
        _pickedImageError = e;
      });
      print(_pickedImageError);
    }
  }

  Widget previewImages() {
    return ListView.builder(
      itemCount: _imagesFileList.length,
      itemBuilder: (context, index) {
        return Image.file(
          File(_imagesFileList![index].path),
          fit: BoxFit.cover,
        );
      },
    );
  }

  void selectedMainCategory(String value) {
    if (value == 'select category') {
      subCategList = [];
    }
    else if (value == 'men') {
      subCategList = men;
    }
    else if (value == 'women') {
      subCategList = women;
    }
    else if (value == 'electronics') {
      subCategList = electronics;
    }
    else if (value == 'accessories') {
      subCategList = accessories;
    }
    else if (value == 'shoes') {
      subCategList = shoes;
    }
    else if (value == 'home & garden') {
      subCategList = homeandgarden;
    }
    else if (value == 'beauty') {
      subCategList = beauty;
    }
    else if (value == 'kids') {
      subCategList = kids;
    }
    else if (value == 'bags') {
      subCategList = bags;
    }
    print(value);
    setState(() {
      mainCategoryValue = value.toString();
      subCategValue = "sub category";
    });
  }

  void uploadProduct() async {
    if (mainCategoryValue != 'select category' &&
        subCategValue != 'sub category') {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        if (_imagesFileList.isNotEmpty) {
          setState(() {
            processing = true;
          });
          try {
            for (var image in _imagesFileList!) {
              firebase_storage.Reference ref = firebase_storage.FirebaseStorage
                  .instance.ref('products/${path.basename(image.path)}');

              await ref.putFile(File(image.path)).whenComplete(() async {
                await ref.getDownloadURL().then((value) {
                  imageUrlList.add(value);
                });
              });
            }
            CollectionReference productReference = FirebaseFirestore.instance
                .collection('products');

            productId = const Uuid().v4();

            await productReference.doc(productId).set(
                {
                  'pid': productId,
                  'main_category': mainCategoryValue,
                  'sub_category': subCategValue,
                  'price': price,
                  'in_stock': quantity,
                  'product_name': productName,
                  'product_description': description,
                  'sid': FirebaseAuth.instance.currentUser!.uid,
                  'product_images': imageUrlList,
                  'discount': discount,
                }
            );
          } catch (e) {
            print(e);
          }


          print('images picked');
          print("valid");
          print(price);
          print(quantity);
          print(productName);
          print(description);
          print(mainCategoryValue);
          print(subCategValue);
          setState(() {
            _imagesFileList = [];
            mainCategoryValue = 'select category';
            subCategList = [];
            imageUrlList = [];
            processing = false;
          });
          _formKey.currentState!.reset();
          MyMessageHandler.showSnackBar(
              _scaffoldKey, "Congratulations Your Products Has Been Created");
        } else {
          MyMessageHandler.showSnackBar(
              _scaffoldKey, "Please Pick Images First");
        }
      } else {
        MyMessageHandler.showSnackBar(
            _scaffoldKey, "Please Fill All The Fields");
      }
    }
    else {
      MyMessageHandler.showSnackBar(_scaffoldKey, "Please Select Categories");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            reverse: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        color: Colors.blueGrey.shade100,
                        height: MediaQuery
                            .of(context)
                            .size
                            .width * 0.5,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.5,
                        child: _imagesFileList.length > 0
                            ? previewImages()
                            : const Center(
                          child: Text(
                            "You Have Not Picked an Images yet !",
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.5,
                        height: MediaQuery
                            .of(context)
                            .size
                            .width * 0.5,
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("* Select Main Category",
                                  style: TextStyle(color: Colors.red),),
                                DropdownButton(
                                  iconSize: 40,
                                  iconEnabledColor: Colors.red,
                                  dropdownColor: Colors.teal.shade300,
                                  value: mainCategoryValue,
                                  items: maincateg.map<
                                      DropdownMenuItem<String>>((value) {
                                    return DropdownMenuItem(
                                        value: value, child: Text(value,));
                                  }).toList(),
                                  onChanged: (value) {
                                    selectedMainCategory(value.toString());
                                  },
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("* Select Sub Category",
                                  style: TextStyle(color: Colors.red),),
                                DropdownButton(
                                  iconSize: 40,
                                  iconEnabledColor: Colors.red,
                                  dropdownColor: Colors.teal.shade300,
                                  iconDisabledColor: Colors.black,
                                  menuMaxHeight: 500,
                                  disabledHint: const Text("sub category"),
                                  value: subCategValue,
                                  items: subCategList.map<
                                      DropdownMenuItem<String>>((value) {
                                    return DropdownMenuItem(
                                        value: value, child: Text(value));
                                  }).toList(),
                                  onChanged: (value) {
                                    print(value);
                                    setState(() {
                                      subCategValue = value.toString();
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                    child: Divider(
                      color: Colors.teal,
                      thickness: 1.5,
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.45,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please Enter Price For Your Product';
                                } else if (value.isValidPrice() != true) {
                                  return "Invalid Price";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                price = double.parse(value!);
                              },
                              keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                              decoration: textFormDecoration.copyWith(
                                  labelText: 'price', hintText: 'price .. \$'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.45,
                            child: TextFormField(
                              maxLength: 2,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return null;
                                }
                                else if (value.isValidPrice() != true) {
                                  return "Invalid Price";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                discount = int.parse(value!);
                              },
                              keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                              decoration: textFormDecoration.copyWith(
                                  labelText: 'discount', hintText: 'discount .. % \$'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Input Quantity for You Product";
                          } else if (!value.isValidQuantity()) {
                            print("Not Valid Quantity");
                          }
                          return null;
                        },
                        onSaved: (value) {
                          quantity = int.parse(value!);
                        },
                        keyboardType: TextInputType.number,
                        decoration: textFormDecoration.copyWith(
                            labelText: 'Quantity', hintText: 'Add Quantity'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Insert Some Product Name";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          productName = value!.toString();
                        },
                        maxLength: 100,
                        maxLines: 3,
                        decoration: textFormDecoration.copyWith(
                            labelText: 'product name',
                            hintText: 'Enter Product Name'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Input Some Description For Your Product";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          description = value!.toString();
                        },
                        maxLines: 5,
                        maxLength: 800,
                        decoration: textFormDecoration.copyWith(
                            labelText: 'product descriptions',
                            hintText: 'Enter Product Descriptions'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: FloatingActionButton(
                onPressed: _imagesFileList!.isEmpty
                    ? () {
                  _pickProductImages();
                }
                    : () {
                  setState(() {
                    _imagesFileList = [];
                  });
                },
                backgroundColor: Colors.teal,
                child: _imagesFileList!.isEmpty
                    ? const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                )
                    : const Icon(Icons.delete_forever, color: Colors.white),
              ),
            ),
            FloatingActionButton(
              onPressed: processing == true ? null : () {
                uploadProduct();
              },
              backgroundColor: Colors.teal,
              child: processing == true
                  ? const CircularProgressIndicator()
                  : Icon(
                Icons.upload,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

var textFormDecoration = InputDecoration(
  labelText: 'price',
  hintText: 'price .. \$',
  labelStyle: const TextStyle(color: Colors.teal),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.teal, width: 1),
      borderRadius: BorderRadius.circular(10)),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blueAccent, width: 1),
      borderRadius: BorderRadius.circular(10)),
);

extension QuantityValidator on String {
  bool isValidQuantity() {
    return RegExp(r'^[1-9][0-9]*$').hasMatch(this);
  }
}

extension PriceValidator on String {
  bool isValidPrice() {
    return RegExp(r'^((([1-9][0-9]*[\.]*)||([0][\.]*))([0-9]{1,2}))$')
        .hasMatch(this);
  }
}

extension DiscountValidator on String {
  bool isValidDiscount() {
    return RegExp(r'^([0-9]*)$')
        .hasMatch(this);
  }
}
