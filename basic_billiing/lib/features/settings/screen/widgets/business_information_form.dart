import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../model/business_settings_model.dart';
import '../../provider/settings_provider.dart';

class BusinessInformationForm extends ConsumerStatefulWidget {
  final BusinessSettingsModel settings;

  const BusinessInformationForm({super.key, required this.settings});

  @override
  ConsumerState<BusinessInformationForm> createState() =>
      _BusinessInformationFormState();
}

class _BusinessInformationFormState
    extends ConsumerState<BusinessInformationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.settings.businessName);
    _phoneController = TextEditingController(text: widget.settings.phoneNumber);
    _addressController = TextEditingController(text: widget.settings.address);
  }

  @override
  void didUpdateWidget(covariant BusinessInformationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_nameController.text != widget.settings.businessName) {
      _nameController.text = widget.settings.businessName;
    }
    if (_phoneController.text != widget.settings.phoneNumber) {
      _phoneController.text = widget.settings.phoneNumber;
    }
    if (_addressController.text != widget.settings.address) {
      _addressController.text = widget.settings.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(settingsProvider.notifier).updateBusinessInformation(
            phoneNumber: _phoneController.text.trim(),
            address: _addressController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business information updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update business information: $e'),
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
                Icon(Icons.storefront_outlined, color: AppColors.primary, size: 22),
                SizedBox(width: 10),
                Text('Business Information', style: AppTextStyles.sectionTitle),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'These details appear on your printed and saved invoice receipts.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _nameController,
              label: 'Store / Business Name (Fixed)',
              readOnly: true,
              prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _phoneController,
              label: 'Contact Phone Number',
              hintText: 'e.g. 78 71 75 78 78',
              prefixIcon: const Icon(Icons.phone_outlined, size: 18),
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _addressController,
              label: 'Store Address',
              hintText: 'e.g. No.1, Park Avenue, Near Aravind Eye Hospital, Udumalpet - 642126',
              prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
              maxLines: 2,
              validator: (v) => Validators.validateRequired(v, 'Store address'),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                label: 'Save Business Info',
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
