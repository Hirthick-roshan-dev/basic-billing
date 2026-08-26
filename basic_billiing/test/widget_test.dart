import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:basic_billiing/app/app.dart';
import 'package:basic_billiing/core/database/database_migrations.dart';
import 'package:basic_billiing/core/providers/core_providers.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('BillingApp launches and renders primary navigation', (WidgetTester tester) async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: DatabaseMigrations.onCreate,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const BillingApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app title / elements exist
    expect(find.text('Billing'), findsWidgets);
    expect(find.text('History'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);

    await db.close();
  });
}
