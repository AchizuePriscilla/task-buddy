import 'package:flutter/material.dart';
import 'package:task_buddy/shared/theme/text_styles.dart';

/// Shared snackbar widget for consistent messaging across the app
class CustomSnackBar {
  /// Shows a snackbar with success or error styling
  static void show(
    BuildContext context, {
    required String message,
    required bool isSuccess,
  }) {
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

  /// Shows a success snackbar
  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, isSuccess: true);
  }

  /// Shows an error snackbar
  static void showError(BuildContext context, String message) {
    show(context, message: message, isSuccess: false);
  }
}
