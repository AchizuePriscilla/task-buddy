import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/features/task_management/domain/priority_enum.dart';
import 'package:task_buddy/features/task_management/presentation/widgets/priority_indicator_chip.dart';
import 'package:task_buddy/shared/theme/text_styles.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
  });

  final String title;
  final String? description;
  final String category;
  final String dueDate;
  final Priority priority;
  final bool isCompleted;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late Color cardColor;

  @override
  Widget build(BuildContext context) {
    cardColor = widget.isCompleted
        ? Theme.of(context).cardColor
        : widget.priority.color;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cardColor,
            cardColor.withValues(alpha: 0.08),
          ],
          stops: [0.11, 0.11],
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Theme.of(context).brightness == Brightness.dark
            ? null
            : Border.all(
                color: cardColor,
                width: .5,
              ),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 10.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Completion checkbox
          Padding(
            padding: EdgeInsets.only(top: 8.h, left: 5.w),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.3),
              ),
              width: 35.w,
              height: 35.w,
              child: widget.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 20.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    )
                  : null,
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
                            widget.title,
                            style: AppTextStyles.h4.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              decoration: widget.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!widget.isCompleted) ...[
                          PriorityIndicatorChip(
                            priority: widget.priority,
                          ),
                        ],
                      ],
                    ),
                    // Description
                    if (widget.description != null &&
                        widget.description!.isNotEmpty) ...[
                      SizedBox(height: 10.h),
                      Text(
                        widget.description!,
                        softWrap: true,
                        style: AppTextStyles.body.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          decoration: widget.isCompleted
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
                            widget.category,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (!widget.isCompleted)
                          RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(
                                    Icons.schedule,
                                    size: 16.sp,
                                    color: widget.priority.color,
                                  ),
                                ),
                                WidgetSpan(
                                    child: SizedBox(
                                        width: 3
                                            .w)), // spacing between icon and text
                                TextSpan(
                                  text: widget.dueDate,
                                  style: AppTextStyles.body.copyWith(
                                    color: widget.priority.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
