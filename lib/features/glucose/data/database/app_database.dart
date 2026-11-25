import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'secure_database_key_store.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [GlucoseReadings, FoodLogs, MedicationReminders, UserSettings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting() : super(NativeDatabase.memory());

  AppDatabase.forTestingEncrypted(File file, String key)
      : super(
          NativeDatabase(
            file,
            setup: (database) => database.execute("PRAGMA key = '$key'"),
          ),
        );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
        onUpgrade: (migrator, from, to) async {
          if (from < 1) {
            await migrator.createAll();
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA secure_delete = ON');
        },
      );

  Future<void> deleteAllUserData() async {
    await transaction(() async {
      await delete(glucoseReadings).go();
      await delete(foodLogs).go();
      await delete(medicationReminders).go();
      await delete(userSettings).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/gulaku.sqlite');
    final key = await const SecureDatabaseKeyStore().loadOrCreate(file);
    return NativeDatabase.createInBackground(
      file,
      setup: (database) {
        if (key.encryptExistingPlaintext) {
          database.execute("PRAGMA rekey = '${key.value}'");
        } else {
          database.execute("PRAGMA key = '${key.value}'");
        }
      },
    );
  });
}
