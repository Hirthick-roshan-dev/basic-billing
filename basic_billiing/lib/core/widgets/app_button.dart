import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = Colors.white;
        borderSide = null;
        break;
      case AppButtonVariant.secondary:
        bgColor = AppColors.secondary;
        fgColor = Colors.white;
        borderSide = null;
        break;
      case AppButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = AppColors.primary;
        borderSide = const BorderSide(color: AppColors.border, width: 1.5);
        break;
      case AppButtonVariant.danger:
        bgColor = AppColors.error;
        fgColor = Colors.white;
        borderSide = null;
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    } else if (icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: fgColor),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.button.copyWith(color: fgColor)),
        ],
      );
    } else {
      content = Text(label, style: AppTextStyles.button.copyWith(color: fgColor));
    }

    final buttonWidget = Material(
      color: onPressed == null ? AppColors.border : bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: (isLoading || onPressed == null) ? null : onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: borderSide != null ? Border.fromBorderSide(borderSide) : null,
          ),
          child: content,
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: buttonWidget);
    }
    return buttonWidget;
  }
}
