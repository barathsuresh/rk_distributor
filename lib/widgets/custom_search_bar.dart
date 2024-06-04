import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/services/theme_service.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function(String) onChanged;
  final Function() onClear;

  CustomSearchBar({
    required this.searchController,
    required this.searchFocusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final ThemeService themeService = Get.find();
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    isDarkMode = themeService.isDarkMode.value;
    widget.searchController.addListener(_updateClearIconVisibility);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_updateClearIconVisibility);
    super.dispose();
  }

  void _updateClearIconVisibility() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(25.0),
      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
      child: TextField(
        controller: widget.searchController,
        focusNode: widget.searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search users...',
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          suffixIcon: widget.searchController.text.isEmpty
              ? SizedBox()
              : IconButton(
            icon: Icon(
              Icons.clear,
              color: isDarkMode
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
            onPressed: () {
              widget.searchController.clear();
              widget.onClear();
              _updateClearIconVisibility(); // To update the clear icon visibility immediately
            },
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          contentPadding: EdgeInsets.all(0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.grey.shade800,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
