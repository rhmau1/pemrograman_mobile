import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/token_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/token_repository_impl.dart';
import '../../domain/controllers/auth_controller.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/token_repository.dart';
import '../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../domain/usecases/auth/get_user_email_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';

// Data Sources Providers
final tokenLocalDataSourceProvider = Provider<TokenLocalDataSource>(
  (ref) => TokenLocalDataSourceImpl(),
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(),
);

// Repositories Providers (DIP: depends on domain abstractions)
final tokenRepositoryProvider = Provider<TokenRepository>(
  (ref) => TokenRepositoryImpl(
    localDataSource: ref.watch(tokenLocalDataSourceProvider),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  ),
);

// Domain Use Cases Providers
final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    tokenRepository: ref.watch(tokenRepositoryProvider),
  ),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(
    tokenRepository: ref.watch(tokenRepositoryProvider),
    onUnsubscribeTopic: () async {
      try {
        await FirebaseMessaging.instance
            .unsubscribeFromTopic('pengumuman-kampus');
      } catch (_) {}
    },
  ),
);

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>(
  (ref) => CheckAuthStatusUseCase(
    tokenRepository: ref.watch(tokenRepositoryProvider),
  ),
);

final getUserEmailUseCaseProvider = Provider<GetUserEmailUseCase>(
  (ref) => GetUserEmailUseCase(
    tokenRepository: ref.watch(tokenRepositoryProvider),
  ),
);

// Domain Controller Provider ("Domain ibarat controller")
final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(
    loginUseCase: ref.watch(loginUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    checkAuthStatusUseCase: ref.watch(checkAuthStatusUseCaseProvider),
    getUserEmailUseCase: ref.watch(getUserEmailUseCaseProvider),
  ),
);

// Presentation State / View Model
final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return ref.watch(authControllerProvider).isAuthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await ref.read(authControllerProvider).login(email, password);
      state = const AsyncData(true);
    } catch (e) {
      state = const AsyncData(false);
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(authControllerProvider).logout();
    state = const AsyncData(false);
    ref.invalidateSelf();
  }
}

final userEmailProvider = FutureProvider<String?>((ref) async {
  final isAuth = ref.watch(authStateProvider).value ?? false;
  if (!isAuth) return null;
  return ref.watch(authControllerProvider).getUserEmail();
});
