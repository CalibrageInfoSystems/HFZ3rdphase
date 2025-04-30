import 'package:flutter/material.dart';

import '../CommonUtils.dart';

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final Color color;
  final VoidCallback? onPressed;
  final double textSize;
  final Color textColor;
  final Color borderColor;
  final double radius;
  final double allPadding;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.color,
    required this.onPressed,
    this.textSize = 16.0,
    this.radius = 10.0,
    this.allPadding = 10.0,
    this.textColor = Colors.white,
    this.borderColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // minimumSize: const Size.fromHeight(33),
        padding: EdgeInsets.all(allPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: borderColor),
        ),
        backgroundColor: color,
      ),
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: 15,
          fontFamily: "Outfit",
          color: textColor,
        ),
      ),
    );
  }
}
