import 'package:flutter_test/flutter_test.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/shared/globals.dart';

void main() {
  group('Priority Enum', () {
    group('displayName', () {
      test('should return correct display names for all priorities', () {
        // Assert
        expect(Priority.low.displayName, isNotEmpty);
        expect(Priority.medium.displayName, isNotEmpty);
        expect(Priority.high.displayName, isNotEmpty);
        expect(Priority.urgent.displayName, isNotEmpty);
      });

      test('should return different display names for different priorities',
          () {
        // Assert
        expect(Priority.low.displayName,
            isNot(equals(Priority.medium.displayName)));
        expect(Priority.medium.displayName,
            isNot(equals(Priority.high.displayName)));
        expect(Priority.high.displayName,
            isNot(equals(Priority.urgent.displayName)));
      });
    });

    group('color', () {
      test('should return correct colors for all priorities', () {
        // Assert
        expect(Priority.low.color, equals(AppGlobals.priorityLow));
        expect(Priority.medium.color, equals(AppGlobals.priorityMedium));
        expect(Priority.high.color, equals(AppGlobals.priorityHigh));
        expect(Priority.urgent.color, equals(AppGlobals.priorityUrgent));
      });
    });

    group('enum values', () {
      test('should have exactly 4 priority levels', () {
        // Assert
        expect(Priority.values.length, equals(4));
      });

      test('should contain all expected priority levels', () {
        // Assert
        expect(Priority.values, contains(Priority.low));
        expect(Priority.values, contains(Priority.medium));
        expect(Priority.values, contains(Priority.high));
        expect(Priority.values, contains(Priority.urgent));
      });
    });
  });
}
