import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/shared/theme/text_styles.dart';

class DueDateRichText extends StatelessWidget {
  const DueDateRichText({
    super.key,
    required this.iconSize,
    required this.text,
    this.textStyle,
    this.color,
    this.showIcon = false,
    this.onTap,
  });
  final double iconSize;
  final String text;
  final TextStyle? textStyle;
  final Color? color;
  final bool showIcon;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          style: textStyle ?? AppTextStyles.bodyLarge.copyWith(color: color),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.schedule,
                size: iconSize,
                color: color,
              ),
            ),
            WidgetSpan(
                child: SizedBox(width: 3.w)), // spacing between icon and text
            TextSpan(text: text),
            if (showIcon) WidgetSpan(child: SizedBox(width: 30.w)),
            if (showIcon)
              WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.clear),
                  ))
          ],
        ),
      ),
    );
  }
}
