import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_buddy/shared/theme/text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final Function(String)? validator;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool enabled;
  final int? maxLength;
  final String? label;

  const CustomTextField(
      {super.key,
      this.controller,
      this.hint,
      this.validator,
      this.readOnly = false,
      this.maxLines = 1,
      this.onTap,
      this.enabled = true,
      this.maxLength,
      this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          maxLength: maxLength,
          onTap: onTap,
          readOnly: readOnly,
          validator: (value) {
            return validator?.call(value ?? "");
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLines: maxLines,
          enabled: enabled,
          cursorColor: Theme.of(context).colorScheme.primary,
          style: AppTextStyles.bodyLarge,
          controller: controller,
          decoration: InputDecoration(
            errorMaxLines: 2,
            hintText: hint,
            labelText: label,
            labelStyle: AppTextStyles.bodyLarge,
            floatingLabelStyle: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            hintStyle: AppTextStyles.body,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.w,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      ],
    );
  }
}
