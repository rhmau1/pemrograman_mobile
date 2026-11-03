import 'package:dio/dio.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/token_repository.dart';

/// Dio dengan refresh otomatis: saat 401, coba refresh SATU kali lalu ulangi
/// request. Bila refresh gagal, sesi dibersihkan dan [onSessionExpired]
/// dipanggil agar UI kembali ke /login.
Dio buildApiClient(
  TokenRepository tokenRepository,
  AuthRepository authRepository, {
  void Function()? onSessionExpired,
}) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://reqres.in/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final access = await tokenRepository.getAccessToken();
      if (access != null) {
        options.headers['Authorization'] = 'Bearer $access';
      }
      handler.next(options);
    },
    onError: (e, handler) async {
      final alreadyRetried = e.requestOptions.extra['retried'] == true;
      if (e.response?.statusCode == 401 && !alreadyRetried) {
        final refresh = await tokenRepository.getRefreshToken();
        if (refresh == null) return handler.next(e);
        try {
          final renewed = await authRepository.refresh(refresh);
          await tokenRepository.saveTokens(access: renewed, refresh: refresh);
          final retry = await dio.fetch(
            e.requestOptions
              ..headers['Authorization'] = 'Bearer $renewed'
              ..extra['retried'] = true,
          );
          return handler.resolve(retry);
        } catch (_) {
          await tokenRepository.clear(); // refresh ikut mati -> paksa login ulang
          onSessionExpired?.call();
        }
      }
      handler.next(e);
    },
  ));

  return dio;
}
