import 'package:flutter/material.dart';
import 'package:task_buddy/shared/globals.dart';
import 'package:task_buddy/shared/localization/strings.dart';

enum Priority {
  low,
  medium,
  high,
  urgent,
}

extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.low:
        return AppStrings.low;
      case Priority.medium:
        return AppStrings.medium;
      case Priority.high:
        return AppStrings.high;
      case Priority.urgent:
        return AppStrings.urgent;
    }
  }

  Color get color {
    switch (this) {
      case Priority.low:
        return AppGlobals.priorityLow;
      case Priority.medium:
        return AppGlobals.priorityMedium;
      case Priority.high:
        return AppGlobals.priorityHigh;
      case Priority.urgent:
        return AppGlobals.priorityUrgent;
    }
  }
}
