import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/user_profile_service.dart';
import 'auth_provider.dart';

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return Stream.value(null);
  }

  return ref.watch(userProfileServiceProvider).streamUserProfile(user.uid);
});

class ProfileNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveProfile(UserModel profile) async {
    state = const AsyncLoading();

    try {
      await ref
          .read(userProfileServiceProvider)
          .saveUserProfile(profile)
          .timeout(const Duration(seconds: 6));

      ref.invalidate(userProfileProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      ref.invalidate(userProfileProvider);

      if (e.toString().contains('TimeoutException')) {
        state = const AsyncData(null);
      } else {
        state = AsyncError(e, st);
      }
    }
  }

  Future<void> createInitialProfile(UserModel profile) async {
    state = const AsyncLoading();

    try {
      await ref
          .read(userProfileServiceProvider)
          .createInitialProfile(profile)
          .timeout(const Duration(seconds: 6));

      ref.invalidate(userProfileProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      ref.invalidate(userProfileProvider);

      if (e.toString().contains('TimeoutException')) {
        state = const AsyncData(null);
      } else {
        state = AsyncError(e, st);
      }
    }
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, void>(ProfileNotifier.new);