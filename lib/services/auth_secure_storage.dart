import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:store_app/models/user.dart';

class AuthSecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user';

  /// Simpan token JWT
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Ambil token JWT
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Simpan data user (JSON)
  static Future<void> saveUser(User user) async {
    await _storage.write(key: _userKey, value: user.toJson());
  }

  /// Ambil data user
  static Future<User?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;
    return User.fromJson(userJson);
  }

  /// Hapus semua data auth (logout)
  static Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
