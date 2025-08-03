import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/features/task_management/domain/enums/category_enum.dart';
import 'package:task_buddy/features/task_management/domain/extensions/datetime_extension.dart';
import 'package:task_buddy/features/task_management/domain/models/task_model.dart';
import 'package:task_buddy/features/task_management/domain/enums/priority_enum.dart';
import 'package:task_buddy/features/task_management/presentation/providers/task_state_provider.dart';
import 'package:task_buddy/features/task_management/presentation/screens/edit_task_screen.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/due_date_rich_text.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/priority_indicator_chip.dart';
import 'package:task_buddy/shared/localization/strings.dart';
import 'package:task_buddy/shared/theme/text_styles.dart';

class TaskCard extends ConsumerStatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
  });

  final TaskModel task;
  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  late Color cardColor;

  @override
  Widget build(BuildContext context) {
    cardColor = widget.task.isCompleted
        ? Theme.of(context).cardColor
        : widget.task.priority.color;
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTaskScreen(
                  task: widget.task,
                ),
              ));
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cardColor,
                cardColor.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.08
                        : 0.2),
              ],
              stops: [0.11, 0.11],
            ),
            borderRadius: BorderRadius.circular(10.r),
            border: Theme.of(context).brightness == Brightness.dark
                ? null
                : Border.all(
                    color: cardColor,
                    width: .2,
                  ),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: 0.w,
            vertical: 10.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completion checkbox
              Padding(
                padding: EdgeInsets.only(top: 8.h, left: 5.w),
                child: GestureDetector(
                  onTap: () => _toggleTaskCompletion(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                        color: widget.task.isCompleted
                            ? Colors.green
                            : Theme.of(context)
                                .cardColor
                                .withValues(alpha: 0.3),
                        width: .1,
                      ),
                    ),
                    width: 35.w,
                    height: 35.w,
                    child: widget.task.isCompleted
                        ? Icon(
                            Icons.check,
                            size: 20.sp,
                            color: Colors.green,
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // Task content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 5.h,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and priority chip
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.task.title,
                                style: AppTextStyles.h4.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                  decoration: widget.task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!widget.task.isCompleted) ...[
                              PriorityIndicatorChip(
                                priority: widget.task.priority,
                              ),
                            ],
                          ],
                        ),
                        // Description
                        if (widget.task.description != null &&
                            widget.task.description!.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          Text(
                            widget.task.description!,
                            softWrap: true,
                            style: AppTextStyles.body.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              decoration: widget.task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ],
                        SizedBox(height: 10.h),
                        // Category and due date
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              child: Text(
                                widget.task.category.displayName,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (!widget.task.isCompleted)
                              DueDateRichText(
                                iconSize: 16.sp,
                                color: widget.task.priority.color,
                                text:
                                    '${AppStrings.dueWithColon} ${widget.task.dueDate.formattedDueDate}',
                              ),
                          ],
                        )
                      ]),
                ),
              ),
            ],
          ),
        ));
  }

  void _toggleTaskCompletion() {
    final updatedTask = widget.task.copyWith(
      isCompleted: !widget.task.isCompleted,
      updatedAt: DateTime.now(),
    );

    ref.read(taskStateProvider.notifier).updateTask(updatedTask);
  }
}
