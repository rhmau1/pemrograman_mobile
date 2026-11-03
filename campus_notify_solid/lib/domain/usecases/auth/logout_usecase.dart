import '../../repositories/token_repository.dart';

class LogoutUseCase {
  const LogoutUseCase({
    required this.tokenRepository,
    this.onUnsubscribeTopic,
  });

  final TokenRepository tokenRepository;
  final Future<void> Function()? onUnsubscribeTopic;

  Future<void> execute() async {
    try {
      if (onUnsubscribeTopic != null) {
        await onUnsubscribeTopic!();
      }
    } catch (_) {}
    await tokenRepository.clear();
  }
}
