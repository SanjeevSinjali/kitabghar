import 'package:hive/hive.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: 0)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String password;
  @HiveField(3)
  final String phoneNumber;
  @HiveField(4)
  final String? token;

  AuthHiveModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.token,
  });

  factory AuthHiveModel.fromEntity(AuthEntity entity) => AuthHiveModel(
        name: entity.name,
        email: entity.email,
        password: entity.password,
        phoneNumber: entity.phoneNumber,
        token: entity.token,
      );

  AuthEntity toEntity() => AuthEntity(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        token: token,
      );
}