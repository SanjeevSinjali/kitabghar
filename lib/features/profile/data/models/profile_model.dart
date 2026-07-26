import 'package:kitabghar/features/profile/domian/entities/profile_entity.dart';

class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String role;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      role: json['role'] ?? 'user',
    );
  }

  ProfileEntity toEntity() => ProfileEntity(
        id: id,
        name: name,
        email: email,
        avatar: avatar,
        role: role,
      );
}