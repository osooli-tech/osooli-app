import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the last few search terms locally.
class RecentSearchesStorage {
  static const _key = 'recent_searches';
  static const _maxEntries = 8;

  final FlutterSecureStorage _storage;

  RecentSearchesStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<List<String>> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>).whereType<String>().toList();
    } on FormatException {
      return const [];
    }
  }

  Future<List<String>> add(String term) async {
    final entries = await load();
    entries.remove(term);
    entries.insert(0, term);
    final trimmed = entries.take(_maxEntries).toList();
    await _storage.write(key: _key, value: jsonEncode(trimmed));
    return trimmed;
  }

  Future<void> clear() => _storage.delete(key: _key);
}
