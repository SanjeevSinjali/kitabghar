import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? id;
  final String name;
  final String email;
  final String password;
  final String phoneNumber;

  const AuthEntity({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [id, name, email, password, phoneNumber];
}