import 'package:flutter_test/flutter_test.dart';
import 'package:basic_billiing/core/utils/invoice_number_generator.dart';

void main() {
  group('InvoiceNumberGenerator Tests', () {
    test('generates expected format INV-YYYYMMDD-XXXX', () {
      final date = DateTime(2026, 8, 26);
      expect(InvoiceNumberGenerator.generate(date, 1), 'INV-20260826-0001');
      expect(InvoiceNumberGenerator.generate(date, 42), 'INV-20260826-0042');
      expect(InvoiceNumberGenerator.generate(date, 9999), 'INV-20260826-9999');
    });

    test('extracts date string correctly', () {
      expect(
        InvoiceNumberGenerator.extractDateString('INV-20260826-0001'),
        '20260826',
      );
      expect(InvoiceNumberGenerator.extractDateString('INVALID'), isNull);
    });
  });
}
