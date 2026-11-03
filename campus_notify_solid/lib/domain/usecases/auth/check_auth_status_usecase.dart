import '../../repositories/token_repository.dart';

class CheckAuthStatusUseCase {
  const CheckAuthStatusUseCase({
    required this.tokenRepository,
  });

  final TokenRepository tokenRepository;

  Future<bool> execute() async {
    final token = await tokenRepository.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
