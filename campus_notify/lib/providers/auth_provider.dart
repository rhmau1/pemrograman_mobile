import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../data/token_store.dart';
import '../data/auth_repository.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      if (session.email != null) {
        await ref
            .read(tokenStoreProvider)
            .writeCustom('user_email', session.email!);
      }
      state = const AsyncData(true);
    } catch (e) {
      state = const AsyncData(false);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
    } catch (_) {}
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(false);
    ref.invalidateSelf();
  }
}

final userEmailProvider = FutureProvider<String?>((ref) async {
  final isAuth = ref.watch(authStateProvider).value ?? false;
  if (!isAuth) return null;
  return ref.read(tokenStoreProvider).readCustom('user_email');
});
