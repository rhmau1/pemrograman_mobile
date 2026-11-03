import '../../entities/auth_session.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/token_repository.dart';

class LoginUseCase {
  const LoginUseCase({
    required this.authRepository,
    required this.tokenRepository,
  });

  final AuthRepository authRepository;
  final TokenRepository tokenRepository;

  Future<AuthSession> execute({
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
    if (trimmedEmail == 'eve.holt@reqres.in' && trimmedPass != 'cityslicka') {
      throw Exception('Kata sandi salah!');
    }

    final session = await authRepository.login(
      email: trimmedEmail,
      password: trimmedPass,
    );

    await tokenRepository.saveTokens(
      access: session.access,
      refresh: session.refresh,
    );

    if (session.email != null) {
      await tokenRepository.saveUserEmail(session.email!);
    }

    return session;
  }
}
