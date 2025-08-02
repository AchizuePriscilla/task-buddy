import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/due_date_rich_text.dart';
import 'package:task_buddy/shared/localization/strings.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/button.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/custom_text_field.dart';
import 'package:task_buddy/shared/theme/text_styles.dart';

class CreateTaskScreen extends ConsumerWidget {
  CreateTaskScreen({super.key});
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        body: TaskForm(
            titleController: titleController,
            descriptionController: descriptionController));
  }
}

class TaskForm extends StatelessWidget {
  const TaskForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          CustomTextField(
            controller: titleController,
            hint: AppStrings.titleHint,
            label: AppStrings.title,
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
            child: DropdownButtonFormField(
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
              onChanged: (value) {},
            ),
          ),
          SizedBox(height: 16.h),
          //Due Date Picker
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 50)),
              );
              if (date != null) {}
            },
            child: DueDateRichText(
              iconSize: 22.sp,
              text: AppStrings.setDueDate,
            ),
          ),
          SizedBox(height: 16.h),
          //Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Button(
                text: AppStrings.cancel,
                onPressed: () {},
                color:
                    Theme.of(context).colorScheme.primary.withValues(alpha: .5),
                textColor: Theme.of(context).colorScheme.onPrimary,
              ),
              Button(
                text: AppStrings.create,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
