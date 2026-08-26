import 'dart:io';
import 'dart:typed_data';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class IFileService {
  Future<Directory> getInvoicesDirectory();
  Future<File> saveInvoicePdf({required String invoiceNumber, required Uint8List bytes});
  Future<File?> getInvoicePdf(String invoiceNumber);
  Future<bool> deleteInvoicePdf(String invoiceNumber);
  Future<bool> openInvoicePdf(String invoiceNumber);
}

class FileService implements IFileService {
  @override
  Future<Directory> getInvoicesDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final invoicesDir = Directory(p.join(docsDir.path, 'BillingApp', 'Invoices'));
    if (!await invoicesDir.exists()) {
      await invoicesDir.create(recursive: true);
    }
    return invoicesDir;
  }

  @override
  Future<File> saveInvoicePdf({required String invoiceNumber, required Uint8List bytes}) async {
    final invoicesDir = await getInvoicesDirectory();
    final filePath = p.join(invoicesDir.path, '$invoiceNumber.pdf');
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  @override
  Future<File?> getInvoicePdf(String invoiceNumber) async {
    final invoicesDir = await getInvoicesDirectory();
    final filePath = p.join(invoicesDir.path, '$invoiceNumber.pdf');
    final file = File(filePath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  @override
  Future<bool> deleteInvoicePdf(String invoiceNumber) async {
    try {
      final file = await getInvoicePdf(invoiceNumber);
      if (file != null && await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openInvoicePdf(String invoiceNumber) async {
    try {
      final file = await getInvoicePdf(invoiceNumber);
      if (file != null && await file.exists()) {
        final result = await OpenFilex.open(file.path);
        return result.type == ResultType.done;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
