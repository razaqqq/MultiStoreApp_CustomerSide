import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:multi_store_app_customer/auth/customer_login.dart';
import 'package:multi_store_app_customer/auth/customer_signup.dart';
import 'package:multi_store_app_customer/main_screen/customer_home_screen.dart';
import 'package:multi_store_app_customer/profiders/cart_profider.dart';
import 'package:multi_store_app_customer/profiders/id_provider.dart';
import 'package:multi_store_app_customer/profiders/sql_helpers.dart';
import 'package:multi_store_app_customer/profiders/stripe_id.dart';
import 'package:multi_store_app_customer/profiders/wish_provider.dart';
import 'package:multi_store_app_customer/services/notifications_services.dart';
import 'package:provider/provider.dart';

import 'main_screen/welcome/onboarding_scrren.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
      "Customer App ///// Handling a Background Message: ${message.messageId}");
  print(
      "Customer App ///// Handling a Background Message: ${message.notification!.title}");
  print(
      "Customer App ///// Handling a Background Message: ${message.notification!.body}");
  print("Customer App ///// Handling a Background Message: ${message.data}");
  // print("Handling a Background Message: ${message.data['']}");
}

void main() async {
  print("Start the App(App Launching)");

  if (kIsWeb) {
    runApp(const MyAppWeb());
  } else if (Platform.isWindows) {
    runApp(Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('this is Widnows'),
      ),
      body: const Center(
        child: Text("Windows"),
      ),
    ));
  } else if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
    await Firebase.initializeApp();
    print('Finish Installing Firebase Settings');

    NotificationsServices.createNotificationChannelAndInitialize();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('Firebase Messaging On Background Message is Called');

    Stripe.publishableKey = stripePublishedKey;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';

    Stripe.urlScheme = 'flutterstripe';
    await Stripe.instance.applySettings();

    print("FInish Installing Stripe Setting");

    SQLHelper.getDatabase;
    print("Completed Initialize Created SQFL DATABASE");

    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => Cart()),
      ChangeNotifierProvider(create: (_) => Wish()),
      ChangeNotifierProvider(create: (_) => IdProvider())
    ], child: const MyApp()));
  } else if (Platform.isLinux) {
  } else if (Platform.isIOS) {}
}

class MyAppWeb extends StatelessWidget {
  const MyAppWeb({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        primaryColor: Colors.black,
        scaffoldBackgroundColor: const Color(0xFF121212),
        backgroundColor: const Color(0xFF121212),
        fontFamily: 'Montserrat',
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Color(0xFF1DB954),
          onSecondary: Color(0xFF1DB954),
          error: Colors.red,
          onError: Colors.red,
          background: Colors.black,
          onBackground: Colors.black,
          surface: Colors.black,
          onSurface: Colors.black,
        ),
        iconTheme: const IconThemeData().copyWith(color: Colors.white),
        textTheme: TextTheme(
            displayMedium: const TextStyle(
                color: Colors.white,
                fontSize: 32.0,
                fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(
                color: Colors.grey[300],
                fontSize: 12.0,
                fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(
                color: Colors.grey[400],
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0),
            bodyMedium: TextStyle(color: Colors.grey[300], letterSpacing: 1.0)),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("This Is Web"),
        ),
        body: Center(
          child: Text("This is Web"),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: Colors.white),
        fontFamily: 'Montserrat',
        colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Colors.white,
            onPrimary: Colors.white,
            secondary: Color.fromRGBO(0, 173, 181, 1),
            onSecondary: Color.fromRGBO(0, 173, 181, 1),
            error: Colors.red,
            onError: Colors.red,
            background: Colors.white,
            onBackground: Colors.white,
            surface: Colors.white,
            onSurface: Colors.white),
        iconTheme: const IconThemeData().copyWith(color: Colors.black),
        textTheme: const TextTheme(
            displayLarge: TextStyle(
                color: Colors.black,
                fontSize: 32.0,
                fontWeight: FontWeight.bold),
            displayMedium: TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            headlineLarge: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            headlineMedium: TextStyle(
                color: Colors.black,
                fontSize: 12.0,
                fontWeight: FontWeight.w500),
            displaySmall: TextStyle(
                color: Colors.red, fontSize: 16.0, fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0),
            bodyMedium: TextStyle(
                color: Colors.black, fontSize: 14.0, letterSpacing: 1.0)),
      ),
      darkTheme: ThemeData(
        appBarTheme:
            const AppBarTheme(backgroundColor: Color.fromRGBO(34, 40, 49, 1)),
        fontFamily: 'Montserrat',
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color.fromRGBO(34, 40, 49, 1),
          onPrimary: Color.fromRGBO(34, 40, 49, 1),
          secondary: Color.fromRGBO(0, 171, 181, 1),
          onSecondary: Color.fromRGBO(0, 171, 181, 1),
          error: Colors.red,
          onError: Colors.red,
          background: Color.fromRGBO(57, 62, 70, 1),
          onBackground: Color.fromRGBO(57, 62, 70, 1),
          surface: Color.fromRGBO(34, 40, 49, 1),
          onSurface: Color.fromRGBO(34, 40, 49, 1),
        ),
        iconTheme: const IconThemeData().copyWith(color: Colors.white),
        textTheme: const TextTheme(
            displayLarge: TextStyle(
                color: Colors.black,
                fontSize: 32.0,
                fontWeight: FontWeight.bold),
            displayMedium: TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            headlineLarge: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            headlineMedium: TextStyle(
                color: Colors.black,
                fontSize: 12.0,
                fontWeight: FontWeight.w500),
            displaySmall: TextStyle(
                color: Colors.red, fontSize: 16.0, fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0),
            bodyMedium: TextStyle(
                color: Colors.black, fontSize: 14.0, letterSpacing: 1.0)),
      ),
      initialRoute: '/onboarding_screen',
      routes: {
        '/onboarding_screen': (context) => const OnBoardingScreen(),
        '/customer_home': (context) => const CustomerHomeScreen(),
        '/customer_signup': (context) => const CustomerSignUp(),
        '/customer_login': (context) => const CustomerLogin(),
      },
    );
  }
}
