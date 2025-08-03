import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';

/// Filter state for UI
class FilterState {
  final CategoryEnum? selectedCategory;
  final Priority? selectedPriority;
  final bool? selectedCompletionStatus;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;
  final String searchQuery;

  const FilterState({
    this.selectedCategory,
    this.selectedPriority,
    this.selectedCompletionStatus,
    this.dueDateFrom,
    this.dueDateTo,
    this.searchQuery = '',
  });

  /// Check if any filters are active
  bool get hasActiveFilters {
    return selectedCategory != null ||
        selectedPriority != null ||
        selectedCompletionStatus != null ||
        dueDateFrom != null ||
        dueDateTo != null ||
        searchQuery.isNotEmpty;
  }
}

/// Filter state notifier - handles filter changes
class FilterStateNotifier extends StateNotifier<FilterState> {
  FilterStateNotifier() : super(const FilterState());

  void setCategory(CategoryEnum? category) {
    state = FilterState(
      selectedCategory: category,
      selectedPriority: state.selectedPriority,
      selectedCompletionStatus: state.selectedCompletionStatus,
      dueDateFrom: state.dueDateFrom,
      dueDateTo: state.dueDateTo,
      searchQuery: state.searchQuery,
    );
  }

  void setPriority(Priority? priority) {
    state = FilterState(
      selectedCategory: state.selectedCategory,
      selectedPriority: priority,
      selectedCompletionStatus: state.selectedCompletionStatus,
      dueDateFrom: state.dueDateFrom,
      dueDateTo: state.dueDateTo,
      searchQuery: state.searchQuery,
    );
  }

  void setCompletionStatus(bool? isCompleted) {
    state = FilterState(
      selectedCategory: state.selectedCategory,
      selectedPriority: state.selectedPriority,
      selectedCompletionStatus: isCompleted,
      dueDateFrom: state.dueDateFrom,
      dueDateTo: state.dueDateTo,
      searchQuery: state.searchQuery,
    );
  }

  void setDateRange(DateTime? from, DateTime? to) {
    state = FilterState(
      selectedCategory: state.selectedCategory,
      selectedPriority: state.selectedPriority,
      selectedCompletionStatus: state.selectedCompletionStatus,
      dueDateFrom: from,
      dueDateTo: to,
      searchQuery: state.searchQuery,
    );
  }

  void setSearchQuery(String query) {
    state = FilterState(
      selectedCategory: state.selectedCategory,
      selectedPriority: state.selectedPriority,
      selectedCompletionStatus: state.selectedCompletionStatus,
      dueDateFrom: state.dueDateFrom,
      dueDateTo: state.dueDateTo,
      searchQuery: query,
    );
  }

  void clearFilters() {
    state = const FilterState();
  }
}

/// Provider for filter state management
final filterStateProvider =
    StateNotifierProvider<FilterStateNotifier, FilterState>((ref) {
  return FilterStateNotifier();
});
