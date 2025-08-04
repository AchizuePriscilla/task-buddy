import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/presentation/providers/filter_state_provider.dart';
import '../../helpers/test_constants.dart';

void main() {
  group('FilterState', () {
    group('hasActiveFilters', () {
      test('should return false when no filters are set', () {
        // Arrange
        const state = FilterState();

        // Act
        final result = state.hasActiveFilters;

        // Assert
        expect(result, isFalse);
      });

      test('should return true when category is set', () {
        // Arrange
        const state = FilterState(selectedCategory: CategoryEnum.work);

        // Act
        final result = state.hasActiveFilters;

        // Assert
        expect(result, isTrue);
      });

      test('should return true when priority is set', () {
        // Arrange
        const state = FilterState(selectedPriority: Priority.high);

        // Act
        final result = state.hasActiveFilters;

        // Assert
        expect(result, isTrue);
      });

      test('should return true when completion status is set', () {
        // Arrange
        const state = FilterState(selectedCompletionStatus: true);

        // Act
        final result = state.hasActiveFilters;

        // Assert
        expect(result, isTrue);
      });

      test('should return true when due date from is set', () {
        // Arrange
        final dueDate = TestConstants.defaultDueDate;
        final state = FilterState(dueDateFrom: dueDate);

        // Act
        final result = state.hasActiveFilters;

        // Assert
        expect(result, isTrue);
      });

      test('should return true when due date to is set', () {
        // Arrange
        final dueDate = TestConstants.defaultDueDate;
        final state = FilterState(dueDateTo: dueDate);

        // Act
        final result = state.hasActiveFilters;

        // Assert
        expect(result, isTrue);
      });

      test('should return true when search query is not empty', () {
        // Arrange
        const state = FilterState(searchQuery: TestConstants.defaultTaskTitle);

        // Act
        final result = state.hasActiveFilters;

        // Assert
        expect(result, isTrue);
      });

      test('should return true when multiple filters are set', () {
        // Arrange
        final state = FilterState(
          selectedCategory: CategoryEnum.work,
          selectedPriority: Priority.high,
          searchQuery: TestConstants.defaultTaskTitle,
        );

        // Act
        final result = state.hasActiveFilters;

        // Assert
        expect(result, isTrue);
      });
    });
  });

  group('FilterStateNotifier', () {
    late ProviderContainer container;
    late FilterStateNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(filterStateProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('should initialize with empty state', () {
        // Act
        final state = notifier.state;

        // Assert
        expect(state.selectedCategory, isNull);
        expect(state.selectedPriority, isNull);
        expect(state.selectedCompletionStatus, isNull);
        expect(state.dueDateFrom, isNull);
        expect(state.dueDateTo, isNull);
        expect(state.searchQuery, equals(''));
        expect(state.hasActiveFilters, isFalse);
      });
    });

    group('setCategory', () {
      test('should set category filter', () {
        // Act
        notifier.setCategory(CategoryEnum.work);

        // Assert
        expect(notifier.state.selectedCategory, equals(CategoryEnum.work));
        expect(notifier.state.hasActiveFilters, isTrue);
      });

      test('should clear category filter when null is passed', () {
        // Arrange
        notifier.setCategory(CategoryEnum.work);

        // Act
        notifier.setCategory(null);

        // Assert
        expect(notifier.state.selectedCategory, isNull);
        expect(notifier.state.hasActiveFilters, isFalse);
      });

      test('should preserve other filters when setting category', () {
        // Arrange
        notifier.setPriority(Priority.high);
        notifier.setSearchQuery('test');

        // Act
        notifier.setCategory(CategoryEnum.work);

        // Assert
        expect(notifier.state.selectedCategory, equals(CategoryEnum.work));
        expect(notifier.state.selectedPriority, equals(Priority.high));
        expect(notifier.state.searchQuery, equals('test'));
      });
    });

    group('setPriority', () {
      test('should set priority filter', () {
        // Act
        notifier.setPriority(Priority.high);

        // Assert
        expect(notifier.state.selectedPriority, equals(Priority.high));
        expect(notifier.state.hasActiveFilters, isTrue);
      });

      test('should clear priority filter when null is passed', () {
        // Arrange
        notifier.setPriority(Priority.high);

        // Act
        notifier.setPriority(null);

        // Assert
        expect(notifier.state.selectedPriority, isNull);
        expect(notifier.state.hasActiveFilters, isFalse);
      });

      test('should preserve other filters when setting priority', () {
        // Arrange
        notifier.setCategory(CategoryEnum.work);
        notifier.setSearchQuery('test');

        // Act
        notifier.setPriority(Priority.high);

        // Assert
        expect(notifier.state.selectedPriority, equals(Priority.high));
        expect(notifier.state.selectedCategory, equals(CategoryEnum.work));
        expect(notifier.state.searchQuery, equals('test'));
      });
    });

    group('setCompletionStatus', () {
      test('should set completion status filter to true', () {
        // Act
        notifier.setCompletionStatus(true);

        // Assert
        expect(notifier.state.selectedCompletionStatus, isTrue);
        expect(notifier.state.hasActiveFilters, isTrue);
      });

      test('should set completion status filter to false', () {
        // Act
        notifier.setCompletionStatus(false);

        // Assert
        expect(notifier.state.selectedCompletionStatus, isFalse);
        expect(notifier.state.hasActiveFilters, isTrue);
      });

      test('should clear completion status filter when null is passed', () {
        // Arrange
        notifier.setCompletionStatus(true);

        // Act
        notifier.setCompletionStatus(null);

        // Assert
        expect(notifier.state.selectedCompletionStatus, isNull);
        expect(notifier.state.hasActiveFilters, isFalse);
      });

      test('should preserve other filters when setting completion status', () {
        // Arrange
        notifier.setCategory(CategoryEnum.work);
        notifier.setPriority(Priority.high);

        // Act
        notifier.setCompletionStatus(true);

        // Assert
        expect(notifier.state.selectedCompletionStatus, isTrue);
        expect(notifier.state.selectedCategory, equals(CategoryEnum.work));
        expect(notifier.state.selectedPriority, equals(Priority.high));
      });
    });

    group('setDateRange', () {
      test('should set date range filters', () {
        // Arrange
        final fromDate = TestConstants.defaultDueDate;
        final toDate = TestConstants.pastDueDate;

        // Act
        notifier.setDateRange(fromDate, toDate);

        // Assert
        expect(notifier.state.dueDateFrom, equals(fromDate));
        expect(notifier.state.dueDateTo, equals(toDate));
        expect(notifier.state.hasActiveFilters, isTrue);
      });

      test('should set only from date', () {
        // Arrange
        final fromDate = TestConstants.defaultDueDate;

        // Act
        notifier.setDateRange(fromDate, null);

        // Assert
        expect(notifier.state.dueDateFrom, equals(fromDate));
        expect(notifier.state.dueDateTo, isNull);
        expect(notifier.state.hasActiveFilters, isTrue);
      });

      test('should set only to date', () {
        // Arrange
        final toDate = TestConstants.pastDueDate;

        // Act
        notifier.setDateRange(null, toDate);

        // Assert
        expect(notifier.state.dueDateFrom, isNull);
        expect(notifier.state.dueDateTo, equals(toDate));
        expect(notifier.state.hasActiveFilters, isTrue);
      });

      test('should clear date range when both dates are null', () {
        // Arrange
        notifier.setDateRange(
            TestConstants.defaultDueDate, TestConstants.pastDueDate);

        // Act
        notifier.setDateRange(null, null);

        // Assert
        expect(notifier.state.dueDateFrom, isNull);
        expect(notifier.state.dueDateTo, isNull);
        expect(notifier.state.hasActiveFilters, isFalse);
      });

      test('should preserve other filters when setting date range', () {
        // Arrange
        notifier.setCategory(CategoryEnum.work);
        notifier.setPriority(Priority.high);

        // Act
        notifier.setDateRange(
            TestConstants.defaultDueDate, TestConstants.pastDueDate);

        // Assert
        expect(
            notifier.state.dueDateFrom, equals(TestConstants.defaultDueDate));
        expect(notifier.state.dueDateTo, equals(TestConstants.pastDueDate));
        expect(notifier.state.selectedCategory, equals(CategoryEnum.work));
        expect(notifier.state.selectedPriority, equals(Priority.high));
      });
    });

    group('setSearchQuery', () {
      test('should set search query', () {
        // Act
        notifier.setSearchQuery(TestConstants.defaultTaskTitle);

        // Assert
        expect(
            notifier.state.searchQuery, equals(TestConstants.defaultTaskTitle));
        expect(notifier.state.hasActiveFilters, isTrue);
      });

      test('should clear search query when empty string is passed', () {
        // Arrange
        notifier.setSearchQuery(TestConstants.defaultTaskTitle);

        // Act
        notifier.setSearchQuery('');

        // Assert
        expect(notifier.state.searchQuery, equals(''));
        expect(notifier.state.hasActiveFilters, isFalse);
      });

      test('should preserve other filters when setting search query', () {
        // Arrange
        notifier.setCategory(CategoryEnum.work);
        notifier.setPriority(Priority.high);

        // Act
        notifier.setSearchQuery(TestConstants.defaultTaskTitle);

        // Assert
        expect(
            notifier.state.searchQuery, equals(TestConstants.defaultTaskTitle));
        expect(notifier.state.selectedCategory, equals(CategoryEnum.work));
        expect(notifier.state.selectedPriority, equals(Priority.high));
      });
    });

    group('clearFilters', () {
      test('should clear all filters', () {
        // Arrange
        notifier.setCategory(CategoryEnum.work);
        notifier.setPriority(Priority.high);
        notifier.setCompletionStatus(true);
        notifier.setDateRange(
            TestConstants.defaultDueDate, TestConstants.pastDueDate);
        notifier.setSearchQuery(TestConstants.defaultTaskTitle);

        // Act
        notifier.clearFilters();

        // Assert
        expect(notifier.state.selectedCategory, isNull);
        expect(notifier.state.selectedPriority, isNull);
        expect(notifier.state.selectedCompletionStatus, isNull);
        expect(notifier.state.dueDateFrom, isNull);
        expect(notifier.state.dueDateTo, isNull);
        expect(notifier.state.searchQuery, equals(''));
        expect(notifier.state.hasActiveFilters, isFalse);
      });

      test('should reset to initial state', () {
        // Arrange
        notifier.setCategory(CategoryEnum.work);

        // Act
        notifier.clearFilters();

        // Assert
        final initialState = FilterState();
        expect(notifier.state.selectedCategory,
            equals(initialState.selectedCategory));
        expect(notifier.state.selectedPriority,
            equals(initialState.selectedPriority));
        expect(notifier.state.selectedCompletionStatus,
            equals(initialState.selectedCompletionStatus));
        expect(notifier.state.dueDateFrom, equals(initialState.dueDateFrom));
        expect(notifier.state.dueDateTo, equals(initialState.dueDateTo));
        expect(notifier.state.searchQuery, equals(initialState.searchQuery));
      });
    });

    group('State Transitions', () {
      test('should maintain state immutability', () {
        // Arrange
        final initialState = notifier.state;

        // Act
        notifier.setCategory(CategoryEnum.work);

        // Assert
        expect(notifier.state, isNot(same(initialState)));
        expect(initialState.selectedCategory, isNull);
        expect(notifier.state.selectedCategory, equals(CategoryEnum.work));
      });

      test('should handle multiple rapid state changes', () {
        // Act
        notifier.setCategory(CategoryEnum.work);
        notifier.setPriority(Priority.high);
        notifier.setCompletionStatus(true);
        notifier.setSearchQuery(TestConstants.defaultTaskTitle);

        // Assert
        expect(notifier.state.selectedCategory, equals(CategoryEnum.work));
        expect(notifier.state.selectedPriority, equals(Priority.high));
        expect(notifier.state.selectedCompletionStatus, isTrue);
        expect(
            notifier.state.searchQuery, equals(TestConstants.defaultTaskTitle));
        expect(notifier.state.hasActiveFilters, isTrue);
      });
    });
  });
}
