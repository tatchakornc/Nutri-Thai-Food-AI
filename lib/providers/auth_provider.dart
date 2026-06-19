import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

/// Singleton AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Stream of Firebase auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Current user (nullable)
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Auth actions state
class AuthNotifier extends AsyncNotifier<void> {
  late AuthService _authService;

  @override
  Future<void> build() async {
    _authService = ref.watch(authServiceProvider);
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authService.loginWithEmail(
          email: email,
          password: password,
        ));
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authService.registerWithEmail(
          email: email,
          password: password,
          displayName: displayName,
        ));
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authService.signOut());
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
