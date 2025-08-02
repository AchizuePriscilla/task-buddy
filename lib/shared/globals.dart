import 'package:flutter/material.dart';

class AppGlobals {
  AppGlobals._();

  //Config Strings
  static const String appThemeStorageKey = 'AppTheme';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);

  // Priority Colors (green to yellow to orange to red progression)
  static const Color priorityLow = Color(0xFF4FB5E9);
  static const Color priorityMedium = Color(0xFF22CD8F);
  static const Color priorityHigh = Color(0xFFEDA30F);
  static const Color priorityUrgent = Color(0xFFDE3F3F);
}
