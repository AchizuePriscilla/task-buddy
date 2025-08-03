import 'package:task_buddy/shared/localization/strings.dart';

extension DateTimeExtension on DateTime {
  String get formattedDate {
    const months = [
      AppStrings.jan,
      AppStrings.feb,
      AppStrings.mar,
      AppStrings.apr,
      AppStrings.may,
      AppStrings.jun,
      AppStrings.jul,
      AppStrings.aug,
      AppStrings.sep,
      AppStrings.oct,
      AppStrings.nov,
      AppStrings.dec,
    ];
    return '${months[month - 1]} ${day.toString().padLeft(2, '0')}, $year';
  }

  int get daysUntilDue {
    return difference(DateTime.now()).inDays;
  }

  bool isSameDay(DateTime dateTime) {
    return year == dateTime.year &&
        month == dateTime.month &&
        day == dateTime.day;
  }

  String get formattedDueDate {
    if (daysUntilDue < 0) {
      return AppStrings.overdue;
    } else if (daysUntilDue == 0 && isSameDay(DateTime.now())) {
      return AppStrings.today;
    } else if (daysUntilDue <= 1) {
      return AppStrings.tomorrow;
    } else if (daysUntilDue <= 7) {
      return '${AppStrings.inDays} $daysUntilDue ${AppStrings.days}';
    } else {
      return formattedDate;
    }
  }
}
