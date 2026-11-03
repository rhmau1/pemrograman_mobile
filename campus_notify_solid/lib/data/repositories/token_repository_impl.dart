import '../../domain/repositories/token_repository.dart';
import '../datasources/local/token_local_datasource.dart';

class TokenRepositoryImpl implements TokenRepository {
  TokenRepositoryImpl({
    TokenLocalDataSource? localDataSource,
  }) : _localDataSource = localDataSource ?? TokenLocalDataSourceImpl();

  final TokenLocalDataSource _localDataSource;

  @override
  Future<void> saveTokens({required String access, required String refresh}) =>
      _localDataSource.saveTokens(access: access, refresh: refresh);

  @override
  Future<String?> getAccessToken() => _localDataSource.readAccess();

  @override
  Future<String?> getRefreshToken() => _localDataSource.readRefresh();

  @override
  Future<void> clear() => _localDataSource.clear();

  @override
  Future<void> saveUserEmail(String email) =>
      _localDataSource.saveUserEmail(email);

  @override
  Future<String?> getUserEmail() => _localDataSource.readUserEmail();

  @override
  Future<void> saveCustom(String key, String value) =>
      _localDataSource.writeCustom(key, value);

  @override
  Future<String?> getCustom(String key) => _localDataSource.readCustom(key);

  @override
  Future<void> deleteCustom(String key) => _localDataSource.deleteCustom(key);
}
