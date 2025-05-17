import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppColours with ChangeNotifier {
  // Singleton instance
  static final AppColours _instance = AppColours._internal();
  factory AppColours() => _instance;
  AppColours._internal();

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  final _themeStream = StreamController<bool>.broadcast();

  // Light mode base colors
  final Color _mainThemeLight = const Color(0XFF0C3F48);
  final Color _scaffoldLight = Colors.white;
  final Color _mainWhiteLight = Colors.white;
  final Color _mainBlackLight = Colors.black;
  final Color _mainGreyLight = Colors.grey;
  final Color _mainTextLight = Colors.black87;
  final Color _shadowLight = Colors.black26;
  final Color _hintTextLight = Colors.black38;
  final Color _textColour2Light = Colors.black54;
  final Color _containerShadowLight = Colors.black.withOpacity(0.05);
  final Color _valueColourLight = const Color(0xFF444444);
  final Color _google1Light = Colors.blue.shade50;
  final Color _google2Light = Colors.blue.shade200;
  final Color _google3Light = Colors.blue.shade800;
  final Color _mapFilterLight =
      Color.fromARGB(255, 160, 185, 220).withOpacity(0.8);
  final Color _navBarLight = const Color(0XFF2B3E46);
  final Color _cont1Light = Colors.grey.shade300;
  final Color _cont2Light = Colors.grey.shade100;
  final Color _cont3Light = Colors.grey.shade600;
  final Color _cont4Light = Colors.grey.shade800;
  final Color _dustbinCardShadowLight = Colors.blueGrey.withOpacity(0.2);
  Color get recievedrequestColour1Light => _isDarkMode
      ? const Color.fromARGB(255, 255, 226, 99)
      : const Color.fromARGB(255, 255, 206, 59);
  Color get recievedrequestColour2Light => _isDarkMode
      ? const Color.fromARGB(255, 255, 231, 131)
      : const Color.fromARGB(255, 255, 211, 91);
  Color get recievedrequestColour3Light => _isDarkMode
      ? const Color.fromARGB(255, 255, 212, 131)
      : const Color.fromARGB(255, 255, 192, 91);
  Color get repliedrequestColour1Light => _isDarkMode
      ? const Color.fromARGB(236, 111, 211, 211)
      : const Color.fromARGB(236, 71, 191, 191);
  Color get repliedrequestColour2Light =>
      _isDarkMode ? const Color(0xff1E7A7D) : const Color(0xff16696C);
  Color get repliedrequestColour3Light =>
      _isDarkMode ? const Color(0xffE3F6F7) : const Color(0xffC3E6E8);

  // Dark mode base colors
  final Color _mainThemeDark =
      const Color(0xFFB5D8E0); // Maintained as requested
  final Color _scaffoldDark = Colors.black; // Opposite of white
  final Color _mainWhiteDark = Colors.black; // Opposite of white
  final Color _mainBlackDark = Colors.white; // Opposite of black
  final Color _mainGreyDark = Colors.grey; // Grey stays grey
  final Color _mainTextDark = Colors.white70; // Opposite of black87
  final Color _shadowDark = Colors.white24; // Opposite of black26
  final Color _hintTextDark = Colors.white38; // Opposite of black38
  final Color _textColour2Dark = Colors.white54; // Opposite of black54
  final Color _containerShadowDark = Colors.white.withOpacity(0.05); // Opposite
  final Color _valueColourDark =
      const Color(0xFFBBBBBB); // Opposite of dark grey
  final Color _google1Dark = Colors.blue.shade900; // Opposite of light blue
  final Color _google2Dark = Colors.blue.shade800; // Opposite of medium blue
  final Color _google3Dark = Colors.blue.shade200; // Opposite of dark blue
  final Color _mapFilterDark =
      Color.fromARGB(255, 95, 70, 35).withOpacity(0.8); // Opposite hue
  final Color _navBarDark = const Color(0XFF0D1A22); // Darker version
  final Color _cont1Dark = Colors.grey.shade800; // Opposite of grey300
  final Color _cont2Dark = Colors.grey.shade900; // Opposite of grey100
  final Color _cont3Dark = Colors.grey.shade400; // Opposite of grey600
  final Color _cont4Dark = Colors.grey.shade200; // Opposite of grey800
  final Color _dustbinCardShadowDark =
      Colors.blueGrey.withOpacity(0.2); // Same opacity

// Request colors (keeping the same but switching light/dark)
  Color get recievedrequestColour1Dark => _isDarkMode
      ? const Color.fromARGB(255, 255, 206, 59) // Swapped
      : const Color.fromARGB(255, 255, 226, 99);
  Color get recievedrequestColour2Dark => _isDarkMode
      ? const Color.fromARGB(255, 255, 211, 91) // Swapped
      : const Color.fromARGB(255, 255, 231, 131);
  Color get recievedrequestColour3Dark => _isDarkMode
      ? const Color.fromARGB(255, 255, 192, 91) // Swapped
      : const Color.fromARGB(255, 255, 212, 131);
  Color get repliedrequestColour1Dark => _isDarkMode
      ? const Color.fromARGB(236, 71, 191, 191) // Swapped
      : const Color.fromARGB(236, 111, 211, 211);
  Color get repliedrequestColour2Dark => _isDarkMode
      ? const Color(0xff16696C)
      : const Color(0xff1E7A7D); // Swapped
  Color get repliedrequestColour3Dark => _isDarkMode
      ? const Color(0xffC3E6E8)
      : const Color(0xffE3F6F7); // Swapped

  // Getter-based colors
  Color get mainThemeColour => _isDarkMode ? _mainThemeDark : _mainThemeLight;
  Color get scaffoldColour => _isDarkMode ? _scaffoldDark : _scaffoldLight;
  Color get mainWhiteColour => _isDarkMode ? _mainWhiteDark : _mainWhiteLight;
  Color get mainBlackColour => _isDarkMode ? _mainBlackDark : _mainBlackLight;
  Color get mainGreyColour => _isDarkMode ? _mainGreyDark : _mainGreyLight;
  Color get mainTextColour => _isDarkMode ? _mainTextDark : _mainTextLight;
  Color get shadowColour => _isDarkMode ? _shadowDark : _shadowLight;
  Color get hintTextColour => _isDarkMode ? _hintTextDark : _hintTextLight;
  Color get textColour2 => _isDarkMode ? _textColour2Dark : _textColour2Light;
  Color get containerShadowColour =>
      _isDarkMode ? _containerShadowDark : _containerShadowLight;
  Color get valueColour => _isDarkMode ? _valueColourDark : _valueColourLight;
  Color get googleColour1 => _isDarkMode ? _google1Dark : _google1Light;
  Color get googleColour2 => _isDarkMode ? _google2Dark : _google2Light;
  Color get googleColour3 => _isDarkMode ? _google3Dark : _google3Light;
  Color get mapFilterColour => _isDarkMode ? _mapFilterDark : _mapFilterLight;
  Color get navBarColour => _isDarkMode ? _navBarDark : _navBarLight;
  Color get contColour1 => _isDarkMode ? _cont1Dark : _cont1Light;
  Color get contColour2 => _isDarkMode ? _cont2Dark : _cont2Light;
  Color get contColour3 => _isDarkMode ? _cont3Dark : _cont3Light;
  Color get contColour4 => _isDarkMode ? _cont4Dark : _cont4Light;
  Color get dustbinCardShadowColour =>
      _isDarkMode ? _dustbinCardShadowDark : _dustbinCardShadowLight;
  Color get repliedrequestColour3 =>
      _isDarkMode ? repliedrequestColour3Dark : repliedrequestColour3Light;
  Color get repliedrequestColour2 =>
      _isDarkMode ? repliedrequestColour2Dark : repliedrequestColour2Light;
  Color get repliedrequestColour1 =>
      _isDarkMode ? repliedrequestColour1Dark : repliedrequestColour1Light;
  Color get recievedrequestColour3 =>
      _isDarkMode ? recievedrequestColour3Dark : recievedrequestColour3Light;
  Color get recievedrequestColour2 =>
      _isDarkMode ? recievedrequestColour2Dark : recievedrequestColour2Light;
  Color get recievedrequestColour1 =>
      _isDarkMode ? recievedrequestColour1Dark : recievedrequestColour1Light;

  // Fixed colors (same in both themes)
  final Color myLocationColour1 = const Color.fromARGB(255, 0, 93, 231);
  final Color myLocationColour2 = Colors.blueAccent;
  Color dustbinCardColour1 = Colors.grey.shade700;
  Color alertsColour = Colors.orange.shade600;
  Color googleColour4 = Color.fromARGB(255, 166, 175, 255);
  Color googleColour5 = Color.fromARGB(255, 209, 219, 255);
  Color darkText = Colors.white70;
  final Color searchBarFocusColour = const Color.fromARGB(255, 75, 211, 145);
  final Color profilePageQuarista = const Color(0XFF11535B);
  final Color profilePageMembers = const Color(0XFF0E4E5A);
  final Color profilePageMembers1 = const Color(0XFF059669);
  final Color filledBinsColour = const Color(0XFFFF5733);
  final Color liveBinsColour = const Color(0XFF2ECC71);
  final Color emptyBinsColour = const Color(0XFF3498DB);
  final Color totalBinsColour = const Color(0XFFA155E7);
  final Color midBinColour = Colors.orange;
  final Color fineBinColour = Colors.yellow;
  final Color goodBinColour = Colors.green;
  final Color closedColour2 = Colors.redAccent;
  final Color openColour = const Color(0xFF035B60);
  final Color addNewPost = const Color.fromARGB(255, 19, 97, 111);
  final Color temperatureColour = Colors.pinkAccent;
  final Color humidityColour = Colors.lightGreenAccent;
  final Color gasColour1 = const Color.fromARGB(255, 150, 9, 56);
  final Color openColour2 = const Color(0xFF058F97);
  final Color darkAccent = const Color(0xFFBB86FC);
  final Color takeATrip1 = Colors.deepOrangeAccent;
  final Color takeATrip2 = Colors.orangeAccent;
  final Color takeATrip3 = Colors.greenAccent;
  final Color takeATrip4 = Colors.purple;
  final Color takeATrip5 = Colors.blueGrey;

  // Dynamic colors with dark variants
  Color get contColour5 =>
      _isDarkMode ? Colors.grey.shade800 : const Color(0xFF444444);
  Color get errorColour => _isDarkMode ? Colors.red.shade400 : Colors.red;
  Color get wellColour =>
      _isDarkMode ? Colors.green.shade400 : Colors.green.shade600;
  Color get fineColour =>
      _isDarkMode ? Colors.yellow.shade400 : Colors.yellow.shade600;
  Color get collColour =>
      _isDarkMode ? Colors.blue.shade400 : Colors.blue.shade600;
  Color get closedColour =>
      _isDarkMode ? Colors.red.shade400 : Colors.red.shade600;
  Color get requestCardColour1 =>
      _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade500;
  Color get dustbinCardRedColour1 =>
      _isDarkMode ? Colors.red.shade800 : Colors.red.shade900;
  Color get dustbinCardRedColour2 =>
      _isDarkMode ? Colors.red.shade600 : Colors.red.shade400;
  Color get dustbinCardRedColour3 =>
      _isDarkMode ? Colors.red.shade900 : Colors.red.shade700;
  Color get dustbinCardGreenColour1 => _isDarkMode
      ? const Color.fromARGB(237, 50, 200, 200)
      : const Color.fromARGB(237, 87, 233, 233);
  Color get dustbinCardGreenColour2 => _isDarkMode
      ? const Color.fromARGB(255, 3, 70, 55)
      : const Color.fromARGB(255, 5, 96, 75);
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
