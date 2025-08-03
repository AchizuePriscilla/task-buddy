class AppStrings {
  AppStrings._();

  // Priority strings
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';
  static const String urgent = 'Urgent';

  // App strings
  static const String appName = 'Task Buddy';
  static const String retry = 'Retry';

  // Task strings
  static const String editTask = 'Edit Task';
  static const String createTask = 'Create Task';
  static const String create = 'Create';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String title = 'Title';
  static const String titleHint = 'Enter task title';
  static const String description = 'Description (Optional)';
  static const String descriptionHint = 'Enter task description';
  static const String priority = 'Priority';
  static const String category = 'Category';
  static const String setDueDate = 'Set Due Date';
  static const String dueWithColon = 'Due:';
  static const String done = 'Done';

  // Date strings
  static const String today = 'Today';
  static const String tomorrow = 'Tomorrow';
  static const String overdue = 'Overdue';
  static const String inDays = 'In';
  static const String days = 'days';
  //Month strings
  static const String jan = 'Jan';
  static const String feb = 'Feb';
  static const String mar = 'Mar';
  static const String apr = 'Apr';
  static const String may = 'May';
  static const String jun = 'Jun';
  static const String jul = 'Jul';
  static const String aug = 'Aug';
  static const String sep = 'Sep';
  static const String oct = 'Oct';
  static const String nov = 'Nov';
  static const String dec = 'Dec';

  // Category strings
  static const String work = 'Work';
  static const String personal = 'Personal';
  static const String study = 'Study';
  static const String home = 'Home';
  static const String health = 'Health';
  static const String finance = 'Finance';
  static const String other = 'Other';

  // Filter strings
  static const String filterTasks = 'Filter Tasks';
  static const String clearFilters = 'Clear Filters';
  static const String clearAll = 'Clear All';
  static const String apply = 'Apply';
  static const String clear = 'Clear';
  static const String all = 'All';
  static const String completed = 'Completed';
  static const String pending = 'Pending';
  static const String status = 'Status';
  static const String searchTasksHint = 'Search tasks...';

  // Home screen strings
  static const String total = 'Total';
  static const String completedWithColon = 'Completed:';
  static const String pendingWithColon = 'Pending:';
  static const String errorWithColon = 'Error:';
  static const String noTasksMatchFilters = 'No tasks match your filters';
  static const String noTasksFound = 'No tasks found. Create your first task!';
  static const String progressIndicatorTooltip = 'of tasks completed';

  // Error messages
  static const String failedToLoadTasks = 'Failed to load tasks:';
  static const String failedToCreateTask = 'Failed to create task:';
  static const String failedToUpdateTask = 'Failed to update task:';
  static const String failedToDeleteTask = 'Failed to delete task:';

  // Form validation strings
  static const String titleRequired = 'Please enter a title for your task';
  static const String descriptionRequired =
      'Please enter a description for your task';
  static const String categoryRequired =
      'Please select a category for your task';
  static const String dueDateRequired =
      'Please select a due date for your task';
  static const String dueDatePast = 'Due date cannot be in the past';
  static const String taskCreatedSuccess = 'Task created successfully!';
  static const String taskCreationFailed = 'Failed to create task:';
  static const String taskUpdatedSuccess = 'Task updated successfully!';
  static const String taskUpdateFailed = 'Failed to update task:';
  static const String markAsCompleted = 'Mark as completed';
}
