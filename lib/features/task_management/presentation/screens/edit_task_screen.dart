import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/domain/extensions/datetime_extension.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/shared/localization/strings.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/button.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/due_date_rich_text.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/custom_text_field.dart';
import 'package:task_buddy/shared/theme/text_styles.dart';

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
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              CustomTextField(
                controller: TextEditingController(text: task.title),
                hint: AppStrings.titleHint,
                label: AppStrings.title,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: TextEditingController(text: task.description),
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
              //Date Picker
              DueDateRichText(
                iconSize: 22.sp,
                text:
                    '${AppStrings.dueWithColon} ${task.dueDate.formattedDueDate} ${task.isCompleted ? '(${AppStrings.done}✅) ' : ''}',
                color: task.isCompleted ? null : task.priority.color,
                showIcon: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: task.dueDate,
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365 * 50)),
                  );
                  if (date != null) {}
                },
              ),
              SizedBox(height: 16.h),
              //Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Button(
                    text: AppStrings.cancel,
                    onPressed: () {},
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: .5),
                    textColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Button(
                    text: AppStrings.save,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
