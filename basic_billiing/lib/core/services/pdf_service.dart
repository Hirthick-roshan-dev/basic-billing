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
      final byteData = await rootBundle.load('assets/images/logo_header.png');
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
          margin: const pw.EdgeInsets.only(bottom: 165),
        ),
        header: (context) {
          if (context.pageNumber > 1) {
            return pw.Container(
              padding: const pw.EdgeInsets.fromLTRB(28, 12, 28, 8),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            );
          }
          return pw.SizedBox();
        },
        build: (context) {
          return [
            // 1. Top Header Banner (Rendered in document flow on first page)
            pw.Container(
              width: PdfPageFormat.a4.width,
              height: 135,
              color: PdfColors.white,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (headerImage != null) ...[
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(
                        left: 20,
                        top: 10,
                        bottom: 10,
                      ),
                      child: pw.Container(
                        height: 105,
                        width: 105,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          image: pw.DecorationImage(
                            image: headerImage,
                            fit: pw.BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 14),
                  ] else ...[
                    pw.SizedBox(width: 28),
                  ],
                  pw.Expanded(
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          // settings.businessName.isNotEmpty
                          //     ? settings.businessName.toUpperCase()
                          //     :
                          'BROTHERS  AUTO  CARE',
                          style: pw.TextStyle(
                            fontSize: 29,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            pw.Text(
                              'Two wheeler - '.toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.deepOrange,
                              ),
                            ),
                            pw.Text(
                              'Multi brand service centre'.toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          settings.address.isNotEmpty
                              ? settings.address
                              : 'No.1, Park Avenue, Near Aravind Eye Hospital Udumalpet - 642126',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          // settings.phoneNumber.isNotEmpty
                          //     ? settings.phoneNumber
                          //     :
                          '          78 71 75 78 78',
                          style: pw.TextStyle(
                            fontSize: 23,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                ],
              ),
            ),

            // 2. Metadata Section (Customer Details & Vehicle / Reference Details)
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(28, 10, 28, 0),
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
                                fontSize: 11.5,
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
                                  color: PdfColors.black,
                                ),
                              ),
                            ],
                            if (bill.vehicleNumber != null &&
                                bill.vehicleNumber!.trim().isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                'Vehicle No: ${bill.vehicleNumber!.trim().toUpperCase()}',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey800,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      // Date & Vehicle / Reference Details (Right side)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Date: ${AppDateUtils.formatInvoiceDate(bill.createdAt)}',
                            style: const pw.TextStyle(
                              fontSize: 9.5,
                              color: PdfColors.grey700,
                            ),
                          ),
                          if (bill.jobCardNumber != null &&
                              bill.jobCardNumber!.trim().isNotEmpty) ...[
                            pw.SizedBox(height: 3),
                            pw.Text(
                              'Job Card No: ${bill.jobCardNumber!.trim().toUpperCase()}',
                              style: pw.TextStyle(
                                fontSize: 9.5,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey800,
                              ),
                            ),
                          ],
                          if (bill.vehicleModel != null &&
                              bill.vehicleModel!.trim().isNotEmpty) ...[
                            pw.SizedBox(height: 3),
                            pw.Text(
                              'Model No: ${bill.vehicleModel!.trim().toUpperCase()}',
                              style: pw.TextStyle(
                                fontSize: 9.5,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey800,
                              ),
                            ),
                          ],
                          if (bill.km != null &&
                              bill.km!.trim().isNotEmpty) ...[
                            pw.SizedBox(height: 3),
                            pw.Text(
                              'KM: ${bill.km!.trim().toUpperCase()}',
                              style: pw.TextStyle(
                                fontSize: 9.5,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey800,
                              ),
                            ),
                          ],
                          pw.SizedBox(height: 3),
                          // pw.Text(
                          //   'Payment Mode: ${bill.paymentType.toUpperCase()}',
                          //   style: pw.TextStyle(
                          //     fontSize: 9.5,
                          //     fontWeight: pw.FontWeight.bold,
                          //     color: brandNavy,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.SizedBox(height: 8),
                ],
              ),
            ),

            // 3. Items Table (Unwrapped so MultiPage can naturally split across pages)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 28),
              child: pw.TableHelper.fromTextArray(
                headers: [
                  '#',
                  'ITEM DESCRIPTION',
                  'QTY',
                  'UNIT PRICE',
                  'AMOUNT',
                ],
                data: List<List<dynamic>>.generate(bill.items.length, (index) {
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
                headerHeight: 24,
                headerPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                cellStyle: const pw.TextStyle(
                  fontSize: 9.5,
                  color: PdfColors.grey900,
                ),
                cellHeight: 24,
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
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1.0),
                ),
                columnWidths: {
                  0: const pw.FixedColumnWidth(28),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FixedColumnWidth(45),
                  3: const pw.FixedColumnWidth(85),
                  4: const pw.FixedColumnWidth(90),
                },
              ),
            ),
          ];
        },
        footer: (context) {
          final isLastPage = context.pageNumber == context.pagesCount;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              if (isLastPage) ...[
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(28, 0, 28, 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // 4. Financial Summary Section (Only on the final page)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Container(
                            width: 240,
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
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
                                _buildSummaryRow(
                                  'Subtotal',
                                  formatMoney(bill.subtotal),
                                  fontBold: fontBold,
                                ),
                                if (bill.discountAmount > 0) ...[
                                  pw.SizedBox(height: 4),
                                  _buildSummaryRow(
                                    'Discount',
                                    '- ${formatMoney(bill.discountAmount)}',
                                    valueColor: PdfColors.red700,
                                  ),
                                ],
                                if (bill.taxPercent > 0 ||
                                    bill.taxAmount > 0) ...[
                                  pw.SizedBox(height: 4),
                                  _buildSummaryRow(
                                    'Tax (${CurrencyUtils.formatPlain(bill.taxPercent)}%)',
                                    '+ ${formatMoney(bill.taxAmount)}',
                                  ),
                                ],
                                pw.SizedBox(height: 4),
                                _buildSummaryRow(
                                  'Payment Mode',
                                  bill.paymentType.toUpperCase(),
                                  fontBold: fontBold,
                                ),
                                pw.SizedBox(height: 6),
                                pw.Divider(
                                  thickness: 0.8,
                                  color: PdfColors.grey300,
                                ),
                                pw.SizedBox(height: 4),
                                pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      bill.isTotalEdited
                                          ? 'FINAL TOTAL'
                                          : 'TOTAL AMOUNT',
                                      style: pw.TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: pw.FontWeight.bold,
                                        color: brandNavy,
                                      ),
                                    ),
                                    pw.Text(
                                      formatMoney(bill.totalAmount),
                                      style: pw.TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: pw.FontWeight.bold,
                                        color: brandNavy,
                                      ),
                                    ),
                                  ],
                                ),
                                if (bill.isTotalEdited) ...[
                                  pw.SizedBox(height: 2),
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
                      pw.SizedBox(height: 10),
                      pw.Divider(thickness: 1, color: PdfColors.grey300),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          // Left: Thank you message, Instagram & Page Number
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                "Thank you for choosing Brother's Auto Care. Don't forget to visit us again!",
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey800,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Row(
                                children: [
                                  pw.SvgImage(
                                    svg:
                                        '<svg viewBox="0 0 24 24" width="10" height="10"><path fill="#E1306C" d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/></svg>',
                                  ),
                                  pw.SizedBox(width: 4),
                                  pw.Text(
                                    'bac_auto_care',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.pink700,
                                    ),
                                  ),
                                  pw.SizedBox(width: 14),
                                  pw.Text(
                                    'Page ${context.pageNumber} of ${context.pagesCount}',
                                    style: const pw.TextStyle(
                                      fontSize: 8,
                                      color: PdfColors.grey500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Right: Authorized Signature
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Container(
                                width: 120,
                                decoration: const pw.BoxDecoration(
                                  border: pw.Border(
                                    bottom: pw.BorderSide(
                                      color: PdfColors.grey600,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Authorized Signature',
                                style: pw.TextStyle(
                                  fontSize: 8.5,
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
              ] else ...[
                // Non-final pages: simple footer with page indicator and continuation note
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(28, 0, 28, 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Continued on next page...',
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'Page ${context.pageNumber} of ${context.pagesCount}',
                        style: const pw.TextStyle(
                          fontSize: 8.5,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Bottom Accent Strip
              pw.Row(
                children: [
                  pw.Container(
                    width: PdfPageFormat.a4.width * 0.65,
                    height: 5,
                    color: brandNavy,
                  ),
                  pw.Container(
                    width: PdfPageFormat.a4.width * 0.35,
                    height: 5,
                    color: brandOrange,
                  ),
                ],
              ),
            ],
          );
        },
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
