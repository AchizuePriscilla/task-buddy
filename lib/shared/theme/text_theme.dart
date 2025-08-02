import 'package:flutter/material.dart';
import 'package:task_buddy/shared/theme/app_colors.dart';
import 'package:task_buddy/shared/theme/text_styles.dart';

class TextThemes {
  /// Main text theme

  static TextTheme get textTheme {
    return TextTheme(
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.body,
      titleMedium: AppTextStyles.bodySmall,
      titleSmall: AppTextStyles.bodyExtraSmall,
      displayLarge: AppTextStyles.h1,
      displayMedium: AppTextStyles.h2,
      displaySmall: AppTextStyles.h3,
      headlineMedium: AppTextStyles.h4,
    );
  }

  /// Dark text theme

  static TextTheme get darkTextTheme {
    return TextTheme(
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColors.white),
      titleMedium: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
      titleSmall: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.white),
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.white),
      displayMedium: AppTextStyles.h2.copyWith(color: AppColors.white),
      displaySmall: AppTextStyles.h3.copyWith(color: AppColors.white),
      headlineMedium: AppTextStyles.h4.copyWith(color: AppColors.white),
    );
  }

  /// Primary text theme

  static TextTheme get primaryTextTheme {
    return TextTheme(
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColors.primary),
      titleMedium: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
      titleSmall:
          AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.primary),
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.primary),
      displayMedium: AppTextStyles.h2.copyWith(color: AppColors.primary),
      displaySmall: AppTextStyles.h3.copyWith(color: AppColors.primary),
      headlineMedium: AppTextStyles.h4.copyWith(color: AppColors.primary),
    );
  }
}
