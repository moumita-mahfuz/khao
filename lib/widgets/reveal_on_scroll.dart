import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../theme/khao_theme.dart';

/// Fades [child] up 24px the first time it scrolls into view.
///
/// With reduced motion the child is shown in its end state immediately.
class RevealOnScroll extends StatefulWidget {
  const RevealOnScroll({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 24,
  });

  final Widget child;
  final Duration delay;
  final double offset;

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll> {
  final _key = UniqueKey();
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    if (KhaoMotion.reduced(context)) return widget.child;
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (info) {
        if (!_shown && info.visibleFraction > 0.05 && mounted) {
          setState(() => _shown = true);
        }
      },
      child: widget.child
          .animate(target: _shown ? 1 : 0)
          .fadeIn(delay: widget.delay, duration: 900.ms, curve: KhaoMotion.ease)
          .moveY(
            delay: widget.delay,
            begin: widget.offset,
            end: 0,
            duration: 900.ms,
            curve: KhaoMotion.ease,
          ),
    );
  }
}

/// Pops [child] from scale 0 → 1 when it scrolls into view (timeline dots).
class PopOnScroll extends StatefulWidget {
  const PopOnScroll({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<PopOnScroll> createState() => _PopOnScrollState();
}

class _PopOnScrollState extends State<PopOnScroll> {
  final _key = UniqueKey();
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    if (KhaoMotion.reduced(context)) return widget.child;
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (info) {
        if (!_shown && info.visibleFraction > 0.4 && mounted) {
          setState(() => _shown = true);
        }
      },
      child: widget.child
          .animate(target: _shown ? 1 : 0)
          .scaleXY(
            delay: widget.delay,
            begin: 0,
            end: 1,
            duration: 600.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}
