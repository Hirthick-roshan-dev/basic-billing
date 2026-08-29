import 'package:flutter_test/flutter_test.dart';
import 'package:basic_billiing/features/billing/model/cart_item_model.dart';
import 'package:basic_billiing/features/billing/provider/cart_provider.dart';

void main() {
  group('CartState Calculations Tests', () {
    test('calculates subtotal correctly from line items', () {
      final items = [
        CartItemModel(productName: 'Milk', unitPrice: 30.0, quantity: 2), // 60.0
        CartItemModel(productName: 'Bread', unitPrice: 50.0, quantity: 1), // 50.0
      ];

      final state = CartState(items: items);
      expect(state.subtotal, 110.0);
      expect(state.totalItemCount, 3);
    });

    test('calculates discount correctly', () {
      final items = [
        CartItemModel(productName: 'Item 1', unitPrice: 100.0, quantity: 1),
      ];

      final state = CartState(
        items: items,
        discountAmount: 10.0,
      );

      expect(state.subtotal, 100.0);
      expect(state.discountAmount, 10.0);
      expect(state.effectiveDiscountAmount, 10.0);
      expect(state.discountPercent, 10.0);
      expect(state.amountAfterDiscount, 90.0);
    });

    test('calculates tax correctly after discount', () {
      final items = [
        CartItemModel(productName: 'Milk', unitPrice: 30.0, quantity: 2), // 60
        CartItemModel(productName: 'Bread', unitPrice: 50.0, quantity: 1), // 50 => subtotal 110
      ];

      final state = CartState(
        items: items,
        discountAmount: 11.0, // -11 => 99.0
        taxEnabled: true,
        taxPercent: 5.0, // 5% of 99.0 => 4.95
      );

      expect(state.subtotal, 110.0);
      expect(state.effectiveDiscountAmount, 11.0);
      expect(state.amountAfterDiscount, 99.0);
      expect(state.taxAmount, 4.95);
      expect(state.calculatedTotal, 103.95);
      expect(state.payableTotal, 103.95);
    });

    test('does not apply tax when taxEnabled is false', () {
      final items = [
        CartItemModel(productName: 'Item', unitPrice: 100.0, quantity: 1),
      ];

      final state = CartState(
        items: items,
        taxEnabled: false,
        taxPercent: 18.0,
      );

      expect(state.taxAmount, 0.0);
      expect(state.calculatedTotal, 100.0);
    });

    test('respects manual total override when isTotalEdited is true', () {
      final items = [
        CartItemModel(productName: 'Item', unitPrice: 100.0, quantity: 1),
      ];

      final state = CartState(
        items: items,
        taxEnabled: true,
        taxPercent: 18.0,
        isTotalEdited: true,
        manualTotal: 115.0,
      );

      expect(state.calculatedTotal, 118.0);
      expect(state.payableTotal, 115.0);
      expect(state.isTotalEdited, isTrue);
    });

    test('updates unit price for cart item and recalculates subtotal and total', () {
      final item = CartItemModel(productName: 'Engine Oil', unitPrice: 200.0, quantity: 2);
      expect(item.totalPrice, 400.0);

      final updatedItem = item.copyWith(unitPrice: 180.0);
      expect(updatedItem.unitPrice, 180.0);
      expect(updatedItem.totalPrice, 360.0);

      final state = CartState(items: [updatedItem]);
      expect(state.subtotal, 360.0);
      expect(state.payableTotal, 360.0);
    });

    test('supports vehicleNumber, vehicleModel, km, and jobCardNumber in CartState copyWith', () {
      const state = CartState(
        customerName: 'John',
        customerPhone: '9876543210',
        vehicleNumber: 'TN 38 AB 1234',
        vehicleModel: 'Swift',
        km: '45000',
        jobCardNumber: 'JC-1024',
      );

      expect(state.customerName, 'John');
      expect(state.customerPhone, '9876543210');
      expect(state.vehicleNumber, 'TN 38 AB 1234');
      expect(state.vehicleModel, 'Swift');
      expect(state.km, '45000');
      expect(state.jobCardNumber, 'JC-1024');

      final updated = state.copyWith(
        vehicleNumber: 'KL 07 CD 5678',
        vehicleModel: 'Creta',
        km: '50000',
      );
      expect(updated.vehicleNumber, 'KL 07 CD 5678');
      expect(updated.vehicleModel, 'Creta');
      expect(updated.km, '50000');
      expect(updated.jobCardNumber, 'JC-1024');
    });
  });
}
