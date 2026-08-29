import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../billing/model/bill_model.dart';
import '../../billing/model/bill_item_model.dart';
import '../model/business_settings_model.dart';
import '../provider/settings_provider.dart';

class PdfPreviewScreen extends ConsumerWidget {
  final BillModel? bill;

  const PdfPreviewScreen({super.key, this.bill});

  static void show(BuildContext context, {BillModel? bill}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(bill: bill),
      ),
    );
  }

  static BillModel createSampleBill(BusinessSettingsModel settings) {
    final now = DateTime.now();
    final taxEnabled = settings.taxEnabled;
    final taxPercent = taxEnabled ? settings.taxPercent : 0.0;

    final items = [
      BillItemModel(
        productName: 'Full Synthetic Engine Oil 5W-30 (3.5L)',
        unitPrice: 1850.0,
        quantity: 1,
        totalPrice: 1850.0,
      ),
      BillItemModel(
        productName: 'Oil Filter Element - OEM',
        unitPrice: 350.0,
        quantity: 1,
        totalPrice: 350.0,
      ),
      BillItemModel(
        productName: 'Front Ceramic Brake Pads (Set of 4)',
        unitPrice: 1200.0,
        quantity: 1,
        totalPrice: 1200.0,
      ),
      BillItemModel(
        productName: 'General Periodic Maintenance & Inspection',
        unitPrice: 800.0,
        quantity: 1,
        totalPrice: 800.0,
      ),
      BillItemModel(
        productName: 'Computerized Wheel Alignment & Balancing',
        unitPrice: 650.0,
        quantity: 1,
        totalPrice: 650.0,
      ),
    ];

    const subtotal = 4850.0;
    const discountAmount = 350.0;
    const amountAfterDiscount = 4500.0;
    final taxAmount = taxEnabled && taxPercent > 0
        ? CurrencyUtils.round((amountAfterDiscount * taxPercent) / 100.0)
        : 0.0;
    final totalAmount = CurrencyUtils.round(amountAfterDiscount + taxAmount);

    return BillModel(
      id: 999,
      invoiceNumber: 'INV-SAMPLE-0001',
      customerName: 'Roshan Kumar',
      customerPhone: '+91 98765 43210',
      vehicleNumber: 'TN 38 AB 1234',
      vehicleModel: 'Maruti Suzuki Swift',
      km: '45,200 KM',
      jobCardNumber: 'JC-1024',
      subtotal: subtotal,
      discountPercent: 7.22,
      discountAmount: discountAmount,
      taxPercent: taxPercent,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      createdAt: now,
      items: items,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.valueOrNull ??
        const BusinessSettingsModel(
          id: 1,
          businessName: "BROTHER'S AUTO CARE",
          phoneNumber: '78 71 75 78 78',
          address: 'No.1, Park Avenue, Near Aravind Eye Hospital, Udumalpet - 642126',
        );

    final isSample = bill == null;
    final displayBill = bill ?? createSampleBill(settings);
    final pdfService = ref.read(pdfServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isSample ? 'Sample Invoice PDF Preview' : 'Invoice ${displayBill.invoiceNumber}',
          style: AppTextStyles.pageTitle,
        ),
      ),
      body: Column(
        children: [
          if (isSample)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: AppColors.primaryLight.withValues(alpha: 0.25),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Previewing sample invoice with active business details and tax settings.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: PdfPreview(
              maxPageWidth: 700,
              initialPageFormat: PdfPageFormat.a4,
              canChangePageFormat: false,
              canChangeOrientation: false,
              pdfFileName: '${displayBill.invoiceNumber}.pdf',
              build: (format) async {
                return await pdfService.generateInvoicePdf(
                  bill: displayBill,
                  settings: settings,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
