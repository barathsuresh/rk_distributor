import 'package:flutter/material.dart';

class CustomBoxedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFilled;
  final Color fillColor;
  final Color borderColor;
  final Color textColor;
  final double borderRadius;

  CustomBoxedButton({
    required this.text,
    required this.onPressed,
    this.isFilled = true,
    this.fillColor = Colors.blue,
    this.borderColor = Colors.blue,
    this.textColor = Colors.white,
    this.borderRadius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3,vertical: 3),
      child: Material(
        color: isFilled ? fillColor : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Text(
              text,
              style: TextStyle(
                color: isFilled ? textColor : borderColor,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}