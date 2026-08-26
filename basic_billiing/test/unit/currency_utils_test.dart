import 'package:flutter_test/flutter_test.dart';
import 'package:basic_billiing/core/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils Tests', () {
    test('round correctly rounds to 2 decimal places', () {
      expect(CurrencyUtils.round(10.1234), 10.12);
      expect(CurrencyUtils.round(10.126), 10.13);
      expect(CurrencyUtils.round(10.0), 10.0);
      expect(CurrencyUtils.round(10.555), 10.56);
      expect(CurrencyUtils.round(0.001), 0.0);
    });

    test('format formats currency with symbol and 2 decimals', () {
      expect(CurrencyUtils.format(1250.5), '₹1,250.50');
      expect(CurrencyUtils.format(100), '₹100.00');
      expect(CurrencyUtils.format(0), '₹0.00');
      expect(CurrencyUtils.format(99.99), '₹99.99');
    });

    test('formatPlain formats numbers with 2 decimals without currency symbol', () {
      expect(CurrencyUtils.formatPlain(1250.5), '1250.50');
      expect(CurrencyUtils.formatPlain(5), '5.00');
      expect(CurrencyUtils.formatPlain(0), '0.00');
    });

    test('tryParse safely parses valid strings and handles invalid', () {
      expect(CurrencyUtils.tryParse('1250.50'), 1250.50);
      expect(CurrencyUtils.tryParse('₹1,250.50'), 1250.50);
      expect(CurrencyUtils.tryParse(''), isNull);
      expect(CurrencyUtils.tryParse('abc'), isNull);
    });
  });
}
