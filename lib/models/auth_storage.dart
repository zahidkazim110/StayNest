import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _emailKey = 'staynest_auth_email';
  static const String _saltKey = 'staynest_auth_salt';
  static const String _hashKey = 'staynest_auth_hash';

  static final Pbkdf2 _algorithm = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  );

  static String _toHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static List<int> _fromHex(String value) {
    return List.generate(
      value.length ~/ 2,
      (i) => int.parse(value.substring(i * 2, i * 2 + 2), radix: 16),
    );
  }

  static Future<List<int>> _deriveHash(
    String password,
    List<int> salt,
  ) async {
    final key = await _algorithm.deriveKey(
      secretKey: SecretKey(password.codeUnits),
      nonce: salt,
    );

    return key.extractBytes();
  }

  static Future<void> saveCredentials(
    String email,
    String password,
  ) async {
    final normalizedEmail = email.trim().toLowerCase();

    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));

    final hash = await _deriveHash(password, salt);

    await _storage.write(
      key: _emailKey,
      value: normalizedEmail,
    );

    await _storage.write(
      key: _saltKey,
      value: _toHex(salt),
    );

    await _storage.write(
      key: _hashKey,
      value: _toHex(hash),
    );
  }

  static Future<bool> resetPassword(
    String email,
    String newPassword,
  ) async {
    final savedEmail = await _storage.read(key: _emailKey);

    if (savedEmail == null ||
        email.trim().toLowerCase() != savedEmail) {
      return false;
    }

    await saveCredentials(email, newPassword);
    return true;
  }
  static Future<bool> verifyCredentials(
    String email,
    String password,
  ) async {
    final savedEmail = await _storage.read(key: _emailKey);
    final savedSalt = await _storage.read(key: _saltKey);
    final savedHash = await _storage.read(key: _hashKey);

    if (savedEmail == null || savedSalt == null || savedHash == null) {
      return false;
    }

    if (email.trim().toLowerCase() != savedEmail) {
      return false;
    }

    final salt = _fromHex(savedSalt);
    final expectedHash = _fromHex(savedHash);
    final actualHash = await _deriveHash(password, salt);

    if (actualHash.length != expectedHash.length) {
      return false;
    }

    var difference = 0;

    for (var i = 0; i < actualHash.length; i++) {
      difference |= actualHash[i] ^ expectedHash[i];
    }

    return difference == 0;
  }
}

