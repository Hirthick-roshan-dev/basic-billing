import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/core_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_text_field.dart';
import '../../features/billing/model/bill_model.dart';

class WhatsAppShareDialog extends ConsumerStatefulWidget {
  final BillModel bill;

  const WhatsAppShareDialog({super.key, required this.bill});

  static Future<void> show(BuildContext context, BillModel bill) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => WhatsAppShareDialog(bill: bill),
    );
  }

  @override
  ConsumerState<WhatsAppShareDialog> createState() => _WhatsAppShareDialogState();
}

class _WhatsAppShareDialogState extends ConsumerState<WhatsAppShareDialog> {
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  bool _isOpeningFolder = false;
  bool _isSharingWhatsApp = false;

  @override
  void initState() {
    super.initState();
    String initialDigits = '';
    if (widget.bill.customerPhone != null) {
      final digits = widget.bill.customerPhone!.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 10) {
        initialDigits = digits.substring(digits.length - 10);
      } else {
        initialDigits = digits;
      }
    }
    _phoneController = TextEditingController(text: initialDigits);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<File> _ensurePdfFile() async {
    final fileService = ref.read(fileServiceProvider);
    var file = await fileService.getInvoicePdf(widget.bill.invoiceNumber);
    if (file == null || !await file.exists()) {
      final settings = await ref.read(settingsRepositoryProvider).getSettings();
      final pdfService = ref.read(pdfServiceProvider);
      final bytes = await pdfService.generateInvoicePdf(
        bill: widget.bill,
        settings: settings,
      );
      file = await fileService.saveInvoicePdf(
        invoiceNumber: widget.bill.invoiceNumber,
        bytes: bytes,
      );
    }
    return file;
  }

  Future<void> _openPdfInFolder() async {
    setState(() => _isOpeningFolder = true);
    try {
      await _ensurePdfFile();
      final fileService = ref.read(fileServiceProvider);
      await fileService.openInvoiceFolder(widget.bill.invoiceNumber);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening PDF folder: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isOpeningFolder = false);
      }
    }
  }

  Future<void> _navigateToWhatsAppWithPdf() async {
    String? targetPhone;
    if (_phoneController.text.trim().isNotEmpty) {
      if (!_formKey.currentState!.validate()) return;
      final digits = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
      targetPhone = '+91$digits';
    }

    setState(() => _isSharingWhatsApp = true);
    try {
      final file = await _ensurePdfFile();
      final whatsappService = ref.read(whatsappServiceProvider);

      // Open WhatsApp chat directly with customer phone if available
      if (targetPhone != null || widget.bill.customerPhone?.isNotEmpty == true) {
        await whatsappService.openWhatsAppChat(
          bill: widget.bill,
          overridePhone: targetPhone,
        );
      }

      // Share the invoice PDF file directly
      await whatsappService.shareInvoiceFile(
        bill: widget.bill,
        filePath: file.path,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing invoice PDF to WhatsApp: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharingWhatsApp = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerName = widget.bill.customerName?.trim();

    return AppDialog(
      title: 'Share Invoice PDF',
      maxWidth: 460,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: AppColors.success,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice #${widget.bill.invoiceNumber}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (customerName != null && customerName.isNotEmpty)
                        Text(
                          'Customer: $customerName',
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Customer WhatsApp Number (Optional)',
              controller: _phoneController,
              hintText: '9876543210',
              prefixText: '+91 ',
              prefixIcon: const Icon(Icons.phone_outlined, size: 18),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: Validators.validateIndianPhone,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The generated invoice PDF file will be shared directly without text.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          label: 'Open PDF in Folder',
          icon: Icons.folder_open,
          variant: AppButtonVariant.outline,
          isLoading: _isOpeningFolder,
          onPressed: (_isOpeningFolder || _isSharingWhatsApp)
              ? null
              : _openPdfInFolder,
        ),
        AppButton(
          label: 'Navigate to WhatsApp with Invoice PDF',
          icon: Icons.chat,
          isLoading: _isSharingWhatsApp,
          variant: AppButtonVariant.primary,
          onPressed: (_isOpeningFolder || _isSharingWhatsApp)
              ? null
              : _navigateToWhatsAppWithPdf,
        ),
      ],
    );
  }
}
