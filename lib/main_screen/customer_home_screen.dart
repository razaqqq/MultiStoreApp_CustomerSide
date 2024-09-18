import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/main_screen/category/category_screen.dart';
import 'package:multi_store_app_customer/main_screen/home/home_screen.dart';
import 'package:multi_store_app_customer/main_screen/minor_screen/visit_store.dart';
import 'package:multi_store_app_customer/main_screen/profile/profile_screen.dart';
import 'package:multi_store_app_customer/main_screen/store/stores_screen.dart';
import 'package:multi_store_app_customer/profiders/cart_profider.dart';
import 'package:provider/provider.dart';

import '../services/notifications_services.dart';
import 'cart/cart_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const HomeScreen(),
    const CategoryScreen(),
    const StoresScreen(),
    const CartScreen(),
    const ProfileScreen(
        // documentId: FirebaseAuth.instance.currentUser!.uid
        ),
  ];

  displayForegroundNotification() {
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Customer APP ///// Got Message Whilst in the Foreground');
      print('Customer APP ///// title = ${message.notification!.title}');
      print('Customer APP ///// body = ${message.notification!.body}');
      print('Customer APP ///// Message Data: ${message.data['key1']}');

      if (message.notification != null) {
        print(
            'Customer APP ///// Message also Contained a notification: ${message.notification}');
        NotificationsServices.displayNotifications(message);
      }
    });
  }

  Future<void> setupInteractedMessage() async {
    // Get any Message Which Caused the Applications to Open From
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'store') {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return VisitStore(
            suppId: message.data['sid'],
          );
        },
      ));
    }
  }

  @override
  void initState() {
    FirebaseMessaging.instance.getToken().then((value) {
      print('token : $value');
    });

    super.initState();

    context.read<Cart>().loadCartItemProvider();

    displayForegroundNotification();

    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Category"),
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: "Stores"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
