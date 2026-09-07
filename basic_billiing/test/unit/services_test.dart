import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:basic_billiing/core/services/admin_pass_key_service.dart';
import 'package:basic_billiing/core/services/whatsapp_service.dart';
import 'package:basic_billiing/features/billing/model/bill_item_model.dart';
import 'package:basic_billiing/features/billing/model/bill_model.dart';

void main() {
  group('AdminPassKeyService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to defaultPassKey when no pass key is configured', () async {
      final service = AdminPassKeyService();
      final key = await service.getPassKey();
      expect(key, AdminPassKeyService.defaultPassKey);
      expect(await service.verifyPassKey(AdminPassKeyService.defaultPassKey), isTrue);
      expect(await service.verifyPassKey('0000'), isFalse);
    });

    test('updates and verifies new pass key correctly', () async {
      final service = AdminPassKeyService();
      await service.setPassKey('9999');
      expect(await service.getPassKey(), '9999');
      expect(await service.verifyPassKey('9999'), isTrue);
      expect(await service.verifyPassKey('1234'), isFalse);
    });

    test('defaults admin view to false and updates accurately', () async {
      final service = AdminPassKeyService();
      expect(await service.isAdminViewEnabled(), isFalse);
      await service.setAdminViewEnabled(true);
      expect(await service.isAdminViewEnabled(), isTrue);
      await service.setAdminViewEnabled(false);
      expect(await service.isAdminViewEnabled(), isFalse);
    });
  });

  group('WhatsAppService Tests', () {
    test('toWhatsAppDigits formats phone numbers with Indian country code 91', () {
      final service = WhatsAppService();
      expect(service.toWhatsAppDigits('9876543210'), '919876543210');
      expect(service.toWhatsAppDigits('+919876543210'), '919876543210');
      expect(service.toWhatsAppDigits('+91 98765 43210'), '919876543210');
      expect(service.toWhatsAppDigits(null), '');
      expect(service.toWhatsAppDigits(''), '');
    });
  });

  group('BillModel & BillItemModel Profit & Loss Tests', () {
    test('calculates profit and loss accurately', () {
      final billProfit = BillModel(
        invoiceNumber: 'INV-001',
        createdAt: DateTime.now(),
        subtotal: 1500.0,
        totalAmount: 1500.0,
        totalPurchaseAmount: 1100.0,
        items: [],
      );

      expect(billProfit.profitOrLoss, 400.0);
      expect(billProfit.isProfit, isTrue);

      final billLoss = BillModel(
        invoiceNumber: 'INV-002',
        createdAt: DateTime.now(),
        subtotal: 800.0,
        totalAmount: 800.0,
        totalPurchaseAmount: 1000.0,
        items: [],
      );

      expect(billLoss.profitOrLoss, -200.0);
      expect(billLoss.isProfit, isFalse);
    });

    test('serializes and deserializes total_purchase_amount, purchase_price, shop_name, and payment_type', () {
      final item = BillItemModel(
        id: 10,
        billId: 1,
        productName: 'Oil Filter',
        unitPrice: 200.0,
        purchasePrice: 120.0,
        quantity: 3,
        totalPrice: 600.0,
      );

      final itemMap = item.toMap();
      expect(itemMap['purchase_price'], 120.0);

      final fromMapItem = BillItemModel.fromMap(itemMap);
      expect(fromMapItem.purchasePrice, 120.0);

      final bill = BillModel(
        id: 1,
        invoiceNumber: 'INV-100',
        createdAt: DateTime(2026, 9, 7),
        subtotal: 600.0,
        totalAmount: 600.0,
        totalPurchaseAmount: 360.0,
        purchaseShopName: 'Metro Auto Spares',
        purchasePaymentType: 'GPay',
        items: [item],
      );

      final billMap = bill.toMap();
      expect(billMap['total_purchase_amount'], 360.0);
      expect(billMap['purchase_shop_name'], 'Metro Auto Spares');
      expect(billMap['purchase_payment_type'], 'GPay');

      final fromMapBill = BillModel.fromMap(billMap, items: [item]);
      expect(fromMapBill.totalPurchaseAmount, 360.0);
      expect(fromMapBill.purchaseShopName, 'Metro Auto Spares');
      expect(fromMapBill.purchasePaymentType, 'GPay');
      expect(fromMapBill.profitOrLoss, 240.0);
      expect(fromMapBill.isProfit, isTrue);
    });
  });
}
