import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static const String defaultCurrencySymbol = '₹';

  /// Consistently round monetary values to 2 decimal places
  static double round(double value) {
    return (value * 100).round() / 100.0;
  }

  /// Formats amount to standard currency representation (e.g. ₹1,250.00 or ₹1,250)
  static String format(double amount, {String symbol = defaultCurrencySymbol, bool includeDecimals = true}) {
    final rounded = round(amount);
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: includeDecimals ? 2 : 0,
      customPattern: '$symbol#,##,##0.00',
    );
    return formatter.format(rounded);
  }

  /// Formats without currency symbol (e.g. 1250.00)
  static String formatPlain(double amount) {
    return round(amount).toStringAsFixed(2);
  }

  /// Parse double safely
  static double? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = value.replaceAll(',', '').replaceAll(defaultCurrencySymbol, '').trim();
    return double.tryParse(cleaned);
  }
}
