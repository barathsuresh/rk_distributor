import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDialogBox extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;

  const CustomDialogBox({
    Key? key,
    required this.title,
    required this.content,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: GoogleFonts.roboto(),
      ),
      content: Text(
        content,
        style: GoogleFonts.roboto(),
      ),
      actions: actions,
    );
  }
}
