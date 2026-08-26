class DatabaseConstants {
  DatabaseConstants._();

  static const String databaseName = 'billing_app.db';
  static const int databaseVersion = 2;

  // Tables
  static const String tableProducts = 'products';
  static const String tableBills = 'bills';
  static const String tableBillItems = 'bill_items';
  static const String tableBusinessSettings = 'business_settings';

  // Products Columns
  static const String colProductId = 'id';
  static const String colProductName = 'name';
  static const String colProductPrice = 'price';
  static const String colProductCreatedAt = 'created_at';
  static const String colProductUpdatedAt = 'updated_at';

  // Bills Columns
  static const String colBillId = 'id';
  static const String colBillInvoiceNumber = 'invoice_number';
  static const String colBillCustomerName = 'customer_name';
  static const String colBillCustomerPhone = 'customer_phone';
  static const String colBillSubtotal = 'subtotal';
  static const String colBillDiscountPercent = 'discount_percent';
  static const String colBillDiscountAmount = 'discount_amount';
  static const String colBillTaxPercent = 'tax_percent';
  static const String colBillTaxAmount = 'tax_amount';
  static const String colBillTotalAmount = 'total_amount';
  static const String colBillIsTotalEdited = 'is_total_edited';
  static const String colBillCreatedAt = 'created_at';
  static const String colBillUpdatedAt = 'updated_at';

  // Bill Items Columns
  static const String colBillItemId = 'id';
  static const String colBillItemBillId = 'bill_id';
  static const String colBillItemProductName = 'product_name';
  static const String colBillItemUnitPrice = 'unit_price';
  static const String colBillItemQuantity = 'quantity';
  static const String colBillItemTotalPrice = 'total_price';

  // Business Settings Columns
  static const String colSettingsId = 'id';
  static const String colSettingsBusinessName = 'business_name';
  static const String colSettingsPhoneNumber = 'phone_number';
  static const String colSettingsAddress = 'address';
  static const String colSettingsTaxEnabled = 'tax_enabled';
  static const String colSettingsTaxPercent = 'tax_percent';
  static const String colSettingsUpdatedAt = 'updated_at';
}
