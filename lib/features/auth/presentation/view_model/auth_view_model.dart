import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/api/api_client.dart';
import 'package:kitabghar/core/services/hive/hive_service.dart';
import 'package:kitabghar/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:kitabghar/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kitabghar/features/auth/data/repositories/auth_repositories.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
import 'package:kitabghar/features/auth/domain/usecases/login_usercase.dart';
import 'package:kitabghar/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kitabghar/features/auth/domain/usecases/register_usecase.dart';
import 'package:kitabghar/features/auth/presentation/state/auth_state.dart';

// Providers
final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(hiveService: ref.read(hiveServiceProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.read(authLocalDataSourceProvider),
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(repository: ref.read(authRepositoryProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(repository: ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(repository: ref.read(authRepositoryProvider));
});

final authViewModelProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    registerUseCase: ref.read(registerUseCaseProvider),
    loginUseCase: ref.read(loginUseCaseProvider),
    logoutUseCase: ref.read(logoutUseCaseProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final RegisterUseCase _registerUseCase;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthNotifier({
    required RegisterUseCase registerUseCase,
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _registerUseCase = registerUseCase,
        _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthState());

  Future<void> register(AuthEntity entity) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _registerUseCase(entity);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = state.copyWith(isLoading: false, isSuccess: true),
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _loginUseCase(
        LoginParams(email: email, password: password));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (user) => state = state.copyWith(isLoading: false, isSuccess: true, user: user),
    );
  }

  Future<void> logout(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _logoutUseCase(email);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = const AuthState(),
    );
  }

  void resetState() => state = const AuthState();
}