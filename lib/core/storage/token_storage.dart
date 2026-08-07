import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _ownerKey = 'auth_owner';

  final FlutterSecureStorage _storage;

  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> ownerJson,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _ownerKey, value: jsonEncode(ownerJson));
  }

  Future<String?> get token => _storage.read(key: _tokenKey);

  Future<Map<String, dynamic>?> get ownerJson async {
    final raw = await _storage.read(key: _ownerKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _ownerKey);
  }
}
