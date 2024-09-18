import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';

import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/profiders/id_provider.dart';
import 'package:multi_store_app_customer/widgets/appbar_widgets.dart';
import 'package:multi_store_app_customer/widgets/snackbar_widget.dart';
import 'package:multi_store_app_customer/widgets/yellow_button.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddAdress extends StatefulWidget {
  const AddAdress({super.key});

  @override
  State<AddAdress> createState() => _AddAdressState();
}

class _AddAdressState extends State<AddAdress> {
  late String firstName;
  late String lastName;
  late String phone;
  late String countryValue;
  late String stateValue;
  late String cityValue;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> countryFormKey = GlobalKey<FormState>();

  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String docId = context.read<IdProvider>().getData;

    return ScaffoldMessenger(
      key: scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: AppBarBackButton(color: Colors.black),
          title: const AppBarTitle(
            title: 'Add Address',
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 40, 30, 40),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.50,
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Enter Your First Name";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                firstName = newValue.toString();
                              },
                              decoration: textFormDecoration.copyWith(
                                labelText: "First Name",
                                hintText: "Enter Your First Name",
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.50,
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Enter Your Last Name";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                lastName = newValue.toString();
                              },
                              decoration: textFormDecoration.copyWith(
                                labelText: "Last Name",
                                hintText: "Enter Last Your Full Name",
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.50,
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Enter Your Phone Number";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                phone = newValue.toString();
                              },
                              decoration: textFormDecoration.copyWith(
                                labelText: "Phone Number",
                                hintText: "Enter Your Phone Number",
                              )),
                        ),
                      ),
                    ],
                  ),
                  CountryStateCityPicker(
                    // key: GLobalKeyss().formKey,
                    country: countryController,
                    state: stateController,
                    city: cityController,
                    dialogColor: Colors.grey.shade200,
                    textFieldDecoration: InputDecoration(
                        fillColor: Colors.blueGrey.shade100,
                        filled: true,
                        suffixIcon: const Icon(Icons.arrow_downward_rounded),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: CustomButton(
                      widthPercentage: 0.8,
                      label: "Add New Address",
                      onPressed: () async {
                        countryValue = countryController.text;
                        stateValue = stateController.text;
                        cityValue = cityController.text;

                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          CollectionReference addressReference =
                              FirebaseFirestore.instance
                                  .collection('customers')
                                  .doc(docId)
                                  .collection('address');
                          var addressId = const Uuid().v4();
                          await addressReference.doc(addressId).set({
                            'address_id': addressId,
                            'first_name': firstName,
                            'last_name': lastName,
                            'phone': phone,
                            'country': countryController.text,
                            'city': cityController.text,
                            'state': stateController.text,
                            'default': true
                          }).whenComplete(() {
                            Navigator.pop(context);
                          });
                        } else {
                          MyMessageHandler.showSnackBar(
                              scaffoldKey, "Please Fill All The Field");
                        }
                      },
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

var textFormDecoration = InputDecoration(
  labelText: "Full Name",
  hintText: "Enter Your Fullname",
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.teal, width: 1),
    borderRadius: BorderRadius.circular(25),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.green, width: 1),
    borderRadius: BorderRadius.circular(25),
  ),
);
