import 'package:flutter/material.dart';

class OlignalColor{//テーマの自作

  static const int _primaryValue = 0xFFd0d0d0;
  static const MaterialColor primaryColor = MaterialColor(
    _primaryValue,
    <int, Color>{
//      50: Color(0xFF11ff44),

      50: Color(0xFFf9f9f9),
      100: Color(0xFFf1f1f1),
      200: Color(0xFFe8e8e8),
      300: Color(0xFFdedede),
      400: Color(0xFFd7d7d7),
      500: Color(_primaryValue),
      600: Color(0xFFcbcbcb),
      700: Color(0xFFc4c4c4),
      800: Color(0xFFbebebe),
      900: Color(0xFFb3b3b3),
    },
  );

  static const MaterialColor accentColor = MaterialColor(
    0xFF11ff44,
    <int, Color>{
//      50: Color(0xFF11ff44),

      50: Color(0xFF11ff44),
      100: Color(0xFF11ff44),
      200: Color(0xFF11ff44),
      300: Color(0xFF11ff44),
      400: Color(0xFF11ff44),
      500: Color(0xFF11ff44),
      600: Color(0xFF11ff44),
      700: Color(0xFF11ff44),
      800: Color(0xFF11ff44),
      900: Color(0xFF11ff44),
    },
  );

  }