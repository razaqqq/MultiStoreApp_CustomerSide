import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:multi_store_app_customer/profiders/authentication_repository.dart';
import 'package:multi_store_app_customer/widgets/appbar_widgets.dart';
import 'package:multi_store_app_customer/widgets/snackbar_widget.dart';
import 'package:multi_store_app_customer/widgets/yellow_button.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  bool checkPassword = true;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          leading: AppBarBackButton(color: Colors.black),
          elevation: 0,
          title: AppBarTitle(title: 'Change Password'),
        ),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  const Text(
                    'to Change Your Password Please Fill in the Form Below and Click Save',
                    softWrap: true,
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Acme'),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Your Current Password';
                        }
                        return null;
                      },
                      controller: oldPasswordController,
                      decoration: passwordFormDecoration.copyWith(
                        labelText: 'Old Password',
                        hintText: 'Enter Your Old Password',
                        errorText:
                            checkPassword != true ? 'Not Valid Password' : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Your New Password';
                        }
                        return null;
                      },
                      controller: newPasswordController,
                      decoration: passwordFormDecoration.copyWith(
                          labelText: 'New Password',
                          hintText: 'Enter Your New Password'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Re enter your New Password';
                        } else if (value != newPasswordController.text) {
                          return 'Password is Not Matching';
                        }

                        return null;
                      },
                      decoration: passwordFormDecoration.copyWith(
                          labelText: 'Repeat Password',
                          hintText: 'Re enter Your Password'),
                    ),
                  ),
                  FlutterPwValidator(
                      controller: newPasswordController,
                      minLength: 8,
                      uppercaseCharCount: 1,
                      numericCharCount: 2,
                      specialCharCount: 1,
                      width: 400,
                      height: 150,
                      onSuccess: () {},
                      onFail: () {}),
                  const Spacer(),
                  CustomButton(
                    widthPercentage: 0.7,
                    label: "Save Changes",
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        checkPassword =
                            await AuthenticationRepository.checkOldPassword(
                                FirebaseAuth.instance.currentUser!.email!,
                                oldPasswordController.text);
                        setState(() {});
                        if (checkPassword == true) {
                          await AuthenticationRepository.updateNewPassword(
                                  newPasswordController.text.trim())
                              .whenComplete(() {
                            formKey.currentState!.reset();
                            newPasswordController.clear();
                            oldPasswordController.clear();
                            MyMessageHandler.showSnackBar(_scaffoldKey,
                                'Your Password Succesfully Updated');
                            Future.delayed(const Duration(seconds: 3))
                                .whenComplete(() {
                              Navigator.pop(context);
                            });
                          });
                        } else {
                          print('password no t valid');
                        }
                      } else {
                        print('Form Not Valid');
                      }
                    },
                    color: Theme.of(context).colorScheme.secondary,
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

var passwordFormDecoration = InputDecoration(
  labelText: 'Full Name',
  hintText: 'Enter Your Full Name',
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.teal, width: 1),
      borderRadius: BorderRadius.circular(6)),
  focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.tealAccent, width: 1),
      borderRadius: BorderRadius.circular(6)),
);
