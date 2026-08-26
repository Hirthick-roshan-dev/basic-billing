import 'dart:io';
import '../model/bill_model.dart';

enum BillingModeType { create, edit }

class BillingMode {
  final BillingModeType type;
  final int? billId;
  final String? invoiceNumber;
  final DateTime? createdAt;

  const BillingMode._({
    required this.type,
    this.billId,
    this.invoiceNumber,
    this.createdAt,
  });

  const BillingMode.create() : this._(type: BillingModeType.create);

  const BillingMode.edit({
    required int billId,
    required String invoiceNumber,
    required DateTime createdAt,
  }) : this._(
          type: BillingModeType.edit,
          billId: billId,
          invoiceNumber: invoiceNumber,
          createdAt: createdAt,
        );

  bool get isEdit => type == BillingModeType.edit;
  bool get isCreate => type == BillingModeType.create;
}

sealed class BillingProcessState {
  const BillingProcessState();
}

class BillingIdleState extends BillingProcessState {
  const BillingIdleState();
}

class BillingSavingState extends BillingProcessState {
  const BillingSavingState();
}

class BillingGeneratingPdfState extends BillingProcessState {
  const BillingGeneratingPdfState();
}

class BillingSuccessState extends BillingProcessState {
  final BillModel bill;
  final File? pdfFile;
  final bool isEdit;

  const BillingSuccessState({
    required this.bill,
    this.pdfFile,
    this.isEdit = false,
  });
}

class BillingErrorState extends BillingProcessState {
  final String message;

  const BillingErrorState(this.message);
}
