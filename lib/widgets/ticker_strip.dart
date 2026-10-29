import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/khao_theme.dart';

/// Section 2: rotated yellow band with an infinite marquee of item names.
///
/// Lay it out with [layoutHeight] and overlap the hero by [overlapTop]; the
/// next section tucks under it by [overlapBottom].
class TickerStrip extends StatelessWidget {
  const TickerStrip({super.key, required this.labels});

  final List<String> labels;

  static double fontSize(bool desktop) => desktop ? 44 : 30;
  static double vPad(bool desktop) => desktop ? 18 : 12;

  /// Bebas line box (normal line-height ≈ 1.2) plus vertical padding.
  static double layoutHeight(bool desktop) =>
      fontSize(desktop) * 1.2 + vPad(desktop) * 2;
  static double overlapTop(bool desktop) => desktop ? 18 : 10;
  static double overlapBottom(bool desktop) => desktop ? 14 : 10;
  static double bleed(bool desktop) => desktop ? 20 : 16;

  @override
  Widget build(BuildContext context) {
    final desktop = KhaoLayout.isDesktop(context);
    final size = fontSize(desktop);
    final gap = desktop ? 40.0 : 22.0;

    final copy = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final l in labels) ...[
          LatinText(
            l,
            size: size,
            letterSpacing: desktop ? 1 : null,
            color: KhaoColors.black,
            height: 1.2,
          ),
          SizedBox(width: gap),
          Text(
            '✺',
            style: TextStyle(
              fontSize: size * 0.8,
              color: KhaoColors.red,
              height: 1.2,
            ),
          ),
          SizedBox(width: gap),
        ],
      ],
    );

    return Semantics(
      label: labels.join(', '),
      child: ExcludeSemantics(
        child: Transform.rotate(
          angle: (desktop ? -1.5 : -2) * math.pi / 180,
          child: Container(
            height: layoutHeight(desktop),
            color: KhaoColors.yellow,
            alignment: Alignment.centerLeft,
            child: Marquee(
              // CSS: 30s (desktop) / 22s (mobile) per copy.
              period: Duration(seconds: desktop ? 30 : 22),
              child: copy,
            ),
          ),
        ),
      ),
    );
  }
}

/// Scrolls [child] leftwards forever, tiling copies to fill the viewport.
class Marquee extends StatefulWidget {
  const Marquee({super.key, required this.child, required this.period});

  final Widget child;
  final Duration period;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: widget.period);
  final _copyKey = GlobalKey();
  double? _copyWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (KhaoMotion.reduced(context)) {
      _c
        ..stop()
        ..value = 0;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void didUpdateWidget(Marquee old) {
    super.didUpdateWidget(old);
    if (old.period != widget.period) {
      _c.duration = widget.period;
      if (_c.isAnimating) _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _measure() {
    final box = _copyKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final w = box.size.width;
    if (w > 0 && w != _copyWidth) setState(() => _copyWidth = w);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measure();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = _copyWidth;
        final copies = w == null ? 2 : (constraints.maxWidth / w).ceil() + 1;
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            minWidth: 0,
            maxWidth: double.infinity,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, child) => Transform.translate(
                offset: Offset(-(w ?? 0) * _c.value, 0),
                child: child,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NotificationListener<SizeChangedLayoutNotification>(
                    onNotification: (_) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => mounted ? _measure() : null,
                      );
                      return true;
                    },
                    child: SizeChangedLayoutNotifier(
                      child: KeyedSubtree(key: _copyKey, child: widget.child),
                    ),
                  ),
                  for (var i = 1; i < copies; i++) widget.child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
