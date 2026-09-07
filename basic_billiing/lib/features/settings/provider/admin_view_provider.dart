import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/admin_pass_key_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../billing_history/screen/widgets/admin_pass_key_dialog.dart';

final adminViewProvider = StateNotifierProvider<AdminViewNotifier, bool>((ref) {
  final service = ref.watch(adminPassKeyServiceProvider);
  return AdminViewNotifier(service);
});

class AdminViewNotifier extends StateNotifier<bool> {
  final IAdminPassKeyService _service;

  AdminViewNotifier(this._service) : super(false) {
    _init();
  }

  Future<void> _init() async {
    final enabled = await _service.isAdminViewEnabled();
    state = enabled;
  }

  Future<void> setAdminView(bool enabled) async {
    state = enabled;
    await _service.setAdminViewEnabled(enabled);
  }

  Future<void> toggleAdminView(BuildContext context) async {
    if (!state) {
      // Turning ON requires admin pass key verification
      final verified = await AdminPassKeyDialog.show(context);
      if (verified == true) {
        state = true;
        await _service.setAdminViewEnabled(true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin View enabled. Financial and profit metrics are now visible.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } else {
      // Turning OFF
      state = false;
      await _service.setAdminViewEnabled(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin View disabled. Sensitive metrics hidden.'),
            backgroundColor: AppColors.textSecondary,
          ),
        );
      }
    }
  }
}
