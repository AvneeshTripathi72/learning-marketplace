import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final double? height;
  final double? width;
  final Color? backgroundColor;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.height,
    this.width,
    this.backgroundColor,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    final bgColor = widget.backgroundColor ??
        (widget.isSecondary
            ? Colors.transparent
            : (isDisabled ? theme.disabledColor.withValues(alpha: 0.15) : theme.colorScheme.primary));

    final fgColor = widget.isSecondary
        ? (isDisabled ? theme.disabledColor : theme.colorScheme.primary)
        : (isDisabled ? theme.disabledColor : theme.colorScheme.onPrimary);

    return MouseRegion(
      onEnter: !isDisabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: !isDisabled ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: widget.height ?? 48,
        width: widget.width ?? double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: widget.isSecondary
              ? Border.all(
                  color: isDisabled
                      ? theme.disabledColor.withValues(alpha: 0.3)
                      : theme.colorScheme.primary,
                  width: 1.5,
                )
              : null,
          boxShadow: (!isDisabled && !widget.isSecondary && !isDark)
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: _isHovered ? 0.35 : 0.2),
                    blurRadius: _isHovered ? 12 : 6,
                    offset: _isHovered ? const Offset(0, 4) : const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.isLoading ? null : widget.onPressed,
            splashColor: fgColor.withValues(alpha: 0.12),
            highlightColor: fgColor.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: 18,
                              color: fgColor,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: AppTypography.button(fgColor).copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
