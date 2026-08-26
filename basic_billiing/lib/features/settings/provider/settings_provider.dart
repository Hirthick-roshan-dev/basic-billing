import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../model/business_settings_model.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, BusinessSettingsModel>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends AsyncNotifier<BusinessSettingsModel> {
  @override
  Future<BusinessSettingsModel> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    return await repo.getSettings();
  }

  Future<void> updateBusinessInformation({
    required String phoneNumber,
    required String address,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final current = state.valueOrNull ?? const BusinessSettingsModel();
      final updated = current.copyWith(
        businessName: "BROTHER'S AUTO CARE",
        phoneNumber: phoneNumber.trim(),
        address: address.trim(),
      );
      final repo = ref.read(settingsRepositoryProvider);
      await repo.updateSettings(updated);
      return updated;
    });
  }

  Future<void> updateTaxSettings({
    required bool taxEnabled,
    required double taxPercent,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final current = state.valueOrNull ?? const BusinessSettingsModel();
      final updated = current.copyWith(
        taxEnabled: taxEnabled,
        taxPercent: taxEnabled ? taxPercent : 0.0,
      );
      final repo = ref.read(settingsRepositoryProvider);
      await repo.updateSettings(updated);
      return updated;
    });
  }
}
