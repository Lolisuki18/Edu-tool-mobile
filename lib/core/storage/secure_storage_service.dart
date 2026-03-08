import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around [FlutterSecureStorage] for typed reads/writes.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  // ── Token ───────────────────────────────────────────────

  Future<String?> getAccessToken() => _storage.read(key: 'access_token');

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: 'access_token', value: token);

  Future<void> clearAccessToken() => _storage.delete(key: 'access_token');

  // ── User role ───────────────────────────────────────────

  Future<String?> getUserRole() => _storage.read(key: 'user_role');

  Future<void> saveUserRole(String role) =>
      _storage.write(key: 'user_role', value: role);

  // ── User data (JSON) ───────────────────────────────────

  Future<Map<String, dynamic>?> getUserData() async {
    final raw = await _storage.read(key: 'user_data');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveUserData(Map<String, dynamic> data) =>
      _storage.write(key: 'user_data', value: jsonEncode(data));

  // ── Clear all ──────────────────────────────────────────

  Future<void> clearAll() => _storage.deleteAll();
}
