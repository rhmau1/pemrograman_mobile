import '../entities/auth_session.dart';
import '../usecases/auth/check_auth_status_usecase.dart';
import '../usecases/auth/get_user_email_usecase.dart';
import '../usecases/auth/login_usecase.dart';
import '../usecases/auth/logout_usecase.dart';

class AuthController {
  const AuthController({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.getUserEmailUseCase,
  });

  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final GetUserEmailUseCase getUserEmailUseCase;

  Future<bool> isAuthenticated() => checkAuthStatusUseCase.execute();

  Future<AuthSession> login(String email, String password) =>
      loginUseCase.execute(email: email, password: password);

  Future<void> logout() => logoutUseCase.execute();

  Future<String?> getUserEmail() => getUserEmailUseCase.execute();
}
