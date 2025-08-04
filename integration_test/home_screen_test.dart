import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_buddy/features/task_management/domain/repositories/task_repository.dart';
import 'package:task_buddy/features/task_management/domain/services/smart_priority_service.dart';
import 'package:task_buddy/features/task_management/domain/services/user_analytics_service.dart';
import 'package:task_buddy/features/task_management/domain/providers/task_repository_provider.dart';
import 'package:task_buddy/features/task_management/domain/providers/smart_priority_service_provider.dart';
import 'package:task_buddy/features/task_management/presentation/screens/create_task_screen.dart';
import 'package:task_buddy/features/task_management/presentation/screens/home_screen.dart';
import '../test/helpers/test_data_factory.dart';
import '../test/helpers/test_helpers.dart' as helpers;
import 'package:integration_test/integration_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Generate mocks
@GenerateMocks([
  TaskRepository,
  SmartPriorityService,
  UserAnalyticsService,
])
import 'home_screen_test.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockTaskRepository mockTaskRepository;
  late MockSmartPriorityService mockSmartPriorityService;
  late MockUserAnalyticsService mockUserAnalyticsService;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    mockSmartPriorityService = MockSmartPriorityService();
    mockUserAnalyticsService = MockUserAnalyticsService();

    // Set up default mock behaviors
    helpers.TestHelpers.setupMockTaskRepositoryWithData(
        mockTaskRepository, TestDataFactory.createTaskList());

    // Set up smart priority service mocks
    when(mockSmartPriorityService.onTaskCreated(any))
        .thenAnswer((_) => Future.value());
    when(mockSmartPriorityService.onTaskUpdated(any))
        .thenAnswer((_) => Future.value());
    when(mockSmartPriorityService.onTaskCompleted(any))
        .thenAnswer((_) => Future.value());
    when(mockSmartPriorityService.recalculatePriorities(any))
        .thenAnswer((_) => Future.value());

    // Set up analytics service mocks
    when(mockUserAnalyticsService.onTaskCreated(any))
        .thenAnswer((_) => Future.value());
    when(mockUserAnalyticsService.onTaskCompleted(any))
        .thenAnswer((_) => Future.value());
    when(mockUserAnalyticsService.onTaskUncompleted(any))
        .thenAnswer((_) => Future.value());
  });

  tearDown(() {
    reset(mockTaskRepository);
    reset(mockSmartPriorityService);
    reset(mockUserAnalyticsService);
  });

  Widget createHomeScreen() {
    return ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockTaskRepository),
        smartPriorityServiceProvider
            .overrideWithValue(mockSmartPriorityService),
        userAnalyticsServiceProvider
            .overrideWithValue(mockUserAnalyticsService),
      ],
      child: ScreenUtilInit(
        designSize: const Size(800, 600),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            theme: ThemeData.light(),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('Tapping on add task button should navigate to add task screen',
        (WidgetTester tester) async {
      // Arrange
      final testTasks = TestDataFactory.createTaskList(count: 3);
      helpers.TestHelpers.setupMockTaskRepositoryWithData(
          mockTaskRepository, testTasks);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Verify the home screen is loaded
      expect(find.text('Task Buddy'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Find and tap the add task button
      final addButton = find.byIcon(Icons.add);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Assert - Should navigate to create task screen
      expect(find.byType(CreateTaskScreen), findsOneWidget);
    });

    testWidgets('Should display task list when tasks exist',
        (WidgetTester tester) async {
      // Arrange
      final testTasks = TestDataFactory.createTaskList(count: 2);
      helpers.TestHelpers.setupMockTaskRepositoryWithData(
          mockTaskRepository, testTasks);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert - Should display tasks
      expect(find.text('Task Buddy'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Should show task statistics
      expect(find.textContaining('Total:'), findsOneWidget);
      expect(find.textContaining('Completed:'), findsOneWidget);
      expect(find.textContaining('Pending:'), findsOneWidget);
    });
  });
}
