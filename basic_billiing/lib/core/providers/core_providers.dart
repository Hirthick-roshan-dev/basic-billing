import 'package:basic_billiing/core/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../services/file_service.dart';
import '../services/pdf_service.dart';
import '../../features/billing/repo/product_repository.dart';
import '../../features/billing/repo/billing_repository.dart';
import '../../features/billing_history/repo/billing_history_repository.dart';
import '../../features/billing/repo/offer_repository.dart';
import '../../features/settings/repo/settings_repository.dart';

// Synchronous Database Provider reading the initialized database singleton
final databaseProvider = Provider<Database>((ref) {
  return AppDatabase.instance.db;
});

// Services Providers
final fileServiceProvider = Provider<IFileService>((ref) {
  return FileService();
});

final pdfServiceProvider = Provider<IPdfService>((ref) {
  return PdfService();
});

// Repositories Providers (Initialized synchronously with Database)
final productRepositoryProvider = Provider<IProductRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ProductRepository(db: db);
});

final offerRepositoryProvider = Provider<IOfferRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return OfferRepository(db: db);
});

final billingRepositoryProvider = Provider<IBillingRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BillingRepository(db: db);
});

final billingHistoryRepositoryProvider = Provider<IBillingHistoryRepository>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return BillingHistoryRepository(db: db);
});

final settingsRepositoryProvider = Provider<ISettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsRepository(db: db);
});
