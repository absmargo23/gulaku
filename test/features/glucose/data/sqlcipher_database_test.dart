import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/features/glucose/data/database/app_database.dart'
    hide GlucoseReading;

void main() {
  test('encrypts file-backed databases and rejects an incorrect key', () async {
    final directory =
        await Directory.systemTemp.createTemp('gulaku-sqlcipher-');
    final file = File('${directory.path}/gulaku.sqlite');
    const key = 'test-database-encryption-key';
    try {
      final encryptedDatabase = AppDatabase.forTestingEncrypted(file, key);
      await encryptedDatabase.into(encryptedDatabase.userSettings).insert(
            UserSettingsCompanion.insert(key: 'setting', value: 'value'),
          );
      await encryptedDatabase.close();

      final handle = await file.open();
      final header = await handle.read(16);
      await handle.close();
      expect(String.fromCharCodes(header), isNot('SQLite format 3\u0000'));

      final readableDatabase = AppDatabase.forTestingEncrypted(file, key);
      expect(
        await readableDatabase.select(readableDatabase.userSettings).get(),
        hasLength(1),
      );
      await readableDatabase.close();

      final incorrectKeyDatabase =
          AppDatabase.forTestingEncrypted(file, 'incorrect-key');
      await expectLater(
        incorrectKeyDatabase.select(incorrectKeyDatabase.userSettings).get(),
        throwsA(anything),
      );
      await incorrectKeyDatabase.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
