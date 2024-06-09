import 'package:flutter/material.dart';

class CustomDropdownTextField extends StatefulWidget {
  final List<String> options;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  const CustomDropdownTextField({
    Key? key,
    this.keyboardType,
    required this.options,
    required this.hintText,
    required this.controller,
  }) : super(key: key);

  @override
  _CustomDropdownTextFieldState createState() => _CustomDropdownTextFieldState();
}

class _CustomDropdownTextFieldState extends State<CustomDropdownTextField> {
  String? _selectedOption;

  void _showOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            children: widget.options.map((String option) {
              return ListTile(
                leading: Icon(Icons.category_outlined),
                title: Text(option),
                onTap: () {
                  setState(() {
                    _selectedOption = option;
                    widget.controller.text = option;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.sentences,
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(Icons.arrow_drop_down),
          onPressed: () {
            _showOptionsModal(context);
          },
        ),
      ),
    );
  }
}
