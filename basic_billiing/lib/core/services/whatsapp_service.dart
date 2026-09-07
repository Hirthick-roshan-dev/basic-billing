import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/billing/model/bill_model.dart';

abstract class IWhatsAppService {
  String toWhatsAppDigits(String? phone);
  Future<bool> shareInvoiceFile({
    required BillModel bill,
    required String filePath,
  });
  Future<bool> openWhatsAppChat({
    required BillModel bill,
    String? overridePhone,
  });
}

class WhatsAppService implements IWhatsAppService {
  @override
  String toWhatsAppDigits(String? phone) {
    if (phone == null) return '';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '91$digits';
    }
    return digits;
  }

  @override
  Future<bool> shareInvoiceFile({
    required BillModel bill,
    required String filePath,
  }) async {
    try {
      final xFile = XFile(
        filePath,
        mimeType: 'application/pdf',
        name: '${bill.invoiceNumber}.pdf',
      );
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          subject: 'Invoice ${bill.invoiceNumber}',
        ),
      );
      return result.status != ShareResultStatus.dismissed;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openWhatsAppChat({
    required BillModel bill,
    String? overridePhone,
  }) async {
    final phoneTarget = overridePhone ?? bill.customerPhone;
    final digits = toWhatsAppDigits(phoneTarget);

    String urlStr;
    if (digits.isNotEmpty) {
      urlStr = 'https://wa.me/$digits';
    } else {
      urlStr = 'https://wa.me/';
    }

    final uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }
}
