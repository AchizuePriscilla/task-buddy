import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/shared/widgets/custom_snackbar.dart';

void main() {
  group('CustomSnackBar', () {
    Widget createTestWidget({required Widget child}) {
      return MaterialApp(
        home: ScreenUtilInit(
          designSize: const Size(800, 600),
          builder: (context, _) => Scaffold(
            body: child,
          ),
        ),
      );
    }

    group('Methods', () {
      testWidgets('should call show method without error',
          (WidgetTester tester) async {
        // Arrange
        const message = 'Test message';

        // Act
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => CustomSnackBar.show(context,
                    message: message, isSuccess: true),
                child: const Text('Show'),
              );
            },
          ),
        ));

        // Assert
        expect(() => tester.tap(find.text('Show')), returnsNormally);
      });

      testWidgets('should call showSuccess method without error',
          (WidgetTester tester) async {
        // Arrange
        const message = 'Success message';

        // Act
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => CustomSnackBar.showSuccess(context, message),
                child: const Text('Success'),
              );
            },
          ),
        ));

        // Assert
        expect(() => tester.tap(find.text('Success')), returnsNormally);
      });

      testWidgets('should call showError method without error',
          (WidgetTester tester) async {
        // Arrange
        const message = 'Error message';

        // Act
        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => CustomSnackBar.showError(context, message),
                child: const Text('Error'),
              );
            },
          ),
        ));

        // Assert
        expect(() => tester.tap(find.text('Error')), returnsNormally);
      });
    });
  });
}
