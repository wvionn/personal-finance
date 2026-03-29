import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Compact one-tap control with a calm, tactile visual style.
class QuickPillButton extends StatefulWidget {
  const QuickPillButton({
    super.key,
    required this.label,
    this.subtitle,
    this.icon,
    required this.onTap,
    this.borderColor,
    this.labelColor,
    this.compact = false,
  });

  final String label;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? borderColor;
  final Color? labelColor;
  final bool compact;

  @override
  State<QuickPillButton> createState() => _QuickPillButtonState();
}

class _QuickPillButtonState extends State<QuickPillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scale = Tween<double>(
      begin: 1,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = widget.borderColor ?? AppTheme.borderHighlight;
    final lbl = widget.labelColor ?? AppTheme.textMain;
    
    return ScaleTransition(
      scale: _scale,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _c.forward(),
          onTapUp: (_) => _c.reverse(),
          onTapCancel: () => _c.reverse(),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppTheme.panel,
              border: Border.all(color: border, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.compact ? 12 : 16,
                vertical: widget.compact ? 14 : 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 16, color: lbl),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: lbl,
                                letterSpacing: 0.1,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
