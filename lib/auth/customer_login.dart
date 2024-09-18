import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:multi_store_app_customer/customer_screen/forgot_password.dart';
import 'package:multi_store_app_customer/profiders/authentication_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profiders/id_provider.dart';
import '../widgets/auth_widget.dart';
import '../widgets/snackbar_widget.dart';

class CustomerLogin extends StatefulWidget {
  const CustomerLogin({super.key});

  @override
  State<CustomerLogin> createState() => _CustomerLoginState();
}

class _CustomerLoginState extends State<CustomerLogin> {


  CollectionReference customers =
      FirebaseFirestore.instance.collection('customers');

  Future<bool> checkIfDocExist(String docId) async {
    try {
      var doc = await customers.doc(docId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  setUserId(User user) {
    context.read<IdProvider>().setCustomerId(user);
  }

  bool docExist = false;

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the Authentication Flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the Auth Details from Request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a New Credential
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

    // Once Sign In, return the User Credential
    return await FirebaseAuth.instance
        .signInWithCredential(credential)
        .whenComplete(() async {
      User user = FirebaseAuth.instance.currentUser!;


      setUserId(user);



      docExist = await checkIfDocExist(user.uid);

      if (docExist == false) {
        await customers.doc(user.uid).set({
          'name': googleUser!.displayName,
          'email': googleUser.email,
          'profile_image': googleUser.photoUrl,
          'phone': '',
          'address': '',
          'cid': user.uid
        }).then(
                (value) => navigate());
      }
      else {
        navigate();
      }

    });
  }

  late String email;
  late String password;

  bool processing = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  void navigate() {
    Navigator.pushReplacementNamed(context, "/customer_home");
  }

  void logIn() async {
    setState(() {
      processing = true;
    });

    if (_formKey.currentState!.validate()) {
      try {
        print(email);
        print(password);

        await AuthenticationRepository.signInWithEmailAndPassword(
            email, password);

        AuthenticationRepository.reloadUserData();

        _formKey.currentState!.reset();


        User user = FirebaseAuth.instance.currentUser!;

        setUserId(user);




        navigate();
      } on FirebaseAuthException catch (e) {
        setState(() {
          processing = false;
        });

        MyMessageHandler.showSnackBar(_scaffoldKey, e.message.toString());
      }
    } else {
      setState(() {
        processing = false;
      });
      MyMessageHandler.showSnackBar(_scaffoldKey, "Please fill all the field");
    }
  }

  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              reverse: true,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthHeaderLabel(headerLabel: "Cus Log In"),
                      const SizedBox(
                        height: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please Enter Your Email Address";
                              } else if (value.isValidEmail() == false) {
                                return "Invalid Email";
                              } else if (value.isValidEmail() == true) {
                                return null;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              email = value;
                            },

                            keyboardType: TextInputType.emailAddress,
                            decoration: textFormDecoration.copyWith(
                                hintText: "Input Your Email Address",
                                hintStyle: TextStyle(color: Theme.of(context).iconTheme.color),
                                labelText: "Email Address"),

                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please Enter Your Password";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              password = value;
                            },
                            obscureText: !passwordVisible,
                            decoration: textFormDecoration.copyWith(
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        passwordVisible = !passwordVisible;
                                      });
                                    },
                                    icon: passwordVisible
                                        ? const Icon(
                                            Icons.visibility,
                                            color: Colors.teal,
                                          )
                                        : const Icon(
                                            Icons.visibility_off,
                                            color: Colors.teal,
                                          )),
                                labelText: "Password",
                                hintText: "Input Your Password")),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPassword(),
                                ));
                          },
                          child: Text(
                            "Forget Password ?",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).iconTheme.color
                            ),
                          )),
                      HaveAccount(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/customer_signup');
                          },
                          actionLabel: "Sign Up",
                          haveAccount: "Dont\'t Have Account? "),
                      processing == true
                          ? Center(child: const CircularProgressIndicator())
                          : AuthMainButton(
                              onPressed: () {
                                logIn();
                              },
                              mainButtonLabel: "Log In",
                            ),
                      divider(),
                      googleInButton(signInWithGoogle)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget divider() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 30),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ),
        Text(
          ' Or ',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(
          width: 80,
          child: Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        )
      ],
    ),
  );
}

Widget googleInButton(Function() signInWithGoogle) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(50, 50, 50, 20),
    child: Material(
      elevation: 3,
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(6),
      child: MaterialButton(
        onPressed: () {
          signInWithGoogle();
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              FontAwesomeIcons.google,
              color: Colors.red,
            ),
            Text(
              'Sign Up With Google',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
      ),
    ),
  );
}
