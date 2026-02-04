import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_text_styles.dart';

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabel;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;
  final bool showNullOption;
  final String nullOptionLabel;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    this.prefixIcon,
    this.validator,
    this.showNullOption = true,
    this.nullOptionLabel = 'Seçiniz',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: AppDecorations.dropdown(
        label: label,
        prefixIcon: prefixIcon,
      ),
      dropdownColor: AppColors.surface,
      style: AppTextStyles.input,
      validator: validator,
      items: [
        if (showNullOption)
          DropdownMenuItem<T>(
            value: null,
            child: Text(nullOptionLabel, style: AppTextStyles.hint),
          ),
        ...items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabel(item)),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}
