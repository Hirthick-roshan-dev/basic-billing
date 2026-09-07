import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';

class AdminPassKeyDialog extends ConsumerStatefulWidget {
  const AdminPassKeyDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const AdminPassKeyDialog(),
    );
  }

  @override
  ConsumerState<AdminPassKeyDialog> createState() => _AdminPassKeyDialogState();
}

class _AdminPassKeyDialogState extends ConsumerState<AdminPassKeyDialog> {
  final _keyController = TextEditingController();
  bool _obscureText = true;
  String? _errorMessage;
  bool _isVerifying = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final entered = _keyController.text.trim();
    if (entered.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter admin pass key';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final adminService = ref.read(adminPassKeyServiceProvider);
    final isValid = await adminService.verifyPassKey(entered);

    if (!mounted) return;

    if (isValid) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Incorrect pass key. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Admin Verification Required',
      maxWidth: 400,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Editing a completed bill requires admin authorization.',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Admin Pass Key',
            controller: _keyController,
            hintText: 'Enter pass key (Default: 1234)',
            obscureText: _obscureText,
            prefixIcon: const Icon(Icons.password, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            errorText: _errorMessage,
            autofocus: true,
            onSubmitted: (_) => _verify(),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: 'Verify & Edit',
          icon: Icons.check,
          variant: AppButtonVariant.primary,
          isLoading: _isVerifying,
          onPressed: _verify,
        ),
      ],
    );
  }
}
