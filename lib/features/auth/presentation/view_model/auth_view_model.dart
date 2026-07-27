import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kitabghar/core/api/api_client.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/core/providers/notification_provider.dart';
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
    apiClient: ref.read(apiClientProvider),
    onUserAuthenticated: (email) =>
        ref.read(notificationsProvider.notifier).onUserAuthenticated(email),
    onUserLoggedOut: () => ref.read(notificationsProvider.notifier).clear(),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final RegisterUseCase _registerUseCase;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final ApiClient _apiClient;
  final Future<void> Function(String email) onUserAuthenticated;
  final void Function() onUserLoggedOut;

  // This is the same web OAuth client ID your backend already verifies
  // Google ID tokens against (GOOGLE_CLIENT_ID in kitabghar_backend's
  // .env) — OAuth client IDs are public identifiers meant to be embedded
  // in client apps, unlike secrets, so hardcoding this here is correct
  // and standard practice.
  static const String _googleServerClientId =
      '184221386512-n3sn5d94th2ku7b1nth0p0o3b8cgvslv.apps.googleusercontent.com';

  AuthNotifier({
    required RegisterUseCase registerUseCase,
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required ApiClient apiClient,
    required this.onUserAuthenticated,
    required this.onUserLoggedOut,
  })  : _registerUseCase = registerUseCase,
        _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _apiClient = apiClient,
        super(const AuthState());

  Future<void> register(AuthEntity entity) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _registerUseCase(entity);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = state.copyWith(isLoading: false, isSuccess: true),
    );
    if (state.isSuccess) {
      await onUserAuthenticated(entity.email);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _loginUseCase(
        LoginParams(email: email, password: password));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (user) => state = state.copyWith(isLoading: false, isSuccess: true, user: user),
    );
    if (state.isSuccess) {
      await onUserAuthenticated(email);
    }
  }

  Future<void> logout(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _logoutUseCase(email);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = const AuthState(),
    );
    onUserLoggedOut();
  }

  /// Signs in with Google, gets back an ID token, and sends it to the
  /// backend's existing POST /auth/google endpoint (the same one the web
  /// app already uses) — no backend changes needed, since the audience
  /// check there just validates against GOOGLE_CLIENT_ID either way.
  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: _googleServerClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the Google sign-in sheet.
        state = state.copyWith(isLoading: false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not get a Google ID token. Please try again.',
        );
        return;
      }

      final response = await _apiClient.post(
        ApiEndpoints.googleAuth,
        body: {'idToken': idToken},
      );

      final userJson = response['user'];
      final user = AuthEntity(
        id: userJson['id'] ?? '',
        name: userJson['name'] ?? '',
        email: userJson['email'] ?? '',
        password: '',
        role: userJson['role'] ?? 'user',
        token: response['token'],
      );

      state = state.copyWith(isLoading: false, isSuccess: true, user: user);
      await onUserAuthenticated(user.email);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Google sign-in failed: ${e.toString()}',
      );
    }
  }

  /// Patches the currently logged-in user's name/email in local state
  /// right after a successful Manage Profile update, so the rest of the
  /// app (e.g. the Profile page header) reflects the change immediately
  /// without needing to log out and back in.
  void updateLocalUser({String? name, String? email}) {
    final current = state.user;
    if (current == null) return;
    state = state.copyWith(
      user: AuthEntity(
        id: current.id,
        name: name ?? current.name,
        email: email ?? current.email,
        password: current.password,
        role: current.role,
        token: current.token,
      ),
    );
  }

  void resetState() => state = const AuthState();
}