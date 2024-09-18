




import 'package:flutter/material.dart';

class MyMessageHandler {
  static void showSnackBar(
      var _scaffoldKey, String message
      ) {
    _scaffoldKey.currentState!.hideCurrentSnackBar();
    _scaffoldKey.currentState!.showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.teal,
        content: Text(
          message.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.white),
        )));
  }
}
