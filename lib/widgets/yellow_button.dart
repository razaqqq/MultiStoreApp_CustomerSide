import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final double widthPercentage;
  final String label;
  final Function() onPressed;
  final Color color;
  const CustomButton(
      {super.key,
      required this.widthPercentage,
      required this.label,
      required this.onPressed,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 40,
        width: MediaQuery.of(context).size.width * widthPercentage ??
            widthPercentage,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(25)),
        child: MaterialButton(
          onPressed: onPressed,
          child: Text(label,
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ));
  }
}
