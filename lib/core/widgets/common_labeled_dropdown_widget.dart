import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// A labeled dropdown that mirrors the look of [CommonLabeledInputItemWidget].
class CommonLabeledDropdownWidget<T> extends StatelessWidget {
  final String? label;
  final String hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isRequired;
  final String? errorText;

  const CommonLabeledDropdownWidget({
    required this.hintText,
    required this.items,
    required this.onChanged,
    super.key,
    this.label,
    this.value,
    this.isRequired = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(label!, style: AppTextStyles.sfProRoundedMedium),
              if (isRequired)
                Text(
                  ' *',
                  style: AppTextStyles.sfProRoundedSemiBold
                      .copyWith(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          style: AppTextStyles.sfProRoundedRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: context.textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            hintStyle: AppTextStyles.sfProRoundedRegular.copyWith(
              color: context.textTheme.titleLarge?.color?.withValues(alpha: 0.7),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              borderSide:
                  BorderSide(color: context.customThemeColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}
