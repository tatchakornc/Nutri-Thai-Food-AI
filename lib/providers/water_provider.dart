import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/water_log_model.dart';
import '../services/water_service.dart';
import '../utils/date_utils.dart' as appDate;
import 'auth_provider.dart';

final waterServiceProvider = Provider<WaterService>((ref) {
  return WaterService();
});

final todayWaterLogProvider = StreamProvider<WaterLogModel>((ref) {
  final user = ref.watch(currentUserProvider);
  final date = appDate.DateUtils.todayString();

  if (user == null) {
    return Stream.value(
      WaterLogModel.empty(
        userId: '',
        date: date,
      ),
    );
  }

  return ref.watch(waterServiceProvider).streamWaterLog(
        user.uid,
        date,
      );
});

class WaterNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  void reset() {
    state = const AsyncData(null);
  }

  Future<void> addGlass() async {
    final user = ref.read(currentUserProvider);

    if (user == null) {
      state = AsyncError(
        'กรุณาเข้าสู่ระบบก่อนเพิ่มน้ำ',
        StackTrace.current,
      );
      return;
    }

    final today = appDate.DateUtils.todayString();

    final currentLog = ref.read(todayWaterLogProvider).valueOrNull ??
        WaterLogModel.empty(
          userId: user.uid,
          date: today,
        );

    if (currentLog.glassesDrunk >= WaterLogModel.maxGlasses) {
      state = const AsyncData(null);
      return;
    }

    final updated = currentLog.addGlass();

    state = const AsyncLoading();

    final service = ref.read(waterServiceProvider);

    unawaited(
      service.setWaterLog(updated).then((_) {
        ref.invalidate(todayWaterLogProvider);
      }).catchError((error, stackTrace) {
        print('Water add error: $error');
      }),
    );

    state = const AsyncData(null);
  }

  Future<void> removeGlass() async {
    final user = ref.read(currentUserProvider);

    if (user == null) {
      state = AsyncError(
        'กรุณาเข้าสู่ระบบก่อนแก้ไขบันทึกน้ำ',
        StackTrace.current,
      );
      return;
    }

    final today = appDate.DateUtils.todayString();

    final currentLog = ref.read(todayWaterLogProvider).valueOrNull ??
        WaterLogModel.empty(
          userId: user.uid,
          date: today,
        );

    if (currentLog.glassesDrunk <= 0) {
      state = const AsyncData(null);
      return;
    }

    final updated = currentLog.removeGlass();

    state = const AsyncLoading();

    final service = ref.read(waterServiceProvider);

    unawaited(
      service.setWaterLog(updated).then((_) {
        ref.invalidate(todayWaterLogProvider);
      }).catchError((error, stackTrace) {
        print('Water remove error: $error');
      }),
    );

    state = const AsyncData(null);
  }
}

final waterNotifierProvider =
    AsyncNotifierProvider<WaterNotifier, void>(WaterNotifier.new);