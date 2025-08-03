import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/features/task_management/presentation/screens/home_screen.dart';
import 'package:task_buddy/shared/localization/strings.dart';
import 'package:task_buddy/shared/theme/app_theme.dart';
import 'package:task_buddy/shared/data/local/database/hive_database_service.dart';
import 'package:task_buddy/shared/domain/providers/database_provider.dart';
import 'package:task_buddy/shared/data/local/shared_prefs_storage_service.dart';
import 'package:task_buddy/shared/domain/providers/shared_preferences_storage_service_provider.dart';
import 'package:task_buddy/shared/globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final database = HiveDatabaseService();
  await database.initialize();
  final storageService = SharedPrefsService();
  storageService.init();
  // Load the theme from the storage service before running the app
  final initialTheme = await loadTheme(storageService);

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        // Override storage service provider with the same instance
        localStorageServiceProvider.overrideWithValue(storageService),
        // Override the theme provider with the initial theme
        appThemeProvider.overrideWith((ref) => AppThemeModeNotifier(
              ref.read(localStorageServiceProvider),
              initialTheme: initialTheme,
            )),
      ],
      child: const MyApp(),
    ),
  );
}

Future<ThemeMode> loadTheme(SharedPrefsService storageService) async {
  final savedTheme = await storageService.get(AppGlobals.appThemeStorageKey);
  final themeString = savedTheme?.toString();
  return ThemeMode.values.byName(themeString ?? 'dark');
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeProvider);
    return ScreenUtilInit(
      designSize: const Size(430, 932), //iPhone 15 pro max design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
