import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Centered empty-state message used across admin list screens.
class AdminEmptyView extends StatelessWidget {
  final String message;
  final IconData icon;

  const AdminEmptyView({
    required this.message,
    super.key,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: Dimensions.iconSizeExtraLarge, color: context.textTheme.bodySmall?.color),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.sfProRoundedRegular
                  .copyWith(color: context.textTheme.bodySmall?.color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centered error message with a retry button.
class AdminErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const AdminErrorView({required this.onRetry, super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: Dimensions.iconSizeLarge, color: context.errorColor),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Text(message ?? 'Something went wrong', textAlign: TextAlign.center),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
