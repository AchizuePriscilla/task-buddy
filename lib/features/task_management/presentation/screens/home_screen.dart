import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/features/task_management/presentation/screens/create_task_screen.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/button.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/task_card.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/filter_chip_widget.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/presentation/providers/task_state_provider.dart';
import 'package:task_buddy/features/task_management/presentation/providers/filter_state_provider.dart';
import 'package:task_buddy/features/task_management/presentation/providers/computed_providers.dart';
import 'package:task_buddy/shared/localization/strings.dart';
import 'package:task_buddy/shared/theme/text_styles.dart';
import 'package:task_buddy/shared/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasAttemptedLoad = false;

  @override
  void initState() {
    super.initState();
    // Load tasks after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasksIfNeeded();
    });
  }

  void _loadTasksIfNeeded() {
    if (!_hasAttemptedLoad) {
      _hasAttemptedLoad = true;
      final taskState = ref.read(taskStateProvider);
      if (taskState.tasks.isEmpty && !taskState.isLoading) {
        ref.read(taskStateProvider.notifier).loadTasks();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildHomeContent(context);
  }

  Widget _buildHomeContent(BuildContext context) {
    // Watch the task state and computed providers
    final taskState = ref.watch(taskStateProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final taskCounts = ref.watch(taskCountsProvider);
    final hasActiveFilters = ref.watch(hasActiveFiltersProvider);
    final taskNotifier = ref.read(taskStateProvider.notifier);
    final filterNotifier = ref.read(filterStateProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppStrings.appName),
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          // Theme toggle
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
          SizedBox(width: 15.w),
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
      body: Column(
        children: [
          // Search bar and filter button
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => filterNotifier.setSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: AppStrings.searchTasksHint,
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Filter button
                InkWell(
                  onTap: () {
                    _showFilterBottomSheet(context, ref);
                  },
                  child: Container(
                    height: 55.h,
                    width: 55.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            hasActiveFilters
                                ? Icons.filter_list
                                : Icons.filter_list_outlined,
                            color: hasActiveFilters
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                        if (hasActiveFilters)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${ref.watch(filteredTasksProvider).length}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onError,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Task statistics
          if (taskCounts.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${AppStrings.total}: ${taskCounts['total'] ?? 0}',
                  style: AppTextStyles.body,
                ),
                SizedBox(width: 16.w),
                Text(
                  '${AppStrings.completedWithColon} ${taskCounts['completed'] ?? 0}',
                  style: AppTextStyles.body,
                ),
                SizedBox(width: 16.w),
                Text(
                  '${AppStrings.pendingWithColon} ${taskCounts['pending'] ?? 0}',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          SizedBox(height: 8.h),
          // Task list
          Expanded(
            child: taskState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : taskState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                '${AppStrings.errorWithColon} ${taskState.error}'),
                            ElevatedButton(
                              onPressed: () => taskNotifier.loadTasks(),
                              child: const Text(AppStrings.retry),
                            ),
                          ],
                        ),
                      )
                    : filteredTasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  size: 64,
                                  color: Theme.of(context).disabledColor,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  hasActiveFilters
                                      ? AppStrings.noTasksMatchFilters
                                      : AppStrings.noTasksFound,
                                  style: AppTextStyles.h4,
                                  textAlign: TextAlign.center,
                                ),
                                if (hasActiveFilters) ...[
                                  SizedBox(height: 8.h),
                                  TextButton(
                                    onPressed: () =>
                                        filterNotifier.clearFilters(),
                                    child: Text(AppStrings.clearFilters),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              return TaskCard(task: filteredTasks[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(),
    );
  }
}

class _FilterBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterStateProvider);
    final filterNotifier = ref.read(filterStateProvider.notifier);

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.filterTasks,
                style: AppTextStyles.h1,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Category filter
          Text(
            AppStrings.category,
            style: AppTextStyles.h4,
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              CustomFilterChip(
                label: AppStrings.all,
                isSelected: filterState.selectedCategory == null,
                onTap: () {
                  filterNotifier.setCategory(null);
                },
              ),
              ...CategoryEnum.values.map((category) => CustomFilterChip(
                    label: category.displayName,
                    isSelected: filterState.selectedCategory == category,
                    onTap: () {
                      filterNotifier.setCategory(category);
                    },
                  )),
            ],
          ),
          SizedBox(height: 16.h),

          // Priority filter
          Text(
            AppStrings.priority,
            style: AppTextStyles.h4,
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              CustomFilterChip(
                label: AppStrings.all,
                isSelected: filterState.selectedPriority == null,
                onTap: () {
                  filterNotifier.setPriority(null);
                },
              ),
              ...Priority.values.map((priority) => CustomFilterChip(
                    label: priority.displayName,
                    isSelected: filterState.selectedPriority == priority,
                    onTap: () {
                      filterNotifier.setPriority(priority);
                    },
                  )),
            ],
          ),
          SizedBox(height: 16.h),

          // Completion status filter
          Text(
            AppStrings.status,
            style: AppTextStyles.h4,
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              CustomFilterChip(
                label: AppStrings.all,
                isSelected: filterState.selectedCompletionStatus == null,
                onTap: () {
                  filterNotifier.setCompletionStatus(null);
                },
              ),
              CustomFilterChip(
                label: AppStrings.completed,
                isSelected: filterState.selectedCompletionStatus == true,
                onTap: () {
                  filterNotifier.setCompletionStatus(true);
                },
              ),
              CustomFilterChip(
                label: AppStrings.pending,
                isSelected: filterState.selectedCompletionStatus == false,
                onTap: () {
                  filterNotifier.setCompletionStatus(false);
                },
              ),
            ],
          ),
          SizedBox(height: 30.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: Button(
                  onPressed: () {
                    filterNotifier.clearFilters();
                  },
                  text: AppStrings.clearAll,
                  isOutlined: true,
                  textColor: Theme.of(context).colorScheme.primary,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Button(
                  onPressed: () => Navigator.pop(context),
                  text: AppStrings.apply,
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
