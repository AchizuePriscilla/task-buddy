import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/shared/data/local/local_storage_service.dart';
import 'package:task_buddy/shared/domain/providers/shared_preferences_storage_service_provider.dart';
import 'package:task_buddy/shared/globals.dart';

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
    storageService.set(appThemeStorageKey, state.name);
  }

  void getCurrentTheme() async {
    final theme = await storageService.get(appThemeStorageKey);
    final value = ThemeMode.values.byName('${theme ?? 'dark'}');
    state = value;
  }
}
