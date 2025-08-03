import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/features/task_management/presentation/screens/home_screen.dart';
import 'package:task_buddy/shared/localization/strings.dart';
import 'package:task_buddy/shared/theme/app_theme.dart';
import 'package:task_buddy/shared/data/local/database/hive_database_service.dart';
import 'package:task_buddy/shared/domain/providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = HiveDatabaseService();
  await database.initialize();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const MyApp(),
    ),
  );
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
