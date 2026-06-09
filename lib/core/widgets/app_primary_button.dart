import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:flutter/material.dart';

/// Standard primary action button with an optional loading state.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expanded;
  final Color? color;

  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.expanded = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: Dimensions.buttonHeightDefault,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: Dimensions.iconSizeSmall),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.sfProRoundedSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                ],
              ),
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
