import 'date_utils.dart';

class InvoiceNumberGenerator {
  InvoiceNumberGenerator._();

  /// Generates a standardized invoice number like INV-20260826-0001
  static String generate(DateTime date, int sequenceNumber) {
    final dateStr = AppDateUtils.formatCompact(date);
    final seqStr = sequenceNumber.toString().padLeft(4, '0');
    return 'INV-$dateStr-$seqStr';
  }

  /// Extracts date string component from invoice number
  static String? extractDateString(String invoiceNumber) {
    final parts = invoiceNumber.split('-');
    if (parts.length == 3 && parts[0] == 'INV') {
      return parts[1];
    }
    return null;
  }
}
