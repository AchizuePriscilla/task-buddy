import 'dart:math';
import 'package:flutter/material.dart';
import 'package:task_buddy/features/task_management/domain/priority_enum.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/task_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final priorities = Priority.values;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          final randomPriority = priorities[random.nextInt(priorities.length)];
          final randomCompleted = random.nextBool();

          return TaskCard(
            title: 'Task $index',
            description: 'Description $index',
            category: 'Category $index',
            dueDate: 'Due Date $index',
            priority: randomPriority,
            isCompleted: randomCompleted,
          );
        },
      ),
    );
  }
}
