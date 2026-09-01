import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../billing/model/bill_model.dart';
import 'billing_details_dialog.dart';

class BillingCard extends StatelessWidget {
  final BillModel bill;
  final VoidCallback? onNavigateToBilling;

  const BillingCard({super.key, required this.bill, this.onNavigateToBilling});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (bill.id != null) {
            BillingDetailsDialog.show(
              context,
              billId: bill.id!,
              onNavigateToBilling: onNavigateToBilling,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              // Icon Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Invoice Number & Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          bill.invoiceNumber,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: bill.paymentType.toUpperCase() == 'UPI'
                                ? Colors.deepPurple.withValues(alpha: 0.1)
                                : AppColors.successLight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: bill.paymentType.toUpperCase() == 'UPI'
                                  ? Colors.deepPurple.shade300
                                  : AppColors.success.withValues(alpha: 0.6),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                bill.paymentType.toUpperCase() == 'UPI'
                                    ? Icons.qr_code_2_outlined
                                    : Icons.payments_outlined,
                                size: 11,
                                color: bill.paymentType.toUpperCase() == 'UPI'
                                    ? Colors.deepPurple.shade700
                                    : AppColors.success,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                bill.paymentType.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: bill.paymentType.toUpperCase() == 'UPI'
                                      ? Colors.deepPurple.shade700
                                      : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (bill.isTotalEdited) ...[
                          // const SizedBox(width: 6),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          //   decoration: BoxDecoration(
                          //     color: AppColors.warningLight,
                          //     borderRadius: BorderRadius.circular(4),
                          //   ),
                          //   child: const Text(
                          //     'Edited',
                          //     style: TextStyle(
                          //       fontSize: 10,
                          //       fontWeight: FontWeight.bold,
                          //       color: AppColors.warning,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bill.customerName?.isNotEmpty == true
                          ? '${bill.customerName}${bill.customerPhone?.isNotEmpty == true ? ' • ${bill.customerPhone}' : ''}'
                          : 'Walk-in Customer',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (bill.vehicleNumber?.isNotEmpty == true ||
                        bill.jobCardNumber?.isNotEmpty == true) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (bill.vehicleNumber?.isNotEmpty == true) ...[
                            const Icon(
                              Icons.directions_car_outlined,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              bill.vehicleNumber!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          if (bill.vehicleNumber?.isNotEmpty == true &&
                              bill.jobCardNumber?.isNotEmpty == true)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          if (bill.jobCardNumber?.isNotEmpty == true) ...[
                            const Icon(
                              Icons.assignment_outlined,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              bill.jobCardNumber!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Date & Time
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppDateUtils.formatInvoiceDate(bill.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppDateUtils.formatTime(bill.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Total Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyUtils.format(bill.totalAmount),
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'View details →',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
