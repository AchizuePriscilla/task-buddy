import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/extensions/datetime_extension.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/services/form_validator.dart';
import 'package:task_buddy/features/task_management/presentation/providers/task_state_provider.dart';
import 'package:task_buddy/shared/localization/strings.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/button.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/due_date_rich_text.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/custom_text_field.dart';
import 'package:task_buddy/shared/theme/text_styles.dart';
import 'package:task_buddy/shared/widgets/custom_snackbar.dart';

class EditTaskScreen extends StatelessWidget {
  const EditTaskScreen({super.key, required this.task});
  final TaskModel task;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.editTask),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.sp,
            ),
          ),
        ),
        body: TaskEditForm(task: task));
  }
}

class TaskEditForm extends ConsumerStatefulWidget {
  const TaskEditForm({super.key, required this.task});
  final TaskModel task;

  @override
  ConsumerState<TaskEditForm> createState() => _TaskEditFormState();
}

class _TaskEditFormState extends ConsumerState<TaskEditForm> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late CategoryEnum selectedCategory;
  late DateTime selectedDueDate;
  late bool isCompleted;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize form with existing task data
    titleController = TextEditingController(text: widget.task.title);
    descriptionController =
        TextEditingController(text: widget.task.description ?? '');
    selectedCategory = widget.task.category;
    selectedDueDate = widget.task.dueDate;
    isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to task state changes
    ref.listen<TaskState>(taskStateProvider, (previous, next) {
      if (previous?.error != next.error && next.error != null) {
        // Show error snackbar
        CustomSnackBar.showError(context, next.error!);
        // Clear the error after showing it
        ref.read(taskStateProvider.notifier).clearError();
      } else if (previous?.tasks.length == next.tasks.length &&
          previous?.tasks != next.tasks) {
        // Task was successfully updated (same length but different content)
        CustomSnackBar.showSuccess(context, AppStrings.taskUpdatedSuccess);
        Navigator.pop(context);
      }
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            CustomTextField(
              controller: titleController,
              hint: AppStrings.titleHint,
              label: AppStrings.title,
              validator: (value) => FormValidator.validateRequiredString(
                  value, AppStrings.titleRequired),
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: descriptionController,
              maxLines: 3,
              hint: AppStrings.descriptionHint,
              label: AppStrings.description,
            ),
            SizedBox(height: 16.h),
            // Category Picker
            SizedBox(
              height: 55.h,
              child: DropdownButtonFormField<CategoryEnum>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: AppStrings.category,
                  labelStyle: AppTextStyles.bodyLarge,
                  floatingLabelStyle: AppTextStyles.bodyLarge.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                items: CategoryEnum.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e.displayName,
                            style: AppTextStyles.bodyLarge,
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                validator: FormValidator.validateCategory,
              ),
            ),
            SizedBox(height: 16.h),
            // Completion Status
            Row(
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) {
                    setState(() {
                      isCompleted = value ?? false;
                    });
                  },
                ),
                Text(
                  AppStrings.markAsCompleted,
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Due Date Picker
            DueDateRichText(
              iconSize: 22.sp,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 50)),
                );
                if (date != null) {
                  setState(() {
                    selectedDueDate = date;
                  });
                }
              },
              onClearIconTap: () {
                setState(() {
                  selectedDueDate = DateTime.now();
                });
              },
              showIcon: true,
              text:
                  '${AppStrings.dueWithColon} ${selectedDueDate.formattedDueDate}',
            ),
            SizedBox(height: 16.h),
            // Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Button(
                  text: AppStrings.cancel,
                  active: !ref.watch(taskStateProvider).isLoading,
                  onPressed: () => Navigator.pop(context),
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: .5),
                  textColor: Theme.of(context).colorScheme.onPrimary,
                ),
                Button(
                  text: AppStrings.save,
                  active: !ref.watch(taskStateProvider).isLoading,
                  isLoading: ref.watch(taskStateProvider).isLoading,
                  onPressed: () async {
                    await _updateTask();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate due date manually since it's not a TextField
    final dueDateError = FormValidator.validateDueDate(selectedDueDate);
    if (dueDateError != null) {
      CustomSnackBar.showError(context, dueDateError);
      return;
    }

    final updatedTask = widget.task.copyWith(
      title: titleController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      category: selectedCategory,
      priority: widget.task.priority, // Keep existing priority
      dueDate: selectedDueDate,
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
    );

    await ref.read(taskStateProvider.notifier).updateTask(updatedTask);
  }
}
