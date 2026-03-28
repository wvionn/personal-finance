import 'package:flutter/material.dart';

/// Compact one-tap control: flat border, no shadow / glow.
class QuickPillButton extends StatefulWidget {
  const QuickPillButton({
    super.key,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.borderColor,
    this.labelColor,
    this.compact = false,
  });

  final String label;
  final String? subtitle;
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
    _scale = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = widget.borderColor ?? scheme.primary;
    final lbl = widget.labelColor ?? scheme.primary;

    return ScaleTransition(
      scale: _scale,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _c.forward(),
          onTapUp: (_) => _c.reverse(),
          onTapCancel: () => _c.reverse(),
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: scheme.surface.withValues(alpha: 0.65),
              border: Border.all(color: border.withValues(alpha: 0.65)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.compact ? 12 : 16,
                vertical: widget.compact ? 10 : 14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: lbl,
                          letterSpacing: 0.2,
                        ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
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
