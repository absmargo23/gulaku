import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../glucose/data/database/secure_database_key_store.dart';

class FoodPhotoStorage {
  const FoodPhotoStorage();

  final _keyStore = const SecureDatabaseKeyStore();

  Future<String> save(XFile photo, String id) async {
    final applicationDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory(
      '${applicationDirectory.path}/food_photos',
    );
    await directory.create(recursive: true);

    final sourceName = photo.name;
    final extensionStart = sourceName.lastIndexOf('.');
    final extension =
        extensionStart >= 0 ? sourceName.substring(extensionStart) : '.jpg';
    final destination = File('${directory.path}/$id$extension.enc');
    final cipher =
        FoodPhotoCipher(await _loadEncryptionKey(applicationDirectory));
    await destination.writeAsBytes(
      await cipher.encrypt(await photo.readAsBytes()),
    );
    return destination.path;
  }

  Future<Uint8List> read(String path) async {
    final applicationDirectory = await getApplicationDocumentsDirectory();
    final encryptedBytes = await File(path).readAsBytes();
    final cipher = FoodPhotoCipher(
      await _loadEncryptionKey(applicationDirectory),
    );
    return cipher.decrypt(encryptedBytes);
  }

  Future<void> delete(String? path) async {
    if (path == null) {
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteAll() async {
    final applicationDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory('${applicationDirectory.path}/food_photos');
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<SecretKey> _loadEncryptionKey(Directory applicationDirectory) async {
    final databaseFile = File('${applicationDirectory.path}/gulaku.sqlite');
    final key = await _keyStore.loadOrCreate(databaseFile);
    final bytes = <int>[];
    for (var index = 0; index < key.value.length; index += 2) {
      bytes.add(int.parse(key.value.substring(index, index + 2), radix: 16));
    }
    return SecretKey(bytes);
  }
}

class FoodPhotoCipher {
  FoodPhotoCipher(SecretKey key) : _key = key;

  static const _nonceLength = 12;
  static const _macLength = 16;
  static final _algorithm = AesGcm.with256bits();

  final SecretKey _key;

  Future<Uint8List> encrypt(List<int> plaintext) async {
    final secretBox = await _algorithm.encrypt(plaintext, secretKey: _key);
    return Uint8List.fromList([
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
  }

  Future<Uint8List> decrypt(List<int> encryptedBytes) async {
    if (encryptedBytes.length < _nonceLength + _macLength) {
      throw const FormatException('Foto terenkripsi tidak valid.');
    }

    final secretBox = SecretBox(
      encryptedBytes.sublist(
        _nonceLength,
        encryptedBytes.length - _macLength,
      ),
      nonce: encryptedBytes.sublist(0, _nonceLength),
      mac: Mac(encryptedBytes.sublist(encryptedBytes.length - _macLength)),
    );
    return Uint8List.fromList(
      await _algorithm.decrypt(secretBox, secretKey: _key),
    );
  }
}
