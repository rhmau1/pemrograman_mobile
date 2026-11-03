import 'package:dio/dio.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    Dio? dio,
  }) : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl(dio: dio);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<String> refresh(String refreshToken) {
    return _remoteDataSource.refresh(refreshToken);
  }
}
