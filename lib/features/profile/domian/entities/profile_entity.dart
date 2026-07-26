class ProfileEntity {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String role;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
  });
}