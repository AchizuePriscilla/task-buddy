import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/presentation/providers/task_state_provider.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/task_card.dart';
import '../helpers/test_data_factory.dart';
import 'task_card_test.mocks.dart';

@GenerateMocks([TaskStateNotifier])
void main() {
  late MockTaskStateNotifier mockTaskStateNotifier;

  setUp(() {
    mockTaskStateNotifier = MockTaskStateNotifier();
    // Stub the addListener method that Riverpod uses
    when(mockTaskStateNotifier.addListener(any,
            fireImmediately: anyNamed('fireImmediately')))
        .thenReturn(() {});
  });

  tearDown(() {
    reset(mockTaskStateNotifier);
  });

  Widget createTestWidget(TaskModel task) {
    return ProviderScope(
      overrides: [
        taskStateProvider.overrideWith((ref) => mockTaskStateNotifier),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: ScreenUtilInit(
            designSize: const Size(800, 600),
            builder: (context, child) => TaskCard(task: task),
          ),
        ),
      ),
    );
  }

  group('TaskCard', () {
    testWidgets('should render without errors', (WidgetTester tester) async {
      // Arrange
      final task = TestDataFactory.createTask();

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.byType(TaskCard), findsOneWidget);
    });

    testWidgets('should display task title', (WidgetTester tester) async {
      // Arrange
      final task = TestDataFactory.createTask(
        title: 'Test Task Title',
      );

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.text('Test Task Title'), findsOneWidget);
    });

    testWidgets('should display task description', (WidgetTester tester) async {
      // Arrange
      final task = TestDataFactory.createTask(
        description: 'Test Task Description',
      );

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.text('Test Task Description'), findsOneWidget);
    });

    testWidgets('should display category name', (WidgetTester tester) async {
      // Arrange
      final task = TestDataFactory.createTask(
        category: CategoryEnum.work,
      );

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.text(CategoryEnum.work.displayName), findsOneWidget);
    });

    testWidgets('should display completed task with check icon',
        (WidgetTester tester) async {
      // Arrange
      final task = TestDataFactory.createTask(
        title: 'Completed Task',
        isCompleted: true,
      );

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.text('Completed Task'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
    testWidgets('should handle empty description gracefully',
        (WidgetTester tester) async {
      // Arrange
      final task = TestDataFactory.createTask(
        title: 'Task with no description',
        description: '',
      );

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.text('Task with no description'), findsOneWidget);
      expect(find.text(''),
          findsNothing); // Empty description should not be displayed
    });

    testWidgets('should handle null description gracefully',
        (WidgetTester tester) async {
      // Arrange
      final task = TestDataFactory.createTask(
        title: 'Task with null description',
        description: null,
      );

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.text('Task with null description'), findsOneWidget);
      expect(find.text('null'),
          findsNothing); // Null description should not be displayed
    });

    testWidgets('should handle long title gracefully',
        (WidgetTester tester) async {
      // Arrange
      final longTitle =
          'This is a very long task title that should be handled properly by the TaskCard widget without causing any layout issues or overflow problems';
      final task = TestDataFactory.createTask(title: longTitle);

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.text(longTitle), findsOneWidget);
      // The widget should handle long text without throwing overflow errors
    });

    testWidgets('should handle long description gracefully',
        (WidgetTester tester) async {
      // Arrange
      final longDescription =
          'This is a very long task description that should be handled properly by the TaskCard widget. It contains multiple sentences and should not cause any layout issues or overflow problems when displayed in the card.';
      final task = TestDataFactory.createTask(description: longDescription);

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.text(longDescription), findsOneWidget);
      // The widget should handle long text without throwing overflow errors
    });

    testWidgets('should display all required UI elements',
        (WidgetTester tester) async {
      // Arrange
      final task = TestDataFactory.createTask();

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.byType(Dismissible), findsOneWidget);
      expect(find.byType(GestureDetector), findsWidgets);
      expect(find.text(task.title), findsOneWidget);
      expect(find.text(task.description!), findsOneWidget);
      expect(find.text(task.category.displayName), findsOneWidget);
    });

    testWidgets('should maintain state during rebuilds',
        (WidgetTester tester) async {
      // Arrange
      final task = TestDataFactory.createTask();

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Rebuild the widget
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.text(task.title), findsOneWidget);
      expect(find.text(task.description!), findsOneWidget);
    });

    testWidgets('should display dismissible widget',
        (WidgetTester tester) async {
      // Arrange
      final task = TestDataFactory.createTask();

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('should display gesture detector for interactions',
        (WidgetTester tester) async {
      // Arrange
      final task = TestDataFactory.createTask();

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('should handle different priority levels',
        (WidgetTester tester) async {
      // Arrange
      final lowPriorityTask =
          TestDataFactory.createTask(priority: Priority.low);
      final mediumPriorityTask =
          TestDataFactory.createTask(priority: Priority.medium);
      final highPriorityTask =
          TestDataFactory.createTask(priority: Priority.high);
      final urgentPriorityTask =
          TestDataFactory.createTask(priority: Priority.urgent);

      // Act & Assert for Low priority
      await tester.pumpWidget(createTestWidget(lowPriorityTask));
      expect(find.text(lowPriorityTask.title), findsOneWidget);

      // Act & Assert for Medium priority
      await tester.pumpWidget(createTestWidget(mediumPriorityTask));
      expect(find.text(mediumPriorityTask.title), findsOneWidget);

      // Act & Assert for High priority
      await tester.pumpWidget(createTestWidget(highPriorityTask));
      expect(find.text(highPriorityTask.title), findsOneWidget);

      // Act & Assert for Urgent priority
      await tester.pumpWidget(createTestWidget(urgentPriorityTask));
      expect(find.text(urgentPriorityTask.title), findsOneWidget);
    });

    testWidgets('should handle all category types',
        (WidgetTester tester) async {
      // Arrange
      final categories = [
        CategoryEnum.work,
        CategoryEnum.personal,
        CategoryEnum.study,
        CategoryEnum.home,
        CategoryEnum.health,
        CategoryEnum.finance,
        CategoryEnum.other,
      ];

      for (final category in categories) {
        final task = TestDataFactory.createTask(category: category);

        // Act
        await tester.pumpWidget(createTestWidget(task));

        // Assert
        expect(find.text(task.category.displayName), findsOneWidget);
      }
    });

    testWidgets('should render without errors for various task states',
        (WidgetTester tester) async {
      // Arrange
      final testCases = [
        TestDataFactory.createTask(isCompleted: true),
        TestDataFactory.createTask(isCompleted: false),
        TestDataFactory.createTask(description: ''),
        TestDataFactory.createTask(description: null),
        TestDataFactory.createTask(dueDate: DateTime.now()),
        TestDataFactory.createTask(
            dueDate: DateTime.now().add(const Duration(days: 1))),
        TestDataFactory.createTask(
            dueDate: DateTime.now().subtract(const Duration(days: 1))),
      ];

      for (final task in testCases) {
        // Act & Assert
        await tester.pumpWidget(createTestWidget(task));
        expect(find.text(task.title), findsOneWidget);
      }
    });

    testWidgets('should display schedule icon for tasks with due dates',
        (WidgetTester tester) async {
      // Arrange
      final task = TestDataFactory.createTask(
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
      );

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('should not display schedule icon for completed tasks',
        (WidgetTester tester) async {
      // Arrange
      final task = TestDataFactory.createTask(
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isCompleted: true,
      );

      // Act
      await tester.pumpWidget(createTestWidget(task));

      // Assert
      expect(find.byIcon(Icons.schedule), findsNothing);
    });
  });
}
