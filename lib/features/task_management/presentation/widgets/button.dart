import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/shared/theme/text_styles.dart';

class Button extends StatelessWidget {
  final String text;
  final Function onPressed;
  final bool active;
  final Color? color;
  final Color? textColor;
  final bool isOutlined;
  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.active = true,
    this.color,
    this.textColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget child =
        Text(text, style: AppTextStyles.h4.copyWith(color: textColor));
    return TextButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: isOutlined
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  )
                : BorderSide.none)),
        fixedSize: WidgetStateProperty.resolveWith((states) => Size(
              150.w,
              53.h,
            )),
        minimumSize: WidgetStateProperty.resolveWith(
          (states) => Size(
            150.w,
            53.h,
          ),
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => active
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onPrimary.withValues(alpha: .55),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              color ??
              (active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: .4)),
        ),
      ),
      child: child,
      onPressed: () => active ? onPressed() : () {},
    );
  }
}
