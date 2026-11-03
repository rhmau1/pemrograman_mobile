import '../../repositories/token_repository.dart';

class GetUserEmailUseCase {
  const GetUserEmailUseCase({
    required this.tokenRepository,
  });

  final TokenRepository tokenRepository;

  Future<String?> execute() async {
    return tokenRepository.getUserEmail();
  }
}
