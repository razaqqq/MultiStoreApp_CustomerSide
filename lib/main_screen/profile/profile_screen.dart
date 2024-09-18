import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/customer_screen/customer_orders.dart';
import 'package:multi_store_app_customer/customer_screen/wislist_screen.dart';
import 'package:multi_store_app_customer/main_screen/cart/cart_screen.dart';
import 'package:multi_store_app_customer/profiders/authentication_repository.dart';
import 'package:multi_store_app_customer/profiders/id_provider.dart';
import 'package:multi_store_app_customer/widgets/yellow_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../customer_screen/add_address.dart';
import '../../widgets/alert_dialog.dart';
import '../../widgets/appbar_widgets.dart';

class ProfileScreen extends StatefulWidget {
  // final String documentId;

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> documentId;
  late String docId;

  clearCustomerId() {
    context.read<IdProvider>().clearCustomerId();
  }

  CollectionReference customers =
      FirebaseFirestore.instance.collection('customers');

  // CollectionReference anonymous =
  //     FirebaseFirestore.instance.collection('anonymous');

  String userAddress(Map<String, dynamic> data) {
    if (docId == '') {
      return "example: NewJersey - Usa";
    } else if (docId != '' && data['address'] == '') {
      return 'Set Your Address';
    }
    return data['address'];
  }

  @override
  void initState() {
    documentId = context.read<IdProvider>().getDocumentId();
    docId = context.read<IdProvider>().getData;

    // FirebaseAuth.instance.authStateChanges().listen(
    //   (User? user) {
    //     if (user != null) {
    //       print(user.uid);
    //       setState(() {
    //         documentId = user.uid;
    //       });
    //     } else {
    //       setState(() {
    //         documentId = null;
    //       });
    //     }
    //   },
    // );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: documentId,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Material(child: CircularProgressIndicator());
          case ConnectionState.done:
            return docId != ''
                ? userScaffold(context)
                : noUserScaffold(context);
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
        }
        return const Material(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget userScaffold(BuildContext context) {
    print(docId);
    return FutureBuilder<DocumentSnapshot>(
      future: customers.doc(docId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something Was Wrong");
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return Center(
              child: InkWell(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, "/customer_login");
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Document Doesnt Exist"),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(documentId.toString())
                    ],
                  )));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            backgroundColor:
                Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            body: Stack(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.yellow, Colors.brown])),
                ),
                CustomScrollView(slivers: [
                  SliverAppBar(
                    elevation: 0,
                    pinned: true,
                    backgroundColor: Colors.white,
                    expandedHeight: 140,
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        return FlexibleSpaceBar(
                          title: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: constraints.biggest.height <= 120 ? 1 : 0,
                            child: Text(
                              "Account",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          background: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                              Theme.of(context).colorScheme.secondary,
                              Colors.brown
                            ])),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 25, left: 30),
                              child: Row(children: [
                                data['profile_image'] == ""
                                    ? const CircleAvatar(
                                        radius: 50,
                                        backgroundImage: AssetImage(
                                            "images/inapp/guest.jpg"),
                                      )
                                    : CircleAvatar(
                                        radius: 50,
                                        backgroundImage:
                                            NetworkImage(data['profile_image']),
                                      ),
                                Padding(
                                    padding: const EdgeInsets.only(left: 25),
                                    child: Text(
                                      data['name'] == ""
                                          ? "Guest".toUpperCase()
                                          : data['name'].toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600),
                                    ))
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(children: [
                      Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  bottomLeft: Radius.circular(30),
                                ),
                              ),
                              child: TextButton(
                                child: SizedBox(
                                    height: 40,
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Center(
                                        child: Text("Cart",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)))),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CartScreen(
                                                back: AppBarBackButton(
                                                    color: Colors.black),
                                              )));
                                },
                              ),
                            ),
                            Container(
                              color: Colors.yellow,
                              child: TextButton(
                                child: SizedBox(
                                    height: 40,
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Center(
                                        child: Text(
                                      "Orders",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: Colors.black54),
                                    ))),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CustomerOrders()));
                                },
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                ),
                              ),
                              child: TextButton(
                                child: SizedBox(
                                    height: 40,
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Center(
                                        child: Text(
                                      "WhistList",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                    ))),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WishListScreen(),
                                      ));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.grey.shade300,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 150,
                              child: Image(
                                  image: AssetImage("images/inapp/logo.jpg")),
                            ),
                            const ProfileHeaderLabel(
                              headerLabel: "Account Info.",
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                height: 260,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  children: [
                                    RepeatedListTile(
                                        title: "Email Address",
                                        subTitle: data['email'] == ""
                                            ? "guest@gmail.com"
                                            : data["email"],
                                        iconData: Icons.email,
                                        onPressedFunction: () {}),
                                    const RepeatedYellowDivider(),
                                    RepeatedListTile(
                                        title: "Phone Number",
                                        subTitle: data['phone'] == ""
                                            ? "Guest Phone"
                                            : data['phone'],
                                        iconData: Icons.phone,
                                        onPressedFunction: () {}),
                                    const RepeatedYellowDivider(),
                                    RepeatedListTile(
                                      onPressedFunction: FirebaseAuth
                                              .instance.currentUser!.isAnonymous
                                          ? null
                                          : () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddAdress(),
                                                  ));
                                            },
                                      title: "Address",
                                      subTitle: userAddress(data),
                                      // subTitle: data['address'] == ""
                                      //     ? "Guest Address"
                                      //     : data['address'],
                                      iconData: Icons.location_pin,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: ProfileHeaderLabel(
                                  headerLabel: "Account Settings."),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 20, top: 10),
                              child: Container(
                                height: 260,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  children: [
                                    RepeatedListTile(
                                        title: "Edit Profile",
                                        subTitle: "Edit Your Profile Here",
                                        iconData: Icons.edit,
                                        onPressedFunction: () {}),
                                    const RepeatedYellowDivider(),
                                    RepeatedListTile(
                                        title: "ChangePassword",
                                        subTitle:
                                            "Do You Need Change You Password",
                                        iconData: Icons.lock,
                                        onPressedFunction: () {}),
                                    const RepeatedYellowDivider(),
                                    RepeatedListTile(
                                        title: "Log Out",
                                        subTitle: "Log Out From Your Account",
                                        iconData: Icons.logout,
                                        onPressedFunction: () {
                                          MyAlertDialog.showMyDialog(
                                              context: context,
                                              title: "Log Out",
                                              content: "Do You Want to Logout",
                                              tabYes: () async {
                                                AuthenticationRepository
                                                    .logOut();
                                                User user = FirebaseAuth
                                                    .instance.currentUser!;

                                                clearCustomerId();

                                                await Future.delayed(
                                                        const Duration(
                                                            microseconds: 100))
                                                    .whenComplete(() async {
                                                  ;
                                                  Navigator.pop(context);
                                                  Navigator
                                                      .pushReplacementNamed(
                                                          context,
                                                          '/welcome_screen');
                                                });
                                              },
                                              tabNo: () {
                                                Navigator.pop(context);
                                              });
                                        })
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ]),
              ],
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.teal,
          ),
        );
      },
    );
  }

  Widget noUserScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Stack(
        children: [
          Container(
            height: 230,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Theme.of(context).colorScheme.secondary,
              Colors.brown
            ])),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                centerTitle: true,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                expandedHeight: 140,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    return FlexibleSpaceBar(
                      title: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: constraints.biggest.height <= 120 ? 1 : 0,
                        child: const Text(
                          'Account',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Theme.of(context).colorScheme.secondary,
                            Colors.brown
                          ]),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 25, left: 30),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    AssetImage('images/inapp/guest.jpg'),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25),
                                    child: Text(
                                      'guest'.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(fontSize: 24),
                                    ),
                                  ),
                                  CustomButton(
                                    widthPercentage: 0.25,
                                    label: 'Login',
                                    onPressed: () {
                                      logInDialog(context);
                                    },
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  bottomLeft: Radius.circular(30)),
                            ),
                            child: TextButton(
                              child: SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Center(
                                  child: Text(
                                    "Cart",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                logInDialog(context);
                              },
                            ),
                          ),
                          Container(
                            color: Colors.yellow,
                            child: TextButton(
                              child: SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Center(
                                    child: Text("Orders",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary))),
                              ),
                              onPressed: () {},
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  bottomRight: Radius.circular(30)),
                            ),
                            child: TextButton(
                              child: SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Center(
                                  child: Text(
                                    "Whislist",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                logInDialog(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.grey.shade300,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 150,
                            child: Image(
                              image: AssetImage('images/inapp/logo.jpg'),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: ProfileHeaderLabel(
                                headerLabel: '  Account Info  '),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              height: 260,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(16)),
                              child: const Column(
                                children: [
                                  RepeatedListTile(
                                      title: 'Email Address',
                                      subTitle: 'guest@gmail.com',
                                      iconData: Icons.email),
                                  RepeatedYellowDivider(),
                                  RepeatedListTile(
                                      title: 'Phone no',
                                      subTitle: 'guest: +1111111',
                                      iconData: Icons.phone),
                                  RepeatedYellowDivider(),
                                  RepeatedListTile(
                                      title: 'Address',
                                      subTitle: 'guest: Heaven',
                                      iconData: Icons.location_pin),
                                ],
                              ),
                            ),
                          ),
                          const ProfileHeaderLabel(
                              headerLabel: '  Profile Settings  '),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              height: 260,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  RepeatedListTile(
                                      title: 'Edit Profile',
                                      subTitle: '',
                                      iconData: Icons.edit,
                                      onPressedFunction: () {
                                        logInDialog(context);
                                      }),
                                  const RepeatedYellowDivider(),
                                  RepeatedListTile(
                                    title: 'Change Password',
                                    subTitle: '',
                                    iconData: Icons.edit,
                                    onPressedFunction: () {
                                      logInDialog(context);
                                    },
                                  ),
                                  const RepeatedYellowDivider(),
                                  RepeatedListTile(
                                    title: 'Log Out',
                                    subTitle: '',
                                    iconData: Icons.logout,
                                    onPressedFunction: () {
                                      MyAlertDialog.showMyDialog(
                                          context: context,
                                          title: 'Log Out',
                                          content:
                                              'Are You Sure Want to LogOut',
                                          tabYes: () async {
                                            Navigator.pushReplacementNamed(
                                                context, '/onboarding_screen');
                                          },
                                          tabNo: () {
                                            Navigator.pop(context);
                                          });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

void logInDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text('Please Log In'),
      content: const Text('You SHould be Logged In to Take Actions'),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: const Text('Log In'),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/customer_login');
          },
        ),
      ],
    ),
  );
}

class RepeatedYellowDivider extends StatelessWidget {
  const RepeatedYellowDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Divider(
          color: Colors.yellow,
          thickness: 1,
        ));
  }
}

class RepeatedListTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData iconData;
  final Function()? onPressedFunction;

  const RepeatedListTile(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.iconData,
      this.onPressedFunction});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressedFunction,
      child: ListTile(
        title: Text(
          "${title}",
          style: const TextStyle(color: Color.fromRGBO(34, 40, 49, 1)),
        ),
        subtitle: Text(
          "${subTitle}",
          style: const TextStyle(color: Color.fromRGBO(34, 40, 49, 1)),
        ),
        leading: Icon(
          iconData,
          color: const Color.fromRGBO(34, 40, 49, 1),
        ),
      ),
    );
  }
}

class ProfileHeaderLabel extends StatelessWidget {
  final String headerLabel;

  const ProfileHeaderLabel({super.key, required this.headerLabel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 40,
            width: 50,
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
              thickness: 1,
            ),
          ),
          Text(
            '  ${headerLabel}  ',
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          SizedBox(
            height: 40,
            width: 50,
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
