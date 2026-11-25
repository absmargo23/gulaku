import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/features/food/data/food_photo_storage.dart';

void main() {
  const plaintext = 'private food photo bytes';

  test('encrypts photos and decrypts them with the same key', () async {
    final cipher = FoodPhotoCipher(SecretKey(List.filled(32, 7)));
    final encrypted = await cipher.encrypt(utf8.encode(plaintext));

    expect(encrypted, isNot(utf8.encode(plaintext)));
    expect(await cipher.decrypt(encrypted), utf8.encode(plaintext));
  });

  test('rejects modified or malformed encrypted photos', () async {
    final cipher = FoodPhotoCipher(SecretKey(List.filled(32, 7)));
    final encrypted = await cipher.encrypt(utf8.encode(plaintext));
    encrypted[encrypted.length - 1] ^= 1;

    await expectLater(cipher.decrypt(encrypted), throwsA(anything));
    await expectLater(cipher.decrypt([1, 2, 3]), throwsFormatException);
  });
}
