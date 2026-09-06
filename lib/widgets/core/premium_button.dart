import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Fallback for colorScheme.surfaceVariant which might be missing in older flutter versions,
    // although we are using flutter latest. Let's use theme.disabledColor or similar if needed.
    final disabledBgColor = theme.disabledColor.withOpacity(0.1);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isSecondary 
            ? Colors.transparent 
            : (onPressed == null ? disabledBgColor : theme.colorScheme.primary),
        borderRadius: BorderRadius.circular(8),
        border: isSecondary 
            ? Border.all(color: theme.colorScheme.primary, width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isSecondary ? theme.colorScheme.primary : theme.colorScheme.onPrimary),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 20,
                          color: onPressed == null 
                              ? theme.disabledColor 
                              : (isSecondary ? theme.colorScheme.primary : theme.colorScheme.onPrimary),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: AppTypography.button(
                            onPressed == null 
                                ? theme.disabledColor 
                                : (isSecondary ? theme.colorScheme.primary : theme.colorScheme.onPrimary)),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
