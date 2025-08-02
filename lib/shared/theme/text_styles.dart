import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  static const String fontFamily = 'Helvetica';

  /// Text styles for body
  static TextStyle bodyLarge = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle body = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w300,
  );

  static TextStyle bodyExtraSmall = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w300,
  );

  /// Text styles for heading

  static TextStyle h1 = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
  );

  static TextStyle h2 = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
  );

  static TextStyle h3 = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle h4 = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );
}
