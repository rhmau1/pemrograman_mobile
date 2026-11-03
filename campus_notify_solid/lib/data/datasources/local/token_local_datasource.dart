import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenLocalDataSource {
  Future<void> saveTokens({required String access, required String refresh});
  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<void> clear();

  Future<void> saveUserEmail(String email);
  Future<String?> readUserEmail();

  Future<void> writeCustom(String key, String value);
  Future<String?> readCustom(String key);
  Future<void> deleteCustom(String key);
}

class TokenLocalDataSourceImpl implements TokenLocalDataSource {
  TokenLocalDataSourceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _emailKey = 'user_email';

  Future<void> save({required String access, required String refresh}) =>
      saveTokens(access: access, refresh: refresh);

  @override
  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  @override
  Future<String?> readAccess() => _storage.read(key: _accessKey);

  @override
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  @override
  Future<void> clear() => _storage.deleteAll();

  @override
  Future<void> saveUserEmail(String email) =>
      _storage.write(key: _emailKey, value: email);

  @override
  Future<String?> readUserEmail() => _storage.read(key: _emailKey);

  @override
  Future<void> writeCustom(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> readCustom(String key) => _storage.read(key: key);

  @override
  Future<void> deleteCustom(String key) => _storage.delete(key: key);
}
