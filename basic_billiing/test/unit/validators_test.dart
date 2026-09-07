import 'package:flutter_test/flutter_test.dart';
import 'package:basic_billiing/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('validateRequired validates non-empty strings', () {
      expect(Validators.validateRequired('Milk', 'Product name'), isNull);
      expect(
        Validators.validateRequired('', 'Product name'),
        'Product name is required',
      );
      expect(
        Validators.validateRequired('   ', 'Product name'),
        'Product name is required',
      );
      expect(
        Validators.validateRequired(null, 'Product name'),
        'Product name is required',
      );
    });

    test('validatePrice checks non-negative valid numbers', () {
      expect(Validators.validatePrice('100.50'), isNull);
      expect(Validators.validatePrice('0'), isNull);
      expect(Validators.validatePrice('-5'), 'Price cannot be negative');
      expect(Validators.validatePrice('abc'), 'Please enter a valid number');
      expect(Validators.validatePrice(''), 'Price is required');
    });

    test('validatePhone checks optional phone number formatting', () {
      expect(Validators.validatePhone(''), isNull);
      expect(Validators.validatePhone(null), isNull);
      expect(Validators.validatePhone('9876543210'), isNull);
      expect(Validators.validatePhone('+91 98765 43210'), isNull);
      expect(Validators.validatePhone('123'), 'Enter a valid phone number');
    });

    test('validateIndianPhone checks 10-digit mobile numbers', () {
      expect(Validators.validateIndianPhone(''), isNull);
      expect(Validators.validateIndianPhone(null), isNull);
      expect(Validators.validateIndianPhone('9876543210'), isNull);
      expect(Validators.validateIndianPhone('+919876543210'), isNull);
      expect(Validators.validateIndianPhone('09876543210'), isNull);
      expect(
        Validators.validateIndianPhone('12345'),
        'Enter a valid 10-digit mobile number',
      );
      expect(
        Validators.validateIndianPhone('987654321000'),
        'Enter a valid 10-digit mobile number',
      );
    });

    test('validatePercentage checks 0 to max bounds', () {
      expect(Validators.validatePercentage('5'), isNull);
      expect(Validators.validatePercentage('0'), isNull);
      expect(Validators.validatePercentage('100'), isNull);
      expect(
        Validators.validatePercentage('-1'),
        'Percentage must be between 0 and 100.0',
      );
      expect(
        Validators.validatePercentage('101'),
        'Percentage must be between 0 and 100.0',
      );
      expect(Validators.validatePercentage(''), isNull);
    });
  });
}
