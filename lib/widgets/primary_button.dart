import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum PrimaryButtonVariant { filled, outlined, text }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final PrimaryButtonVariant variant;
  final IconData? leadingIcon;
  final Color? color;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = PrimaryButtonVariant.filled,
    this.leadingIcon,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    Widget child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final size = width != null
        ? Size(width!, 52)
        : const Size(double.infinity, 52);

    switch (variant) {
      case PrimaryButtonVariant.filled:
        return SizedBox(
          width: width ?? double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: effectiveColor,
              foregroundColor: Colors.white,
              minimumSize: size,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: child,
          ),
        );
      case PrimaryButtonVariant.outlined:
        return SizedBox(
          width: width ?? double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: effectiveColor,
              side: BorderSide(color: effectiveColor, width: 1.5),
              minimumSize: size,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: child,
          ),
        );
      case PrimaryButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
    }
  }
}
