import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../provider/settings_provider.dart';
import 'widgets/business_information_form.dart';
import 'widgets/tax_settings_form.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings', style: AppTextStyles.pageTitle),
      ),
      body: settingsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading settings...'),
        error: (err, stack) =>
            Center(child: Text('Error loading settings: $err')),
        data: (settings) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BusinessInformationForm(settings: settings),
                  const SizedBox(height: 20),
                  TaxSettingsForm(settings: settings),
                  const SizedBox(height: 20),
                  // const InvoicePreviewCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
