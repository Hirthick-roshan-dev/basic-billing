import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../model/business_settings_model.dart';
import '../../provider/settings_provider.dart';

class TaxSettingsForm extends ConsumerStatefulWidget {
  final BusinessSettingsModel settings;

  const TaxSettingsForm({super.key, required this.settings});

  @override
  ConsumerState<TaxSettingsForm> createState() => _TaxSettingsFormState();
}

class _TaxSettingsFormState extends ConsumerState<TaxSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late bool _taxEnabled;
  late final TextEditingController _taxPercentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _taxEnabled = widget.settings.taxEnabled;
    _taxPercentController = TextEditingController(
      text: widget.settings.taxPercent > 0 ? CurrencyUtils.formatPlain(widget.settings.taxPercent) : '5.0',
    );
  }

  @override
  void didUpdateWidget(covariant TaxSettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_taxEnabled != widget.settings.taxEnabled) {
      _taxEnabled = widget.settings.taxEnabled;
    }
    if (_taxPercentController.text != CurrencyUtils.formatPlain(widget.settings.taxPercent)) {
      _taxPercentController.text =
          widget.settings.taxPercent > 0 ? CurrencyUtils.formatPlain(widget.settings.taxPercent) : '5.0';
    }
  }

  @override
  void dispose() {
    _taxPercentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_taxEnabled && !_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final taxPercent = _taxEnabled
          ? (double.tryParse(_taxPercentController.text.trim()) ?? 0.0)
          : 0.0;

      await ref.read(settingsProvider.notifier).updateTaxSettings(
            taxEnabled: _taxEnabled,
            taxPercent: taxPercent,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tax settings updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update tax settings: $e'),
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
                Icon(Icons.percent, color: AppColors.primary, size: 22),
                SizedBox(width: 10),
                Text('Tax Settings', style: AppTextStyles.sectionTitle),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Configure automatic tax calculations for new bills. Existing historical bills will not be affected.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 18),

            // Toggle Switch Tile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enable Tax Calculation',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _taxEnabled ? 'Tax is applied to new bills' : 'No tax applied to new bills',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  Switch(
                    value: _taxEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _taxEnabled = val);
                    },
                  ),
                ],
              ),
            ),

            if (_taxEnabled) ...[
              const SizedBox(height: 16),
              AppTextField(
                controller: _taxPercentController,
                label: 'Default Tax Rate (%)',
                hintText: 'e.g. 5.0, 18.0',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (v) => Validators.validatePercentage(v, max: 100.0),
              ),
            ],

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                label: 'Save Tax Settings',
                icon: Icons.check,
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
