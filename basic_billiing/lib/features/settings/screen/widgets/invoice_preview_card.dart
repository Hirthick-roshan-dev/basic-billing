// import 'package:flutter/material.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/widgets/app_button.dart';
// import '../pdf_preview_screen.dart';

// class InvoicePreviewCard extends StatelessWidget {
//   const InvoicePreviewCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: AppColors.primaryLight.withValues(alpha: 0.35),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(
//                     Icons.picture_as_pdf_outlined,
//                     color: AppColors.primary,
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 14),
//                 // Expanded(
//                 //   child: Column(
//                 //     crossAxisAlignment: CrossAxisAlignment.start,
//                 //     children: [
//                 //       Text(
//                 //         'Invoice Template & PDF Preview',
//                 //         style: AppTextStyles.subsectionTitle,
//                 //       ),
//                 //       const SizedBox(height: 2),
//                 //       const Text(
//                 //         'Preview the exact invoice layout with sample customer details, vehicle number, line items, and current settings.',
//                 //         style: AppTextStyles.bodySmall,
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),
//               ],
//             ),
//             const SizedBox(height: 18),
//             const Divider(),
//             const SizedBox(height: 14),
//             // Row(
//             //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //   children: [
//             //     const Text(
//             //       'Format: A4 Standard (Print & Share ready)',
//             //       style: AppTextStyles.bodySmall,
//             //     ),
//             //     AppButton(
//             //       label: 'Preview Sample PDF',
//             //       icon: Icons.visibility_outlined,
//             //       variant: AppButtonVariant.primary,
//             //       onPressed: () {
//             //         PdfPreviewScreen.show(context);
//             //       },
//             //     ),
//             //   ],
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
