import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NothingToBeDisplayed extends StatelessWidget {
  String? text;
  Widget? icon;
  NothingToBeDisplayed({
    this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon ?? Icon(
            Icons.error_outline,
            size: 40,
          ),
          SizedBox(
            height: 9,
          ),
          Text(text ?? "Nothing to be displayed",style: GoogleFonts.roboto(),)
        ],
      ),
    );
  }
}