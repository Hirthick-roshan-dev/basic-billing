import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _invoiceDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _invoiceTimeFormat = DateFormat('hh:mm a');
  static final DateFormat _fullDateFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _compactDateFormat = DateFormat('yyyyMMdd');
  static final DateFormat _isoDateFormat = DateFormat('yyyy-MM-dd');

  static String formatInvoiceDate(DateTime date) => _invoiceDateFormat.format(date);
  static String formatTime(DateTime date) => _invoiceTimeFormat.format(date);
  static String formatFull(DateTime date) => _fullDateFormat.format(date);
  static String formatCompact(DateTime date) => _compactDateFormat.format(date);
  static String formatIsoDate(DateTime date) => _isoDateFormat.format(date);

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0, 0);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999, 999);
  }

  static ({DateTime start, DateTime end}) getTodayRange() {
    final now = DateTime.now();
    return (start: startOfDay(now), end: endOfDay(now));
  }

  static ({DateTime start, DateTime end}) getYesterdayRange() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return (start: startOfDay(yesterday), end: endOfDay(yesterday));
  }

  static ({DateTime start, DateTime end}) getThisWeekRange() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return (start: startOfDay(firstDayOfWeek), end: endOfDay(now));
  }

  static ({DateTime start, DateTime end}) getThisMonthRange() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    return (start: startOfDay(firstDayOfMonth), end: endOfDay(now));
  }
}
