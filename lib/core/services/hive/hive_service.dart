import 'package:hive_flutter/hive_flutter.dart';
import 'package:kitabghar/features/auth/data/models/auth_hive_model.dart';

class HiveService {
  static const String _authBox = 'auth_box';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AuthHiveModelAdapter());
    await Hive.openBox<AuthHiveModel>(_authBox);
  }

  Box<AuthHiveModel> get _box => Hive.box<AuthHiveModel>(_authBox);

  Future<void> registerUser(AuthHiveModel user) async {
    await _box.put(user.email, user);
  }

  AuthHiveModel? getUser(String email) => _box.get(email);

  Future<void> deleteUser(String email) async {
    await _box.delete(email);
  }

  List<AuthHiveModel> getAllUsers() => _box.values.toList();
}