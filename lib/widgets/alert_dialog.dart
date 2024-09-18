




import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAlertDialog {
  static void showMyDialog(
      {required BuildContext context,
        required String title,
        required String content,
        required Function() tabYes,
        required Function() tabNo}) {
    showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: tabYes,
              child: Text("Yes", style: TextStyle(color: Theme.of(context).iconTheme.color),),
            ),
            CupertinoDialogAction(
              onPressed: tabNo,
              child: Text("No", style: TextStyle(color: Theme.of(context).iconTheme.color)),
            )
          ],
        ));
  }
}