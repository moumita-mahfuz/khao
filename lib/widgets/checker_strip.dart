import 'package:flutter/material.dart';

import 'package:visibility_detector/visibility_detector.dart';

import '../theme/khao_theme.dart';

/// Two rows of squares joining two sections; drifts right one tile per 8s.
///
/// Mirrors CSS `repeating-conic-gradient(a 0 25%, b 0 50%)` on a 2×2 tile:
/// top-left [b], top-right [a], bottom-left [a], bottom-right [b].
/// [flipped] mirrors it vertically (`transform: scaleY(-1)`).
class CheckerStrip extends StatefulWidget {
  const CheckerStrip({
    super.key,
    required this.a,
    required this.b,
    this.flipped = false,
  });

  /// brown / black (after the signature section).
  const CheckerStrip.brownBlack({super.key, this.flipped = false})
    : a = KhaoColors.richBrown,
      b = KhaoColors.black;

  /// black / cream.
  const CheckerStrip.blackCream({super.key, this.flipped = false})
    : a = KhaoColors.black,
      b = KhaoColors.cream;

  final Color a;
  final Color b;
  final bool flipped;

  @override
  State<CheckerStrip> createState() => _CheckerStripState();
}

class _CheckerStripState extends State<CheckerStrip>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  final _visKey = UniqueKey();
  bool _visible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  /// Runs the drift only while on screen and motion is allowed.
  void _sync() {
    if (KhaoMotion.reduced(context)) {
      _c
        ..stop()
        ..value = 0;
    } else if (!_visible) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tile = KhaoLayout.isDesktop(context) ? 72.0 : 48.0;
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: (info) {
        if (!mounted) return;
        _visible = info.visibleFraction > 0;
        _sync();
      },
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: SizedBox(
            height: tile,
            width: double.infinity,
            child: CustomPaint(
              painter: _CheckerPainter(
                progress: _c,
                tile: tile,
                a: widget.a,
                b: widget.b,
                flipped: widget.flipped,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  _CheckerPainter({
    required this.progress,
    required this.tile,
    required this.a,
    required this.b,
    required this.flipped,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final double tile;
  final Color a;
  final Color b;
  final bool flipped;

  /// How far the strip paints past its top and bottom edges, overlapping the
  /// neighbouring sections so no background can show between them.
  static const _bleed = 1.0;

  /// At fractional device pixel ratios (Windows 125%/150% scaling, browser
  /// zoom) and fractional scroll offsets, the strip's horizontal edges land
  /// mid-pixel. Anti-aliased, every square's top/bottom edge then blends the
  /// two colours into a grey hairline running along the strip's edges and
  /// its middle. Turning anti-aliasing off fixes that but pixel-snaps the
  /// vertical edges too, so the slow drift (~4.5px/s) steps instead of
  /// gliding.
  ///
  /// So the two are split: each row is a hard (non-anti-aliased) clip, which
  /// gives crisp horizontal edges, and the squares are drawn anti-aliased and
  /// taller than the row, so only their moving vertical edges are smoothed.
  @override
  void paint(Canvas canvas, Size size) {
    final half = tile / 2;
    final pa = Paint()..color = a;
    final area = Rect.fromLTRB(0, -_bleed, size.width, size.height + _bleed);
    canvas.clipRect(area, doAntiAlias: false);
    canvas.drawRect(
      area,
      Paint()
        ..color = b
        ..isAntiAlias = false,
    );

    void row(Rect r, double shift) {
      canvas.save();
      canvas.clipRect(r, doAntiAlias: false);
      for (
        var x = -tile + progress.value * tile + shift;
        x < size.width;
        x += tile
      ) {
        canvas.drawRect(
          Rect.fromLTRB(x, r.top - 1, x + half, r.bottom + 1),
          pa,
        );
      }
      canvas.restore();
    }

    // Unflipped: the top row's squares sit half a tile right of the bottom
    // row's. Flipped mirrors that vertically.
    row(Rect.fromLTRB(0, -_bleed, size.width, half), flipped ? 0 : half);
    row(
      Rect.fromLTRB(0, half, size.width, size.height + _bleed),
      flipped ? half : 0,
    );
  }

  @override
  bool shouldRepaint(_CheckerPainter old) =>
      old.a != a || old.b != b || old.tile != tile || old.flipped != flipped;
}
