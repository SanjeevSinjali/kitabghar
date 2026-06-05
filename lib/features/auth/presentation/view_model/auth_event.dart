import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String address;

  RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
  });

  @override
  List<Object?> get props => [name, email, password, phone, address];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutEvent extends AuthEvent {
  final String email;

  LogoutEvent({required this.email});

  @override
  List<Object?> get props => [email];
}