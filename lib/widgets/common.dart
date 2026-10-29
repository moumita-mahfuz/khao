import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../l10n/khao_l10n.dart';
import '../theme/khao_theme.dart';

/// Inline SVG icons from the design source (24×24 viewBox).
abstract final class KhaoIcons {
  static const _flamePath =
      'M12 2c1 3-1 4.5-1 7 0 1.5 1 2.5 2 2.5s2-1 2-2.5c0-.8-.3-1.6-.6-2.2C16.9 8.6 19 11.3 19 14.5 19 18.6 15.9 22 12 22s-7-3.4-7-7.5C5 9.6 9.6 6.5 12 2z';

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  static Widget _svg(String body, double size) => SvgPicture.string(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">$body</svg>',
    width: size,
    height: size,
  );

  static Widget _stroke(String paths, double size, Color c, double w) => _svg(
    '<g fill="none" stroke="${_hex(c)}" stroke-width="$w" '
    'stroke-linecap="round" stroke-linejoin="round">$paths</g>',
    size,
  );

  static Widget flame(double size, Color color) =>
      _svg('<path fill="${_hex(color)}" d="$_flamePath"/>', size);

  static Widget cart(double size, Color c) => _stroke(
    '<path d="M6 6h15l-1.5 9h-12z"/><path d="M6 6 5 3H2"/>'
    '<circle cx="9" cy="20" r="1.3"/><circle cx="18" cy="20" r="1.3"/>',
    size,
    c,
    2.2,
  );

  static Widget chevronLeft(double size, Color c) =>
      _stroke('<path d="M15 6l-6 6 6 6"/>', size, c, 2.4);

  static Widget chevronRight(double size, Color c) =>
      _stroke('<path d="M9 6l6 6-6 6"/>', size, c, 2.4);

  static Widget arrowRight(double size, Color c) =>
      _stroke('<path d="M5 12h14M13 6l6 6-6 6"/>', size, c, 2.4);

  static Widget burger(double size, Color c) =>
      _stroke('<path d="M4 7h16M4 12h16M4 17h10"/>', size, c, 2.2);

  static Widget close(double size, Color c) =>
      _stroke('<path d="M6 6l12 12M18 6 6 18"/>', size, c, 2.2);

  static Widget pin(double size, Color c) => _stroke(
    '<path d="M12 21s-7-6.5-7-12a7 7 0 0 1 14 0c0 5.5-7 12-7 12z"/>'
    '<circle cx="12" cy="9" r="2.5"/>',
    size,
    c,
    2.2,
  );

  /// Open menu card / book.
  static Widget menuBook(double size, Color c) => _stroke(
    '<path d="M12 6c-2-1.5-5-2-8-1.5v14c3-.5 6 0 8 1.5 2-1.5 5-2 8-1.5v-14c-3-.5-6 0-8 1.5z"/>'
    '<path d="M12 6v14"/><path d="M7 9h2M7 12h2M15 9h2M15 12h2"/>',
    size,
    c,
    1.8,
  );

  /// A samosa sitting in a paper tray.
  static Widget snackBox(double size, Color c) => _stroke(
    '<path d="M12 4 7.5 13h9z"/><path d="M12 4l-1 6"/>'
    '<path d="M3 12l2 7h14l2-7z"/><path d="M3 12h18"/>'
    '<path d="M8 16h1M11.5 16h1M15 16h1"/>',
    size,
    c,
    1.8,
  );

  static Widget calendar(double size, Color c) => _stroke(
    '<rect x="3.5" y="5" width="17" height="15.5" rx="2.5"/>'
    '<path d="M3.5 10h17M8 3v4M16 3v4"/>'
    '<path d="M8 13.5h.01M12 13.5h.01M16 13.5h.01M8 17h.01M12 17h.01M16 17h.01"/>',
    size,
    c,
    2,
  );

  /// Hand-drawn arrow curving down to the bottom-left.
  static Widget curvedArrow(double size, Color c) => _stroke(
    '<path d="M21 3c-7 1-12 6-14 15"/><path d="M3.5 14.5 7 18.5l4.5-3"/>',
    size,
    c,
    1.8,
  );

  static Widget check(double size, Color c) =>
      _stroke('<path d="M6 12.5l4 4 8-9"/>', size, c, 3);

  static Widget crown(double size, Color c) => _stroke(
    '<path d="M4 18h16"/><path d="M4.5 15.5 3 7l5 4 4-6 4 6 5-4-1.5 8.5z"/>',
    size,
    c,
    1.8,
  );

  static Widget phone(double size, Color c) => _stroke(
    '<path d="M5 4h4l2 5-2.5 1.5a11 11 0 0 0 5 5L15 13l5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2"/>',
    size,
    c,
    2,
  );
}

/// Isolates a looping animation on its own layer so it doesn't repaint the
/// rest of the page every frame, and pauses its tickers while off screen.
class AnimateWhileVisible extends StatefulWidget {
  const AnimateWhileVisible({super.key, required this.child});

  final Widget child;

  @override
  State<AnimateWhileVisible> createState() => _AnimateWhileVisibleState();
}

class _AnimateWhileVisibleState extends State<AnimateWhileVisible> {
  final _key = UniqueKey();
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0;
        if (visible != _visible && mounted) setState(() => _visible = visible);
      },
      child: TickerMode(
        enabled: _visible,
        child: RepaintBoundary(child: widget.child),
      ),
    );
  }
}

/// Centers content at max 1440 with the responsive side padding.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.horizontal});

  final Widget child;

  /// Overrides the default side padding (56 desktop / 16 mobile).
  final double? horizontal;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: KhaoLayout.maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontal ?? KhaoLayout.sidePad(context),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Hover effect styles used by buttons in the design.
enum HoverStyle {
  /// `.btn:hover { translateY(-3px) }`
  lift,

  /// `.cta:hover { translate(-2px,-2px); box-shadow: 4px 4px 0 #111 }`
  offsetShadow,

  /// `.sz:hover { translateY(-2px) }`
  liftSmall,
}

/// Tappable wrapper that adds the design's hover motion, a pointer cursor,
/// keyboard focus/activation and a visible focus ring.
class Hoverable extends StatefulWidget {
  const Hoverable({
    super.key,
    this.child,
    this.builder,
    this.onTap,
    this.style = HoverStyle.lift,
    this.borderRadius = 999,
    this.semanticLabel,
    this.selected,
  }) : assert(child != null || builder != null);

  final Widget? child;

  /// Alternative to [child] when the look depends on hover state.
  final Widget Function(BuildContext context, bool hovered)? builder;
  final VoidCallback? onTap;
  final HoverStyle? style;
  final double borderRadius;
  final String? semanticLabel;
  final bool? selected;

  @override
  State<Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<Hoverable> {
  bool _hover = false;
  bool _focus = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduced = KhaoMotion.reduced(context);
    final on = _hover && !reduced;
    final offset = switch (widget.style) {
      HoverStyle.lift => const Offset(0, -3),
      HoverStyle.liftSmall => const Offset(0, -2),
      HoverStyle.offsetShadow => const Offset(-2, -2),
      null => Offset.zero,
    };
    final shadow = widget.style == HoverStyle.offsetShadow && on
        ? [const BoxShadow(color: KhaoColors.black, offset: Offset(4, 4))]
        : const <BoxShadow>[];
    final child = widget.builder?.call(context, _hover) ?? widget.child!;

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hover = v),
        onShowFocusHighlight: (v) => setState(() => _focus = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed && !reduced ? 0.97 : 1,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: reduced
                  ? Duration.zero
                  : const Duration(milliseconds: 250),
              curve: KhaoMotion.ease,
              transform: Matrix4.translationValues(
                on ? offset.dx : 0,
                on ? offset.dy : 0,
                0,
              ),
              foregroundDecoration: _focus
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius + 3,
                      ),
                      border: Border.all(
                        color: KhaoColors.orange,
                        width: 3,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    )
                  : null,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: shadow,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill button (filled or outlined) with Anek Bangla 700 label.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.background,
    this.foreground = KhaoColors.black,
    this.borderColor,
    this.height = 56,
    this.horizontalPadding = 32,
    this.fontSize = 18,
    this.leading,
    this.trailing,
    this.expand = false,
    this.latin = false,
    this.letterSpacing,
  });

  final String label;
  final VoidCallback onTap;
  final Color? background;
  final Color foreground;
  final Color? borderColor;
  final double height;
  final double horizontalPadding;
  final double fontSize;
  final Widget? leading;
  final Widget? trailing;
  final bool expand;

  /// Use Bebas Neue (Latin labels like "ORDER NOW").
  final bool latin;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    final text = latin
        ? LatinText(
            label,
            size: fontSize,
            color: foreground,
            letterSpacing: letterSpacing,
            height: 1,
          )
        : Text(
            label,
            style: KhaoText.anek(fontSize, color: foreground, height: 1.2),
          );
    return Hoverable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: borderColor == null
              ? null
              : Border.all(color: borderColor!, width: 2),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            text,
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ),
    );
  }
}

/// A CSS-style dashed line (horizontal or vertical).
class DashedLine extends StatelessWidget {
  const DashedLine({
    super.key,
    required this.color,
    this.thickness = 1,
    this.dash,
    this.gap,
    this.axis = Axis.horizontal,
  });

  final Color color;
  final double thickness;
  final double? dash;
  final double? gap;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final horizontal = axis == Axis.horizontal;
    return SizedBox(
      height: horizontal ? thickness : null,
      width: horizontal ? null : thickness,
      child: CustomPaint(
        painter: _DashPainter(
          color: color,
          thickness: thickness,
          // Matches Chrome: thin borders 3/3, thicker ones 2w dash / 1w gap.
          dash: dash ?? (thickness < 2 ? 3 : thickness * 2),
          gap: gap ?? (thickness < 2 ? 3 : thickness),
          axis: axis,
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter({
    required this.color,
    required this.thickness,
    required this.dash,
    required this.gap,
    required this.axis,
  });

  final Color color;
  final double thickness;
  final double dash;
  final double gap;
  final Axis axis;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final length = axis == Axis.horizontal ? size.width : size.height;
    for (var x = 0.0; x < length; x += dash + gap) {
      final d = (x + dash).clamp(0, length) - x;
      canvas.drawRect(
        axis == Axis.horizontal
            ? Rect.fromLTWH(x, 0, d, thickness)
            : Rect.fromLTWH(0, x, thickness, d),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) =>
      old.color != color || old.dash != dash || old.gap != gap;
}

/// Orange circle with a Bebas tag and "[ছবি দরকার]" for items without photos.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    required this.tag,
    this.tagSize = 34,
    this.noteSize = 11,
  });

  final String tag;
  final double tagSize;
  final double noteSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KhaoColors.orange,
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LatinText(tag, size: tagSize, color: KhaoColors.black, height: 0.9),
            const SizedBox(height: 6),
            Text(
              context.tr.photoNeeded,
              style: KhaoText.hind(noteSize, color: KhaoColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
