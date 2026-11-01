import 'package:dio/dio.dart';

class AuthSession {
  const AuthSession({
    required this.access,
    required this.refresh,
    this.email,
    this.name,
  });

  final String access;
  final String refresh;
  final String? email;
  final String? name;
}

class AuthRepository {
  AuthRepository({Dio? dio}) : _dio = dio ?? Dio();
  final Dio _dio;

  /// Autentikasi API dengan validasi kredensial ketat (harus sesuai API)
  Future<AuthSession> login({
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

    // Validasi kredensial resmi ReqRes API
    // ReqRes akun resmi: eve.holt@reqres.in dengan password: cityslicka
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
        final token = data['token'] as String? ?? 'reqres-token';
        return AuthSession(
          access: token,
          refresh: 'refresh-$token',
          email: trimmedEmail,
          name: trimmedEmail.split('@').first,
        );
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

  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
