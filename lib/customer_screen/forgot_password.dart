import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/profiders/authentication_repository.dart';
import 'package:multi_store_app_customer/widgets/appbar_widgets.dart';
import 'package:multi_store_app_customer/widgets/auth_widget.dart';
import 'package:multi_store_app_customer/widgets/yellow_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const AppBarBackButton(
          color: Colors.black,
        ),
        title: const AppBarTitle(title: 'Forgot Password?'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'To Reset Your Password',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 1.2,
                    fontFamily: 'acme'),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Please Enter Your Email Address and Click on the Button Below',
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 1.2,
                    fontFamily: 'acme'),
              ),
              Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Your Email';
                          } else if (!value.isValidEmail()) {
                            return 'In Valid Email Address';
                          } else if (value.isValidEmail()) {
                            return null;
                          }
                          return null;
                        },
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            hintText: 'Enter Your Email',
                            labelText: 'Email Address',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.purple,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(6)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.deepPurpleAccent, width: 2),
                                borderRadius: BorderRadius.circular(6))),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomButton(
                          widthPercentage: 0.6,
                          label: 'Send Reset Password Link',
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await AuthenticationRepository.forgotPassword(
                                  emailController.text);
                            } else {
                              print('form not valid');
                            }
                          },
                          color: Theme.of(context).colorScheme.secondary)
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
