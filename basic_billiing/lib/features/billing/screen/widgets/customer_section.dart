import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../provider/cart_provider.dart';

class CustomerSection extends ConsumerStatefulWidget {
  const CustomerSection({super.key});

  @override
  ConsumerState<CustomerSection> createState() => _CustomerSectionState();
}

class _CustomerSectionState extends ConsumerState<CustomerSection> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final cart = ref.read(cartProvider);
    _nameController = TextEditingController(text: cart.customerName);
    _phoneController = TextEditingController(text: cart.customerPhone);
  }

  @override
  void didUpdateWidget(covariant CustomerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cart = ref.read(cartProvider);
    if (_nameController.text != cart.customerName) {
      _nameController.text = cart.customerName;
    }
    if (_phoneController.text != cart.customerPhone) {
      _phoneController.text = cart.customerPhone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CartState>(cartProvider, (previous, next) {
      if (previous?.customerName != next.customerName && _nameController.text != next.customerName) {
        _nameController.text = next.customerName;
      }
      if (previous?.customerPhone != next.customerPhone && _phoneController.text != next.customerPhone) {
        _phoneController.text = next.customerPhone;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Information',
          style: AppTextStyles.subsectionTitle,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _nameController,
                label: 'Name (Optional)',
                hintText: 'Customer name',
                prefixIcon: const Icon(Icons.person_outline, size: 18),
                onChanged: (val) {
                  ref.read(cartProvider.notifier).setCustomerName(val);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: _phoneController,
                label: 'Phone (Optional)',
                hintText: 'e.g. 9876543210',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9+\s\-()]*')),
                ],
                validator: Validators.validatePhone,
                onChanged: (val) {
                  ref.read(cartProvider.notifier).setCustomerPhone(val);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
