import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rk_distributor/services/theme_service.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function(String) onChanged;
  final Function onClear;
  final String? hintText;
  final TextCapitalization? textCapitalization;

  CustomSearchBar(
      {required this.searchController,
      required this.searchFocusNode,
      required this.onChanged,
      required this.onClear,
      this.hintText,
      this.textCapitalization});

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final ThemeService themeService = Get.find();

  @override
  void initState() {
    super.initState();
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
    return Obx(
      () => Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(25.0),
        color:
            themeService.isDarkMode.value ? Colors.grey.shade800 : Colors.white,
        child: TextField(
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.words,
          controller: widget.searchController,
          focusNode: widget.searchFocusNode,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Search',
            hintStyle: TextStyle(
              color: themeService.isDarkMode.value
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: themeService.isDarkMode.value
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
            suffixIcon: widget.searchController.text.isEmpty
                ? SizedBox()
                : IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: themeService.isDarkMode.value
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
            fillColor: themeService.isDarkMode.value
                ? Colors.grey.shade800
                : Colors.white,
            contentPadding: EdgeInsets.all(0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(
            color: themeService.isDarkMode.value
                ? Colors.white
                : Colors.grey.shade800,
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
