import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/shared/localization/strings.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/presentation/screens/create_task_screen.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/task_card.dart';
import 'package:task_buddy/shared/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final random = Random();
    final priorities = Priority.values;
    final categories = CategoryEnum.values;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppStrings.appName),
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              ref.read(appThemeProvider.notifier).toggleTheme();
            },
            child: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
          SizedBox(width: 10.w),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTaskScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          final randomPriority = priorities[random.nextInt(priorities.length)];
          final randomCategory = categories[random.nextInt(categories.length)];
          final randomCompleted = random.nextBool();

          return TaskCard(
            task: TaskModel(
              id: 'task_$index',
              title: 'Task $index',
              description: 'Description $index',
              category: randomCategory,
              dueDate: DateTime.now().add(Duration(days: index)),
              priority: randomPriority,
              isCompleted: randomCompleted,
            ),
          );
        },
      ),
    );
  }
}
