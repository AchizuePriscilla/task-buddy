import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/button.dart';

void main() {
  group('Button', () {
    Widget createTestWidget({
      String text = 'Test Button',
      Function? onPressed,
      bool active = true,
      Color? color,
      Color? textColor,
      bool isOutlined = false,
      bool isLoading = false,
    }) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: Scaffold(
          body: ScreenUtilInit(
            designSize: const Size(800, 600),
            builder: (context, child) => Button(
              text: text,
              onPressed: onPressed ?? () {},
              active: active,
              color: color,
              textColor: textColor,
              isOutlined: isOutlined,
              isLoading: isLoading,
            ),
          ),
        ),
      );
    }

    testWidgets('should render without errors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Button), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should display button text', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'Save Task';

      // Act
      await tester.pumpWidget(createTestWidget(text: buttonText));

      // Assert
      expect(find.text(buttonText), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped and active',
        (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      void onPressed() {
        wasPressed = true;
      }

      // Act
      await tester.pumpWidget(createTestWidget(onPressed: onPressed));
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('should not call onPressed when inactive',
        (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      void onPressed() {
        wasPressed = true;
      }

      // Act
      await tester.pumpWidget(createTestWidget(
        onPressed: onPressed,
        active: false,
      ));
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isFalse);
    });

    testWidgets('should not call onPressed when loading',
        (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      void onPressed() {
        wasPressed = true;
      }

      // Act
      await tester.pumpWidget(createTestWidget(
        onPressed: onPressed,
        isLoading: true,
      ));
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isFalse);
    });

    testWidgets('should show loading indicator when isLoading is true',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(isLoading: true));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('should show text when isLoading is false',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(isLoading: false));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should render with outlined style',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(isOutlined: true));

      // Assert
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should render with filled style', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(isOutlined: false));

      // Assert
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should render with custom color', (WidgetTester tester) async {
      // Arrange
      const customColor = Colors.red;

      // Act
      await tester.pumpWidget(createTestWidget(color: customColor));

      // Assert
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should render with custom text color',
        (WidgetTester tester) async {
      // Arrange
      const customTextColor = Colors.white;

      // Act
      await tester.pumpWidget(createTestWidget(textColor: customTextColor));

      // Assert
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should render with proper dimensions',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should render when inactive', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(active: false));

      // Assert
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should handle empty text', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(text: ''));

      // Assert
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('should handle long text', (WidgetTester tester) async {
      // Arrange
      const longText = 'This is a very long button text that might overflow';

      // Act
      await tester.pumpWidget(createTestWidget(text: longText));

      // Assert
      expect(find.text(longText), findsOneWidget);
    });

    testWidgets('should handle multiple rapid taps gracefully',
        (WidgetTester tester) async {
      // Arrange
      int tapCount = 0;
      void onPressed() {
        tapCount++;
      }

      // Act
      await tester.pumpWidget(createTestWidget(onPressed: onPressed));

      // Tap multiple times rapidly
      await tester.tap(find.byType(TextButton));
      await tester.tap(find.byType(TextButton));
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      // Assert
      expect(tapCount, equals(3));
    });

    testWidgets('should not respond to taps when loading',
        (WidgetTester tester) async {
      // Arrange
      int tapCount = 0;
      void onPressed() {
        tapCount++;
      }

      // Act
      await tester.pumpWidget(createTestWidget(
        onPressed: onPressed,
        isLoading: true,
      ));

      // Try to tap while loading
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      // Assert
      expect(tapCount, equals(0));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle loading state transitions',
        (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      void onPressed() {
        wasPressed = true;
      }

      // Act - Start with loading state
      await tester.pumpWidget(createTestWidget(
        onPressed: onPressed,
        isLoading: true,
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Transition to non-loading state
      await tester.pumpWidget(createTestWidget(
        onPressed: onPressed,
        isLoading: false,
      ));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Button'), findsOneWidget);

      // Tap should work now
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('should handle active state transitions',
        (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      void onPressed() {
        wasPressed = true;
      }

      // Act - Start with inactive state
      await tester.pumpWidget(createTestWidget(
        onPressed: onPressed,
        active: false,
      ));
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      // Assert - Should not be pressed
      expect(wasPressed, isFalse);

      // Transition to active state
      await tester.pumpWidget(createTestWidget(
        onPressed: onPressed,
        active: true,
      ));
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      // Assert - Should be pressed now
      expect(wasPressed, isTrue);
    });
  });
}
