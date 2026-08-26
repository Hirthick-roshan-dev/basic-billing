import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../model/product_model.dart';
import '../../provider/product_provider.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  final ProductModel? productToEdit;

  const AddProductDialog({super.key, this.productToEdit});

  static Future<ProductModel?> show(BuildContext context, {ProductModel? productToEdit}) {
    return showDialog<ProductModel>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddProductDialog(productToEdit: productToEdit),
    );
  }

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productToEdit?.name ?? '');
    _priceController = TextEditingController(
      text: widget.productToEdit != null ? CurrencyUtils.formatPlain(widget.productToEdit!.price) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final name = _nameController.text.trim();
      final price = double.parse(_priceController.text.trim());

      ProductModel result;
      if (widget.productToEdit != null) {
        final updated = widget.productToEdit!.copyWith(name: name, price: price);
        await ref.read(productListProvider.notifier).updateProduct(updated);
        result = updated;
      } else {
        result = await ref.read(productListProvider.notifier).addProduct(
              name: name,
              price: price,
            );
      }

      if (mounted) {
        Navigator.of(context).pop(result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.productToEdit != null
                  ? 'Product updated successfully'
                  : 'Product added successfully',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;

    return AppDialog(
      title: isEditing ? 'Edit Product' : 'Add New Product',
      maxWidth: 460,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Product Name',
              hintText: 'e.g. Engine Oil, Brake Pad, Oil Filter',
              maxLength: 80,
              autofocus: true,
              validator: (v) => Validators.validateProductName(v, maxLength: 80),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _priceController,
              label: 'Unit Price',
              hintText: '0.00',
              prefixText: '${CurrencyUtils.defaultCurrencySymbol} ',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: Validators.validatePrice,
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: isEditing ? 'Save Changes' : 'Add Product',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}
