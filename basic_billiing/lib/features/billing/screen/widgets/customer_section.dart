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
  late final TextEditingController _vehicleController;
  late final TextEditingController _modelController;
  late final TextEditingController _kmController;
  late final TextEditingController _jobCardController;

  @override
  void initState() {
    super.initState();
    final cart = ref.read(cartProvider);
    _nameController = TextEditingController(text: cart.customerName);
    _phoneController = TextEditingController(text: cart.customerPhone);
    _vehicleController = TextEditingController(text: cart.vehicleNumber);
    _modelController = TextEditingController(text: cart.vehicleModel);
    _kmController = TextEditingController(text: cart.km);
    _jobCardController = TextEditingController(text: cart.jobCardNumber);
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
    if (_vehicleController.text != cart.vehicleNumber) {
      _vehicleController.text = cart.vehicleNumber;
    }
    if (_modelController.text != cart.vehicleModel) {
      _modelController.text = cart.vehicleModel;
    }
    if (_kmController.text != cart.km) {
      _kmController.text = cart.km;
    }
    if (_jobCardController.text != cart.jobCardNumber) {
      _jobCardController.text = cart.jobCardNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleController.dispose();
    _modelController.dispose();
    _kmController.dispose();
    _jobCardController.dispose();
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
      if (previous?.vehicleNumber != next.vehicleNumber && _vehicleController.text != next.vehicleNumber) {
        _vehicleController.text = next.vehicleNumber;
      }
      if (previous?.vehicleModel != next.vehicleModel && _modelController.text != next.vehicleModel) {
        _modelController.text = next.vehicleModel;
      }
      if (previous?.km != next.km && _kmController.text != next.km) {
        _kmController.text = next.km;
      }
      if (previous?.jobCardNumber != next.jobCardNumber && _jobCardController.text != next.jobCardNumber) {
        _jobCardController.text = next.jobCardNumber;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer & Vehicle Information',
          style: AppTextStyles.subsectionTitle,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _nameController,
                label: 'Customer Name (Optional)',
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
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _vehicleController,
                label: 'Vehicle No. (Optional)',
                hintText: 'e.g. TN 38 AB 1234',
                prefixIcon: const Icon(Icons.directions_car_outlined, size: 18),
                textCapitalization: TextCapitalization.characters,
                onChanged: (val) {
                  ref.read(cartProvider.notifier).setVehicleNumber(val);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: _modelController,
                label: 'Vehicle Model (Optional)',
                hintText: 'e.g. Swift / Creta / i20',
                prefixIcon: const Icon(Icons.commute_outlined, size: 18),
                textCapitalization: TextCapitalization.words,
                onChanged: (val) {
                  ref.read(cartProvider.notifier).setVehicleModel(val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _kmController,
                label: 'KM Driven (Optional)',
                hintText: 'e.g. 45000',
                prefixIcon: const Icon(Icons.speed_outlined, size: 18),
                onChanged: (val) {
                  ref.read(cartProvider.notifier).setKm(val);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: _jobCardController,
                label: 'Job Card No. (Optional)',
                hintText: 'e.g. JC-1024',
                prefixIcon: const Icon(Icons.assignment_outlined, size: 18),
                textCapitalization: TextCapitalization.characters,
                onChanged: (val) {
                  ref.read(cartProvider.notifier).setJobCardNumber(val);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
