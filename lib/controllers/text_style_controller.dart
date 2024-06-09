import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rk_distributor/services/theme_service.dart';

class TextStyleController extends GetxController {
  final ThemeService themeService = Get.find();
  final loginTextStyle = Rxn<TextStyle>();
  final errorOnUserWaitingPage = Rxn<TextStyle>();
  final appBarTextStyle = Rxn<TextStyle>();
  final listTileTextTileStyle = Rxn<TextStyle>();
  final listTileTextSubtitleStyle = Rxn<TextStyle>();
  final nothingToBeDisplayedStyle = Rxn<TextStyle>();
  final userListTileTitleStyle = Rxn<TextStyle>();
  final userListTileSubtitleStyle = Rxn<TextStyle>();
  final userProfileNameStyle = Rxn<TextStyle>();
  final userProfileEmailStyle = Rxn<TextStyle>();
  final floatingActionButtonStyle = Rxn<TextStyle>();
  final h3InAboutUserStyle = Rxn<TextStyle>();
  final italicListSubtitleStyle = Rxn<TextStyle>();
  final h2CommonStyleBold = Rxn<TextStyle>();
  final h2CommonStyleBoldRoboto = Rxn<TextStyle>();
  final bottomNavBarTexStyle = Rxn<TextStyle>();
  @override
  void onInit() {
    super.onInit();
    initializeTextStyles();
    ever(themeService.isDarkMode, (_) => initializeTextStyles());
  }

  void initializeTextStyles() {
    var isDark = themeService.isDarkMode.value;
    var textColor = isDark ? Colors.white : Colors.black;
    loginTextStyle.value = GoogleFonts.montserrat(
      color: textColor,
      fontSize: 35,
      fontWeight: FontWeight.bold,
    );
    errorOnUserWaitingPage.value = GoogleFonts.pressStart2p(
        color: isDark ? Colors.red : Colors.black, fontSize: 20);
    appBarTextStyle.value = GoogleFonts.sourceCodePro(
        color: textColor, fontSize: 20, fontWeight: FontWeight.bold);

    listTileTextTileStyle.value = GoogleFonts.roboto(
        color: textColor, fontSize: 20, fontWeight: FontWeight.bold);
    listTileTextSubtitleStyle.value =
        GoogleFonts.roboto(color: textColor);

    nothingToBeDisplayedStyle.value = GoogleFonts.roboto(color: textColor);

    userListTileTitleStyle.value =
        GoogleFonts.roboto(color: textColor, fontSize: 20,fontWeight: FontWeight.bold);
    userListTileSubtitleStyle.value = GoogleFonts.roboto(color: textColor,fontSize: 11,);

    userProfileNameStyle.value = GoogleFonts.roboto(fontSize: 25,color: textColor,fontWeight: FontWeight.bold);
    userProfileEmailStyle.value = GoogleFonts.roboto(fontSize: 10,color: textColor,fontWeight: FontWeight.w700);

    floatingActionButtonStyle.value = GoogleFonts.roboto(fontSize: 15);

    h3InAboutUserStyle.value = GoogleFonts.montserrat(fontSize: 20);

    italicListSubtitleStyle.value = GoogleFonts.roboto(color: textColor,fontStyle: FontStyle.italic);

    h2CommonStyleBold.value = GoogleFonts.montserrat(fontSize: 24,color: textColor,fontWeight: FontWeight.bold);

    h2CommonStyleBoldRoboto.value = GoogleFonts.roboto(fontSize: 18,color: textColor,fontWeight: FontWeight.bold);

    bottomNavBarTexStyle.value = GoogleFonts.roboto();
  }
}
