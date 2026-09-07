import 'package:flutter/material.dart';

class PremiumCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool hasHoverEffect;
  final Color? backgroundColor;
  final BoxBorder? border;
  final Gradient? gradient;

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 12.0,
    this.hasHoverEffect = true,
    this.backgroundColor,
    this.border,
    this.gradient,
  });

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final effectiveBorder = widget.border ??
        Border.all(
          color: _isHovered
              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.4 : 0.5)
              : (isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
          width: 1,
        );

    return MouseRegion(
      onEnter: widget.hasHoverEffect ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.hasHoverEffect ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -3.0 : 0.0),
        decoration: BoxDecoration(
          color: widget.gradient == null
              ? (widget.backgroundColor ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white))
              : null,
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: effectiveBorder,
          boxShadow: isDark
              ? [
                  if (_isHovered)
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.03),
                    blurRadius: _isHovered ? 14 : 6,
                    offset: _isHovered ? const Offset(0, 6) : const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            onTap: widget.onTap,
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
