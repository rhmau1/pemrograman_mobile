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
