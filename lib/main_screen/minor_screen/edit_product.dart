import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_store_app_customer/widgets/pick_button.dart';
import 'package:multi_store_app_customer/widgets/yellow_button.dart';
import 'package:path/path.dart' as path;

import '../../utilities/categ_list.dart';
import '../../widgets/snackbar_widget.dart';

class EditProduct extends StatefulWidget {
  const EditProduct({super.key, required this.items});

  final dynamic items;

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
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
  List<dynamic> imageUrlList = [];
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

  Future uploadImages() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_imagesFileList!.isNotEmpty) {
        if (mainCategoryValue != 'select category' &&
            subCategValue != 'sub category') {
          try {
            for (var image in _imagesFileList!) {
              firebase_storage.Reference ref = firebase_storage
                  .FirebaseStorage.instance
                  .ref('products/${path.basename(image.path)}');

              await ref.putFile(File(image.path)).whenComplete(() async {
                await ref.getDownloadURL().then((value) {
                  imageUrlList.add(value);
                });
              });
            }
          } catch (e) {
            print(e.toString());
          }
        } else {
          MyMessageHandler.showSnackBar(
              _scaffoldKey, 'Please Select Categories');
        }
      } else {
        imageUrlList = widget.items['product_images'];
      }
    } else {
      MyMessageHandler.showSnackBar(_scaffoldKey, 'Please Fill All The Field');
    }
  }

  editProductInformation() async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('products')
          .doc(widget.items['pid']);
      transaction.update(documentReference, {
        // 'main_category': mainCategoryValue,
        // 'sub_category': subCategValue,
        'price': price,
        'in_stock': quantity,
        'product_name': productName,
        'product_description': description,
        'product_images': imageUrlList,
        'discount': discount,
      });
    }).whenComplete(() {
      Navigator.pop(context);
    });
  }

  Future saveChanges() async {
    await uploadImages().whenComplete(() async {
      await editProductInformation();
    });
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

  Widget previewCurrentImages() {
    List<dynamic> itemImages = widget.items['product_images'];
    return ListView.builder(
      itemCount: itemImages.length,
      itemBuilder: (context, index) {
        return Image.network(itemImages[index]);
      },
    );
  }

  void selectedMainCategory(String value) {
    if (value == 'select category') {
      subCategList = [];
    } else if (value == 'men') {
      subCategList = men;
    } else if (value == 'women') {
      subCategList = women;
    } else if (value == 'electronics') {
      subCategList = electronics;
    } else if (value == 'accessories') {
      subCategList = accessories;
    } else if (value == 'shoes') {
      subCategList = shoes;
    } else if (value == 'home & garden') {
      subCategList = homeandgarden;
    } else if (value == 'beauty') {
      subCategList = beauty;
    } else if (value == 'kids') {
      subCategList = kids;
    } else if (value == 'bags') {
      subCategList = bags;
    }
    print(value);
    setState(() {
      mainCategoryValue = value.toString();
      subCategValue = "sub category";
    });
  }

  // void uploadProduct() async {
  //   if (mainCategoryValue != 'select category' &&
  //       subCategValue != 'sub category') {
  //     if (_formKey.currentState!.validate()) {
  //       _formKey.currentState!.save();
  //       if (_imagesFileList.isNotEmpty) {
  //         setState(() {
  //           processing = true;
  //         });
  //         try {
  //           for (var image in _imagesFileList!) {
  //             firebase_storage.Reference ref = firebase_storage
  //                 .FirebaseStorage.instance
  //                 .ref('products/${path.basename(image.path)}');
  //
  //             await ref.putFile(File(image.path)).whenComplete(() async {
  //               await ref.getDownloadURL().then((value) {
  //                 imageUrlList.add(value);
  //               });
  //             });
  //           }
  //           CollectionReference productReference =
  //           FirebaseFirestore.instance.collection('products');
  //
  //           productId = const Uuid().v4();
  //
  //           await productReference.doc(productId).set({
  //             'pid': productId,
  //             'main_category': mainCategoryValue,
  //             'sub_category': subCategValue,
  //             'price': price,
  //             'in_stock': quantity,
  //             'product_name': productName,
  //             'product_description': description,
  //             'sid': FirebaseAuth.instance.currentUser!.uid,
  //             'product_images': imageUrlList,
  //             'discount': discount,
  //           });
  //         } catch (e) {
  //           print(e);
  //         }
  //
  //         print('images picked');
  //         print("valid");
  //         print(price);
  //         print(quantity);
  //         print(productName);
  //         print(description);
  //         print(mainCategoryValue);
  //         print(subCategValue);
  //         setState(() {
  //           _imagesFileList = [];
  //           mainCategoryValue = 'select category';
  //           subCategList = [];
  //           imageUrlList = [];
  //           processing = false;
  //         });
  //         _formKey.currentState!.reset();
  //         MyMessageHandler.showSnackBar(
  //             _scaffoldKey, "Congratulations Your Products Has Been Created");
  //       } else {
  //         MyMessageHandler.showSnackBar(
  //             _scaffoldKey, "Please Pick Images First");
  //       }
  //     } else {
  //       MyMessageHandler.showSnackBar(
  //           _scaffoldKey, "Please Fill All The Fields");
  //     }
  //   } else {
  //     MyMessageHandler.showSnackBar(_scaffoldKey, "Please Select Categories");
  //   }
  // }

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
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            color: Colors.blueGrey.shade100,
                            height: MediaQuery.of(context).size.width * 0.5,
                            width: MediaQuery.of(context).size.width * 0.5,
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
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.width * 0.5,
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "* Select Main Category",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    DropdownButton(
                                      iconSize: 40,
                                      iconEnabledColor: Colors.red,
                                      dropdownColor: Colors.teal.shade300,
                                      value: mainCategoryValue,
                                      items: maincateg
                                          .map<DropdownMenuItem<String>>(
                                              (value) {
                                        return DropdownMenuItem(
                                            value: value,
                                            child: Text(
                                              value,
                                            ));
                                      }).toList(),
                                      onChanged: (value) {
                                        selectedMainCategory(value.toString());
                                      },
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "* Select Sub Category",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    DropdownButton(
                                      iconSize: 40,
                                      iconEnabledColor: Colors.red,
                                      dropdownColor: Colors.teal.shade300,
                                      iconDisabledColor: Colors.black,
                                      menuMaxHeight: 500,
                                      disabledHint: const Text("sub category"),
                                      value: subCategValue,
                                      items: subCategList
                                          .map<DropdownMenuItem<String>>(
                                              (value) {
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
                      ExpandablePanel(
                          theme: const ExpandableThemeData(hasIcon: false),
                          header: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.all(6),
                              child: const Center(
                                child: Text(
                                  'Change Images Category',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          collapsed: const SizedBox(),
                          expanded: changeImages())
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
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: TextFormField(
                              initialValue:
                                  widget.items['price'].toStringAsDouble(2),
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
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: textFormDecoration.copyWith(
                                  labelText: 'price', hintText: 'price .. \$'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: TextFormField(
                              initialValue: widget.items['discount'],
                              maxLength: 2,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return null;
                                } else if (value.isValidPrice() != true) {
                                  return "Invalid Price";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                discount = int.parse(value!);
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: textFormDecoration.copyWith(
                                  labelText: 'discount',
                                  hintText: 'discount .. % \$'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        initialValue: widget.items['in_stock'],
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
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        initialValue: widget.items['product_name'],
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
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        initialValue: widget.items['product_description'],
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
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CustomButton(
                              widthPercentage: 0.25,
                              label: 'Cancel',
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              color: Theme.of(context).colorScheme.secondary),
                          CustomButton(
                              widthPercentage: 0.5,
                              label: 'Save Changes',
                              onPressed: () {
                                saveChanges();
                              },
                              color: Theme.of(context).colorScheme.secondary),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      PickUpButton(
                          label: 'Delete Items',
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .runTransaction((transaction) async {
                              DocumentReference documentReference =
                                  FirebaseFirestore.instance
                                      .collection('products')
                                      .doc(widget.items['pid']);
                              transaction.delete(documentReference);
                            }).whenComplete(() {
                              Navigator.pop(context);
                            });
                          },
                          width: 0.7)
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget changeImages() {
    return Column(
      children: [
        Row(
          children: [
            Container(
                color: Colors.blueGrey.shade100,
                height: MediaQuery.of(context).size.width * 0.5,
                width: MediaQuery.of(context).size.width * 0.5,
                child: previewCurrentImages()),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "* Select Main Category",
                        style: TextStyle(color: Colors.red),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        margin: const EdgeInsets.all(6),
                        constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width * 0.3),
                        decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(10)),
                        child:
                            Center(child: Text(widget.items['main_category'])),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Sub Category",
                        style: TextStyle(color: Colors.red),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        margin: const EdgeInsets.all(6),
                        constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width * 0.3),
                        decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(10)),
                        child:
                            Center(child: Text(widget.items['sub_category'])),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: _imagesFileList!.isNotEmpty
              ? CustomButton(
                  widthPercentage: 0.6,
                  label: 'Reset',
                  onPressed: () {
                    setState(
                      () {
                        _imagesFileList = [];
                      },
                    );
                  },
                  color: Theme.of(context).colorScheme.secondary)
              : CustomButton(
                  widthPercentage: 0.6,
                  label: 'Change Images',
                  onPressed: _pickProductImages,
                  color: Theme.of(context).colorScheme.secondary),
        )
      ],
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
    return RegExp(r'^([0-9]*)$').hasMatch(this);
  }
}
