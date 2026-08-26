import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';
import '../../features/billing/model/bill_model.dart';
import '../../features/settings/model/business_settings_model.dart';

abstract class IPdfService {
  Future<Uint8List> generateInvoicePdf({
    required BillModel bill,
    required BusinessSettingsModel settings,
  });
}

class PdfService implements IPdfService {
  @override
  Future<Uint8List> generateInvoicePdf({
    required BillModel bill,
    required BusinessSettingsModel settings,
  }) async {
    final pdf = pw.Document();

    // Use built-in offline PostScript fonts for guaranteed offline compatibility
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    final fontOblique = pw.Font.helveticaOblique();

    final theme = pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
      italic: fontOblique,
      boldItalic: fontBold,
    );

    // Format currency for standard PDF output
    String formatMoney(double amount) {
      return 'Rs. ${CurrencyUtils.formatPlain(amount)}';
    }

    // Brand color palette
    final brandNavy = PdfColor.fromHex('#0E1838');
    final brandOrange = PdfColor.fromHex('#E8581C');

    // Load top header banner image
    pw.MemoryImage? headerImage;
    try {
      final byteData = await rootBundle.load(
        'assets/images/invoice_header.png',
      );
      final headerImageBytes = byteData.buffer.asUint8List();
      headerImage = pw.MemoryImage(headerImageBytes);
    } catch (_) {
      // Fallback if header asset is unavailable
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: pw
              .EdgeInsets
              .zero, // Allows full-width edge-to-edge header & footer
        ),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // 1. Top Header Banner (Full-Bleed Edge-to-Edge with reduced height)
            if (headerImage != null)
              pw.Container(
                width: PdfPageFormat.a4.width,
                height: 140,
                child: pw.Image(headerImage, fit: pw.BoxFit.fill),
              ),

            // 2. Metadata Section (Customer Details & Plain Invoice Details) with 28pt padding
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(28, 12, 28, 0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Billed To
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'BILLED TO:',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey600,
                              ),
                            ),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              (bill.customerName != null &&
                                      bill.customerName!.trim().isNotEmpty)
                                  ? bill.customerName!.trim().toUpperCase()
                                  : 'WALK-IN CUSTOMER',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey900,
                              ),
                            ),
                            if (bill.customerPhone != null &&
                                bill.customerPhone!.trim().isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                'Phone: ${bill.customerPhone!.trim()}',
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      // Plain Invoice Details (no container)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'INVOICE',
                            style: pw.TextStyle(
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                              color: brandNavy,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            bill.invoiceNumber,
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Date: ${AppDateUtils.formatInvoiceDate(bill.createdAt)}  ${AppDateUtils.formatTime(bill.createdAt)}',
                            style: const pw.TextStyle(
                              fontSize: 9.5,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
        build: (context) {
          return [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 28),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // Items Table with perfectly aligned columns and clean styling
                  pw.TableHelper.fromTextArray(
                    headers: [
                      '#',
                      'ITEM DESCRIPTION',
                      'QTY',
                      'UNIT PRICE',
                      'AMOUNT',
                    ],
                    data: List<List<dynamic>>.generate(bill.items.length, (
                      index,
                    ) {
                      final item = bill.items[index];
                      return [
                        '${index + 1}',
                        item.productName,
                        '${item.quantity}',
                        formatMoney(item.unitPrice),
                        formatMoney(item.totalPrice),
                      ];
                    }),
                    headerStyle: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    headerDecoration: pw.BoxDecoration(color: brandNavy),
                    headerHeight: 26,
                    headerPadding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    cellPadding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    cellStyle: const pw.TextStyle(
                      fontSize: 9.5,
                      color: PdfColors.grey900,
                    ),
                    cellHeight: 26,
                    headerAlignments: {
                      0: pw.Alignment.center,
                      1: pw.Alignment.centerLeft,
                      2: pw.Alignment.centerRight,
                      3: pw.Alignment.centerRight,
                      4: pw.Alignment.centerRight,
                    },
                    cellAlignments: {
                      0: pw.Alignment.center,
                      1: pw.Alignment.centerLeft,
                      2: pw.Alignment.centerRight,
                      3: pw.Alignment.centerRight,
                      4: pw.Alignment.centerRight,
                    },
                    border: const pw.TableBorder(
                      horizontalInside: pw.BorderSide(
                        color: PdfColors.grey200,
                        width: 0.8,
                      ),
                      bottom: pw.BorderSide(
                        color: PdfColors.grey300,
                        width: 1.0,
                      ),
                    ),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(28),
                      1: const pw.FlexColumnWidth(4),
                      2: const pw.FixedColumnWidth(45),
                      3: const pw.FixedColumnWidth(85),
                      4: const pw.FixedColumnWidth(90),
                    },
                  ),
                  pw.SizedBox(height: 16),

                  // Clean, Unified Right-Aligned Financial Summary Section
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 250,
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey50,
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(6),
                          ),
                          border: pw.Border.all(
                            color: PdfColors.grey200,
                            width: 0.8,
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          children: [
                            // Subtotal
                            _buildSummaryRow(
                              'Subtotal',
                              formatMoney(bill.subtotal),
                              fontBold: fontBold,
                            ),

                            // Discount
                            if (bill.discountAmount > 0) ...[
                              pw.SizedBox(height: 5),
                              _buildSummaryRow(
                                'Discount',
                                '- ${formatMoney(bill.discountAmount)}',
                                valueColor: PdfColors.red700,
                              ),
                            ],

                            // Tax
                            if (bill.taxPercent > 0 || bill.taxAmount > 0) ...[
                              pw.SizedBox(height: 5),
                              _buildSummaryRow(
                                'Tax (${CurrencyUtils.formatPlain(bill.taxPercent)}%)',
                                '+ ${formatMoney(bill.taxAmount)}',
                              ),
                            ],

                            pw.SizedBox(height: 8),
                            pw.Divider(
                              thickness: 0.8,
                              color: PdfColors.grey300,
                            ),
                            pw.SizedBox(height: 6),

                            // Highlighted Total Row
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  bill.isTotalEdited
                                      ? 'FINAL TOTAL'
                                      : 'TOTAL AMOUNT',
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    fontWeight: pw.FontWeight.bold,
                                    color: brandNavy,
                                  ),
                                ),
                                pw.Text(
                                  formatMoney(bill.totalAmount),
                                  style: pw.TextStyle(
                                    fontSize: 13,
                                    fontWeight: pw.FontWeight.bold,
                                    color: brandNavy,
                                  ),
                                ),
                              ],
                            ),
                            if (bill.isTotalEdited) ...[
                              pw.SizedBox(height: 3),
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(
                                  '(Manually adjusted total)',
                                  style: const pw.TextStyle(
                                    fontSize: 7.5,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
        footer: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(28, 0, 28, 12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      // Left side: Thank you message & Page Number
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Thank you for choosing Brother's Auto Care. Don't forget to visit us again!",
                              style: pw.TextStyle(
                                fontSize: 9.5,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey800,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Page ${context.pageNumber} of ${context.pagesCount}',
                              style: const pw.TextStyle(
                                fontSize: 8.5,
                                color: PdfColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 24),
                      // Right side: Signature line
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 140,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(
                                  color: PdfColors.grey600,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'Authorized Signature',
                            style: pw.TextStyle(
                              fontSize: 9.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Bottom Accent Strip (Full-Bleed Edge-to-Edge from left to right)
            pw.Row(
              children: [
                pw.Container(
                  width: PdfPageFormat.a4.width * 0.65,
                  height: 6,
                  color: brandNavy,
                ),
                pw.Container(
                  width: PdfPageFormat.a4.width * 0.35,
                  height: 6,
                  color: brandOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return await pdf.save();
  }

  pw.Widget _buildSummaryRow(
    String label,
    String value, {
    pw.Font? fontBold,
    PdfColor? valueColor,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 9.5,
            font: fontBold,
            color: valueColor ?? PdfColors.grey900,
          ),
        ),
      ],
    );
  }
}
