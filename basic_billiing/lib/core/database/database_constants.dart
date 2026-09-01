class DatabaseConstants {
  DatabaseConstants._();

  static const String databaseName = 'billing_app.db';
  static const int databaseVersion = 8;

  // Tables
  static const String tableProducts = 'products';
  static const String tableBills = 'bills';
  static const String tableBillItems = 'bill_items';
  static const String tableBusinessSettings = 'business_settings';
  static const String tableOfferProducts = 'offer_products';
  static const String tableOfferGroups = 'offer_groups';

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
  static const String colBillVehicleNumber = 'vehicle_number';
  static const String colBillVehicleModel = 'vehicle_model';
  static const String colBillKm = 'km';
  static const String colBillJobCardNumber = 'job_card_no';
  static const String colBillPaymentType = 'payment_type';
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

  // Offer Products Columns
  static const String colOfferId = 'id';
  static const String colOfferGroup = 'offer_group';
  static const String colOfferProductId = 'product_id';
  static const String colOfferProductName = 'product_name';
  static const String colOfferProductPrice = 'product_price';
  static const String colOfferCreatedAt = 'created_at';

  // Offer Groups Columns
  static const String colOfferGroupId = 'group_id';
  static const String colOfferGroupName = 'name';
  static const String colOfferGroupTotalPrice = 'total_price';
  static const String colOfferGroupUpdatedAt = 'updated_at';
}
