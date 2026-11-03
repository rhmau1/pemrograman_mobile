import 'package:dio/dio.dart';
import '../../models/auth_session_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });

  Future<String> refresh(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPass = password.trim();

    if (trimmedEmail.isEmpty || trimmedPass.isEmpty) {
      throw Exception('Email dan kata sandi wajib diisi');
    }

    if (trimmedPass.length < 6) {
      throw Exception('Kata sandi minimal 6 karakter');
    }

    if (trimmedEmail == 'eve.holt@reqres.in' && trimmedPass != 'cityslicka') {
      throw Exception('Kata sandi salah!');
    }

    try {
      final response = await _dio.post(
        'https://reqres.in/api/login',
        data: {'email': trimmedEmail, 'password': trimmedPass},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return AuthSessionModel.fromJson(data, email: trimmedEmail);
      }
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        String? errorMsg;
        if (data is Map) {
          errorMsg = data['error']?.toString();
        } else if (data is String) {
          errorMsg = data;
        }

        if (errorMsg != null && errorMsg.isNotEmpty) {
          throw Exception('Gagal Login API: $errorMsg');
        }
      }
      rethrow;
    }

    throw Exception('Login API tidak menghasilkan token');
  }

  @override
  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
