import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swms_administration/constants/colours.dart';

class AppTextStyles {
  final TextStyle pageTitleStyleMobile = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColours().mainTextColour,
  );

  final TextStyle pageHeadlineStyleMobile = GoogleFonts.poppins(
    fontSize: 14,
    color: AppColours().textColour2,
  );

  final TextStyle subtitleStyleMobile = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  final TextStyle bodyTextStyle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColours().dustbinCardColour1,
  );

  final TextStyle buttonTextStyle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColours().mainWhiteColour,
  );

  final TextStyle smallTextStyle = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColours().mainGreyColour,
  );

  final TextStyle largeTitleStyle = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColours().mainTextColour,
  );

  final TextStyle cardTitleStyle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColours().mainTextColour,
  );

  final TextStyle cardSubtitleStyle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColours().textColour2,
  );

  final TextStyle statValueStyle = GoogleFonts.poppins(
    fontSize: 35,
    fontWeight: FontWeight.bold,
    color: AppColours().valueColour,
  );

  final TextStyle statTitleStyle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColours().mainTextColour,
  );

  final TextStyle statStatusStyle = GoogleFonts.poppins(
    fontSize: 16,
    color: AppColours().textColour2,
  );

  final TextStyle errorTextStyle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColours().errorColour,
  );

  final TextStyle hintTextStyle = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColours().requestCardColour1,
  );

  final TextStyle inputTextStyle = GoogleFonts.poppins(
    fontSize: 15,
    color: AppColours().contColour4,
  );

  final TextStyle tabLabelStyle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColours().mainTextColour,
  );

  final TextStyle tabUnselectedLabelStyle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColours().mainTextColour.withOpacity(0.6),
  );
}
