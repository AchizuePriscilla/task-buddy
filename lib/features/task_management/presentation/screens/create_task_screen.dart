import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/services/form_validator.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/due_date_rich_text.dart';
import 'package:task_buddy/features/task_management/presentation/providers/task_state_provider.dart';
import 'package:task_buddy/shared/localization/strings.dart';
import 'package:task_buddy/shared/theme/text_styles.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/button.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/custom_text_field.dart';

class CreateTaskScreen extends StatelessWidget {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.createTask),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.sp,
            ),
          ),
        ),
        body: TaskForm());
  }
}

class TaskForm extends ConsumerStatefulWidget {
  const TaskForm({
    super.key,
  });

  @override
  ConsumerState<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  CategoryEnum? selectedCategory;
  DateTime? selectedDueDate;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Listen to task state changes
    ref.listen<TaskState>(taskStateProvider, (previous, next) {
      if (previous?.error != next.error && next.error != null) {
        // Show error snackbar
        _showSnackBar(next.error!, isSuccess: false);
        // Clear the error after showing it
        ref.read(taskStateProvider.notifier).clearError();
      } else if (previous?.tasks.length != next.tasks.length &&
          next.tasks.length > (previous?.tasks.length ?? 0)) {
        // Task was successfully created (list got longer)
        _showSnackBar(AppStrings.taskCreatedSuccess, isSuccess: true);
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
                    selectedCategory = value;
                  });
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: FormValidator.validateCategory,
              ),
            ),
            SizedBox(height: 16.h),
            // Due Date Picker
            DueDateRichText(
              iconSize: 22.sp,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDueDate ?? DateTime.now(),
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
                  selectedDueDate = null;
                });
              },
              showIcon: selectedDueDate != null,
              text: selectedDueDate != null
                  ? '${AppStrings.dueWithColon} ${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}'
                  : AppStrings.setDueDate,
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
                  text: AppStrings.create,
                  active: !ref.watch(taskStateProvider).isLoading,
                  isLoading: ref.watch(taskStateProvider).isLoading,
                  onPressed: () async {
                    await _createTask();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate due date manually since it's not a TextField
    final dueDateError = FormValidator.validateDueDate(selectedDueDate);
    if (dueDateError != null) {
      _showSnackBar(dueDateError, isSuccess: false);
      return;
    }

    await ref.read(taskStateProvider.notifier).createTask(
          TaskModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: titleController.text.trim(),
            description: descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
            category: selectedCategory!,
            priority: Priority.low, // Default priority
            dueDate: selectedDueDate!,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.body,
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
