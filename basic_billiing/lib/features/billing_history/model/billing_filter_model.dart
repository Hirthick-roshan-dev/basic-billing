import '../../../core/utils/date_utils.dart';

enum DateFilterType {
  today('Today'),
  yesterday('Yesterday'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  singleDate('Select Date');

  final String label;
  const DateFilterType(this.label);
}

class BillingFilterModel {
  final DateFilterType type;
  final DateTime? selectedDate;

  const BillingFilterModel({
    this.type = DateFilterType.today,
    this.selectedDate,
  });

  ({DateTime? start, DateTime? end}) getDateRange() {
    switch (type) {
      case DateFilterType.today:
        final range = AppDateUtils.getTodayRange();
        return (start: range.start, end: range.end);
      case DateFilterType.yesterday:
        final range = AppDateUtils.getYesterdayRange();
        return (start: range.start, end: range.end);
      case DateFilterType.thisWeek:
        final range = AppDateUtils.getThisWeekRange();
        return (start: range.start, end: range.end);
      case DateFilterType.thisMonth:
        final range = AppDateUtils.getThisMonthRange();
        return (start: range.start, end: range.end);
      case DateFilterType.singleDate:
        if (selectedDate == null) return (start: null, end: null);
        return (
          start: AppDateUtils.startOfDay(selectedDate!),
          end: AppDateUtils.endOfDay(selectedDate!),
        );
    }
  }

  BillingFilterModel copyWith({DateFilterType? type, DateTime? selectedDate}) {
    return BillingFilterModel(
      type: type ?? this.type,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
