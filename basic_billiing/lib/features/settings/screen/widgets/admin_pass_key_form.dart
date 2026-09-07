import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class AdminPassKeyForm extends ConsumerStatefulWidget {
  const AdminPassKeyForm({super.key});

  @override
  ConsumerState<AdminPassKeyForm> createState() => _AdminPassKeyFormState();
}

class _AdminPassKeyFormState extends ConsumerState<AdminPassKeyForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentKeyController = TextEditingController();
  final _newKeyController = TextEditingController();
  final _confirmKeyController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentKeyController.dispose();
    _newKeyController.dispose();
    _confirmKeyController.dispose();
    super.dispose();
  }

  Future<void> _updatePassKey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final adminService = ref.read(adminPassKeyServiceProvider);
      final currentEntered = _currentKeyController.text.trim();
      final isCurrentValid = await adminService.verifyPassKey(currentEntered);

      if (!isCurrentValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Current pass key is incorrect'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final newKey = _newKeyController.text.trim();
      await adminService.setPassKey(newKey);

      _currentKeyController.clear();
      _newKeyController.clear();
      _confirmKeyController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin pass key updated successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update pass key: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.lock_outline, color: AppColors.primary, size: 22),
                SizedBox(width: 10),
                Text('Admin Pass Key', style: AppTextStyles.sectionTitle),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Set the admin pass key required to edit completed bills in Bill History. Default pass key is 1234.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Current Pass Key',
              controller: _currentKeyController,
              hintText: 'Enter current pass key',
              obscureText: _obscureCurrent,
              prefixIcon: const Icon(Icons.password, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCurrent
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() => _obscureCurrent = !_obscureCurrent);
                },
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Current pass key is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'New Pass Key',
              controller: _newKeyController,
              hintText: 'Enter new pass key (min 4 characters)',
              obscureText: _obscureNew,
              prefixIcon: const Icon(Icons.key, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() => _obscureNew = !_obscureNew);
                },
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'New pass key is required';
                }
                if (v.trim().length < 4) {
                  return 'Pass key must be at least 4 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Confirm New Pass Key',
              controller: _confirmKeyController,
              hintText: 'Re-enter new pass key',
              obscureText: _obscureConfirm,
              prefixIcon: const Icon(Icons.key, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please confirm new pass key';
                }
                if (v.trim() != _newKeyController.text.trim()) {
                  return 'Pass keys do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                label: 'Update Pass Key',
                icon: Icons.check,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _updatePassKey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
