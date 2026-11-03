import '../../domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.access,
    required super.refresh,
    super.email,
    super.name,
  });

  factory AuthSessionModel.fromJson(
    Map<String, dynamic> json, {
    String? email,
  }) {
    final token = json['token'] as String? ?? 'reqres-token';
    final userEmail = email ?? json['email'] as String?;
    return AuthSessionModel(
      access: token,
      refresh: 'refresh-$token',
      email: userEmail,
      name: userEmail?.split('@').first,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
    };
  }
}
