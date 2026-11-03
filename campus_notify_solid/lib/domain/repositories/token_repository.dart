abstract class TokenRepository {
  Future<void> saveTokens({required String access, required String refresh});
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clear();

  Future<void> saveUserEmail(String email);
  Future<String?> getUserEmail();

  Future<void> saveCustom(String key, String value);
  Future<String?> getCustom(String key);
  Future<void> deleteCustom(String key);
}
