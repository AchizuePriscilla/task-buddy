import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/shared/data/local/local_storage_service.dart';
import 'package:task_buddy/shared/domain/providers/shared_preferences_storage_service_provider.dart';
import 'package:task_buddy/shared/globals.dart';
import 'package:task_buddy/shared/theme/app_colors.dart';
import 'package:task_buddy/shared/theme/text_styles.dart';
import 'package:task_buddy/shared/theme/text_theme.dart';

final appThemeProvider = StateNotifierProvider<AppThemeModeNotifier, ThemeMode>(
  (ref) {
    final storage = ref.watch(localStorageServiceProvider);
    return AppThemeModeNotifier(storage);
  },
);

class AppThemeModeNotifier extends StateNotifier<ThemeMode> {
  final LocalStorageService storageService;

  ThemeMode currentTheme = ThemeMode.dark;

  AppThemeModeNotifier(this.storageService) : super(ThemeMode.dark) {
    getCurrentTheme();
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    storageService.set(AppGlobals.appThemeStorageKey, state.name);
  }

  void getCurrentTheme() async {
    final theme = await storageService.get(AppGlobals.appThemeStorageKey);
    final value = ThemeMode.values.byName('${theme ?? 'dark'}');
    state = value;
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.fontFamily,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.lightGrey,
        error: AppColors.error,
        surface: AppColors.black,
      ),
      cardColor: AppColors.grey,
      // backgroundColor: AppColors.black,
      scaffoldBackgroundColor: AppColors.black,
      textTheme: TextThemes.darkTextTheme,
      primaryTextTheme: TextThemes.primaryTextTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.black,
        titleTextStyle: AppTextStyles.h2,
      ),
    );
  }
}
