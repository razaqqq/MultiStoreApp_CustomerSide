import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

class IdProvider with ChangeNotifier {
  static String _customerId = '';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> documentId;
  late String docId;

  String get getData {
    return _customerId;
  }

  setCustomerId(User user) async {
    final SharedPreferences pref = await _prefs;
    pref.setString('customer_id', user.uid).whenComplete(() {
      _customerId = user.uid;
    });
    if (kDebugMode) {
      print(user.uid);
    }
    print('Customer Id Has Shaved in SharedPreferences');
    notifyListeners();
  }

  clearCustomerId() async {
    final SharedPreferences pref = await _prefs;
    pref.setString('customer_id', '').whenComplete(() {
      _customerId = '';
    });

    print('Customer Id Was Removed from SharedPreferences');

    notifyListeners();
  }

  Future<String> getDocumentId() {
    return _prefs.then((SharedPreferences sharedPreferences) {
      return sharedPreferences.getString('customer_id') ?? '';
    });

    notifyListeners();
  }

  getDocId() async {
    await getDocumentId().then((value) => _customerId = value);
    print('customerid was updated into provider');
    notifyListeners();
  }
}
