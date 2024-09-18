



import 'package:flutter/material.dart';




class PickUpButton extends StatelessWidget {
  const PickUpButton({super.key, required this.label, required this.onPressed, required this.width});


  final String label;
  final Function() onPressed;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width * width,
      decoration: BoxDecoration(
        color: Colors.pink.shade200, borderRadius: BorderRadius.circular(12),
      ),
      child: MaterialButton(
      onPressed: onPressed,
        child: Text(
          label, style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
