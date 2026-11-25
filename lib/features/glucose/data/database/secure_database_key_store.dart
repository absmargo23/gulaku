import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseEncryptionKey {
  const DatabaseEncryptionKey({
    required this.value,
    required this.encryptExistingPlaintext,
  });

  final String value;
  final bool encryptExistingPlaintext;
}

class SecureDatabaseKeyStore {
  const SecureDatabaseKeyStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _storageKey = 'gulaku_sqlcipher_key_v1';
  static const _sqliteHeader = 'SQLite format 3\u0000';

  final FlutterSecureStorage _storage;

  Future<DatabaseEncryptionKey> loadOrCreate(File databaseFile) async {
    final existingKey = await _storage.read(key: _storageKey);
    final fileExists = await databaseFile.exists();
    final containsPlaintextDatabase =
        fileExists && await _hasPlaintextSqliteHeader(databaseFile);

    if (existingKey != null) {
      return DatabaseEncryptionKey(
        value: existingKey,
        encryptExistingPlaintext: containsPlaintextDatabase,
      );
    }

    if (fileExists && !containsPlaintextDatabase) {
      throw StateError(
        'Kunci basis data aman tidak tersedia. Data tidak dapat dibuka.',
      );
    }

    final key = _createKey();
    await _storage.write(key: _storageKey, value: key);
    return DatabaseEncryptionKey(
      value: key,
      encryptExistingPlaintext: containsPlaintextDatabase,
    );
  }

  String _createKey() {
    final random = Random.secure();
    return List.generate(
      32,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  Future<bool> _hasPlaintextSqliteHeader(File file) async {
    final handle = await file.open();
    try {
      final bytes = await handle.read(_sqliteHeader.length);
      if (bytes.isEmpty) {
        return true;
      }
      return String.fromCharCodes(bytes) == _sqliteHeader;
    } finally {
      await handle.close();
    }
  }
}
