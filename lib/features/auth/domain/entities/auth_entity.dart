import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? token;

  const AuthEntity({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = 'user',
    this.token,
  });

  @override
  List<Object?> get props => [id, name, email, password, role];
}