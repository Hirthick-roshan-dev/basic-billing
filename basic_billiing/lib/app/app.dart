import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'app_navigation.dart';

class BillingApp extends StatelessWidget {
  const BillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick bill',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppNavigationWrapper(),
    );
  }
}
