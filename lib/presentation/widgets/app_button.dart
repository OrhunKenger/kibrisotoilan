import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart'; // New Import

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;
  final IconData? icon;
  final Color? backgroundColor; // New

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 52,
    this.icon,
    this.backgroundColor, // New
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(label, style: AppTextStyles.button),
                ],
              )
            : Text(label, style: AppTextStyles.button);

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom( // Modified
            foregroundColor: backgroundColor ?? AppColors.primary,
            side: BorderSide(color: backgroundColor ?? AppColors.primary),
          ),
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom( // Modified
          backgroundColor: backgroundColor ?? AppColors.primary,
        ),
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}
