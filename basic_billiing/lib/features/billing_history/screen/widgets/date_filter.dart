import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../model/billing_filter_model.dart';
import '../../provider/billing_filter_provider.dart';

class DateFilterWidget extends ConsumerWidget {
  const DateFilterWidget({super.key});

  Future<void> _selectSingleDate(BuildContext context, WidgetRef ref) async {
    final current =
        ref.read(billingFilterProvider).selectedDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(billingFilterProvider.notifier).setSelectedDate(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(billingFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...DateFilterType.values.map((type) {
            final isSelected = filter.type == type;
            String label = type.label;

            if (type == DateFilterType.singleDate &&
                filter.selectedDate != null) {
              label = AppDateUtils.formatInvoiceDate(filter.selectedDate!);
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (type == DateFilterType.singleDate) ...[
                      const Icon(Icons.calendar_today_outlined, size: 13),
                      const SizedBox(width: 6),
                    ],
                    Text(label),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (type == DateFilterType.singleDate) {
                    _selectSingleDate(context, ref);
                  } else {
                    ref.read(billingFilterProvider.notifier).setFilterType(type);
                  }
                },
                selectedColor: AppColors.primaryLight.withValues(alpha: 0.5),
                checkmarkColor: AppColors.primary,
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
