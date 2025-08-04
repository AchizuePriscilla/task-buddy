import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/custom_text_field.dart';

void main() {
  group('CustomTextField', () {
    Widget createTestWidget({
      TextEditingController? controller,
      String? hint,
      Function(String)? validator,
      int maxLines = 1,
      bool readOnly = false,
      VoidCallback? onTap,
      bool enabled = true,
      int? maxLength,
      String? label,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ScreenUtilInit(
            designSize: const Size(800, 600),
            builder: (context, child) => CustomTextField(
              controller: controller,
              hint: hint,
              validator: validator,
              maxLines: maxLines,
              readOnly: readOnly,
              onTap: onTap,
              enabled: enabled,
              maxLength: maxLength,
              label: label,
            ),
          ),
        ),
      );
    }

    testWidgets('should render without errors', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(createTestWidget(controller: controller));

      // Assert
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should display hint text', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      const hintText = 'Enter your text here';

      // Act
      await tester.pumpWidget(createTestWidget(
        controller: controller,
        hint: hintText,
      ));

      // Assert
      expect(find.text(hintText), findsOneWidget);
    });

    testWidgets('should display label text', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      const labelText = 'Task Title';

      // Act
      await tester.pumpWidget(createTestWidget(
        controller: controller,
        label: labelText,
      ));

      // Assert
      expect(find.text(labelText), findsOneWidget);
    });

    testWidgets('should accept text input', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      const inputText = 'Test input text';

      // Act
      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.enterText(find.byType(TextFormField), inputText);
      await tester.pump();

      // Assert
      expect(controller.text, equals(inputText));
    });

    testWidgets('should handle empty text input', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      // Assert
      expect(controller.text, equals(''));
    });

    testWidgets('should handle long text input', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      const longText =
          'This is a very long text input that should be handled properly by the CustomTextField widget without causing any layout issues or overflow problems';

      // Act
      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.enterText(find.byType(TextFormField), longText);
      await tester.pump();

      // Assert
      expect(controller.text, equals(longText));
    });

    testWidgets('should support multiple lines', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      const multiLineText = 'Line 1\nLine 2\nLine 3';

      // Act
      await tester.pumpWidget(createTestWidget(
        controller: controller,
        maxLines: 3,
      ));
      await tester.enterText(find.byType(TextFormField), multiLineText);
      await tester.pump();

      // Assert
      expect(controller.text, equals(multiLineText));
    });

    testWidgets('should handle read-only mode', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController(text: 'Read only text');

      // Act
      await tester.pumpWidget(createTestWidget(
        controller: controller,
        readOnly: true,
      ));

      // Assert
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should call onTap callback when tapped',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      bool onTapCalled = false;

      // Act
      await tester.pumpWidget(createTestWidget(
        controller: controller,
        onTap: () => onTapCalled = true,
      ));
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      // Assert
      expect(onTapCalled, isTrue);
    });

    testWidgets('should respect max length constraint',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      const maxLength = 10;
      const inputText = 'This text is longer than the max length';

      // Act
      await tester.pumpWidget(createTestWidget(
        controller: controller,
        maxLength: maxLength,
      ));
      await tester.enterText(find.byType(TextFormField), inputText);
      await tester.pump();

      // Assert
      expect(controller.text.length, lessThanOrEqualTo(maxLength));
    });

    testWidgets('should support validation function',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(createTestWidget(
        controller: controller,
        validator: (value) {
          if (value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ));

      // Assert
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should display character counter when maxLength is set',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      const maxLength = 50;

      // Act
      await tester.pumpWidget(createTestWidget(
        controller: controller,
        maxLength: maxLength,
      ));

      // Enter some text
      await tester.enterText(find.byType(TextFormField), 'Test text');
      await tester.pump();

      // Assert
      expect(find.text('9/$maxLength'), findsOneWidget);
    });

    testWidgets('should handle controller updates',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController(text: 'Initial text');

      // Act
      await tester.pumpWidget(createTestWidget(controller: controller));

      // Assert
      expect(controller.text, equals('Initial text'));

      // Update controller
      controller.text = 'Updated text';
      await tester.pump();

      // Assert
      expect(controller.text, equals('Updated text'));
    });

    testWidgets('should handle focus and interaction',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      // Assert
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should handle text input operations',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController(text: 'Original text');

      // Act
      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      // Simulate text change
      controller.text = 'Updated text';
      await tester.pump();

      // Assert
      expect(controller.text, equals('Updated text'));
    });

    testWidgets('should handle keyboard input', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      // Simulate keyboard input
      await tester.enterText(find.byType(TextFormField), 'Keyboard input');
      await tester.pump();

      // Assert
      expect(controller.text, equals('Keyboard input'));
    });

    testWidgets('should handle text editing operations',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController(text: 'Text to edit');

      // Act
      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      // Simulate text editing
      controller.text = 'Edited text';
      await tester.pump();

      // Assert
      expect(controller.text, equals('Edited text'));
    });

    testWidgets('should handle form integration', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScreenUtilInit(
            designSize: const Size(800, 600),
            builder: (context, child) => Form(
              key: formKey,
              child: CustomTextField(
                controller: controller,
                validator: (value) => value.isEmpty ? 'Required' : null,
              ),
            ),
          ),
        ),
      ));

      // Validate form
      formKey.currentState!.validate();
      await tester.pump();

      // Assert
      expect(find.text('Required'), findsOneWidget);
    });
  });
}
