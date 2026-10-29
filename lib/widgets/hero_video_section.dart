import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../l10n/khao_l10n.dart';
import '../models/sections.dart';
import '../pages/menu_pdf_page.dart';
import '../theme/khao_theme.dart';
import 'common.dart';

/// Section 1: full-bleed looping video with headline, nav and badge.
class HeroVideoSection extends StatefulWidget {
  const HeroVideoSection({super.key, required this.onNavigate});

  static const desktopHeight = 900.0;
  static const mobileHeight = 760.0;

  /// Includes the top safe-area inset (status bar / notch) so the video
  /// still bleeds behind it while the content keeps its designed height.
  static double heightFor(BuildContext context) =>
      (KhaoLayout.isDesktop(context) ? desktopHeight : mobileHeight) +
      MediaQuery.paddingOf(context).top;

  final SectionNavigator onNavigate;

  @override
  State<HeroVideoSection> createState() => _HeroVideoSectionState();
}

class _HeroVideoSectionState extends State<HeroVideoSection> {
  bool _menuOpen = false;

  void _go(KhaoSection s) {
    setState(() => _menuOpen = false);
    widget.onNavigate(s);
  }

  void _openMenuPage() {
    setState(() => _menuOpen = false);
    MenuPdfPage.open(context);
  }

  /// Nav items shared by the desktop bar and the mobile dropdown:
  /// Menu opens the full menu page; the rest scroll to their section.
  List<(String, VoidCallback)> _navItems(KhaoStrings t) => [
    for (final (label, _, onTap) in _navEntries(t)) (label, onTap),
  ];

  /// Same items with the icon the mobile dropdown shows beside each.
  List<(String, Widget Function(double, Color), VoidCallback)> _navEntries(
    KhaoStrings t,
  ) => [
    (t.navMenu, KhaoIcons.menuBook, _openMenuPage),
    (t.navQuickBites, KhaoIcons.snackBox, () => _go(KhaoSection.menu)),
    (t.dayTitle, KhaoIcons.calendar, () => _go(KhaoSection.daypart)),
    (t.navFindUs, KhaoIcons.pin, () => _go(KhaoSection.visit)),
  ];

  @override
  Widget build(BuildContext context) {
    final desktop = KhaoLayout.isDesktop(context);
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: HeroVideoSection.heightFor(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _HeroVideo(desktop: desktop),
          _Scrim(desktop: desktop),
          Positioned(
            left: desktop ? 56 : 16,
            right: desktop ? 56 : 16,
            bottom: desktop ? 72 : 48,
            child: _HeroContent(desktop: desktop, onNavigate: _go),
          ),
          Positioned(
            top: topInset,
            left: 0,
            right: 0,
            child: _TopBar(
              desktop: desktop,
              menuOpen: _menuOpen,
              onToggleMenu: () => setState(() => _menuOpen = !_menuOpen),
              items: _navItems(context.tr),
            ),
          ),
          if (!desktop && _menuOpen)
            Positioned(
              top: topInset + 76,
              left: 12,
              right: 12,
              child: _DropdownNav(items: _navEntries(context.tr)),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- video

class _HeroVideo extends StatefulWidget {
  const _HeroVideo({required this.desktop});

  /// Desktop and mobile play different cuts of the hero video.
  final bool desktop;

  @override
  State<_HeroVideo> createState() => _HeroVideoState();
}

class _HeroVideoState extends State<_HeroVideo> {
  static const _poster = 'assets/video/hero-poster.jpg';
  static const _desktopVideo = 'assets/video/hero-desktop.mp4';
  // Renamed with each new cut so browsers/CDNs don't serve a cached copy.
  static const _mobileVideo = 'assets/video/hero-mobile.mp4';
  VideoPlayerController? _controller;
  bool _ready = false;
  bool? _reduced;

  /// Off screen the video is paused and its platform view dropped, so the
  /// browser doesn't keep compositing it while the rest of the page scrolls.
  bool _hidden = false;
  final _visKey = UniqueKey();

  void _onVisibility(VisibilityInfo info) {
    final hidden = info.visibleFraction == 0;
    if (hidden == _hidden || !mounted) return;
    setState(() => _hidden = hidden);
    final c = _controller;
    if (c == null || !_ready || _reduced == true) return;
    hidden ? c.pause() : c.play();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = KhaoMotion.reduced(context);
    if (reduced == _reduced) return;
    _reduced = reduced;
    if (reduced) {
      // Reduced motion: no looping video, the poster is the end state.
      _controller?.pause();
    } else {
      _start();
    }
  }

  @override
  void didUpdateWidget(_HeroVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.desktop == widget.desktop) return;
    // Crossed the breakpoint: swap to the other layout's video.
    _controller?.dispose();
    _controller = null;
    _ready = false;
    if (_reduced != true) _start();
  }

  Future<void> _start() async {
    if (_controller != null) {
      if (_ready) await _controller!.play();
      return;
    }
    final c = VideoPlayerController.asset(
      widget.desktop ? _desktopVideo : _mobileVideo,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = c;
    try {
      await c.initialize();
      // Web autoplay policy: must be muted *before* play().
      await c.setVolume(0);
      await c.setLooping(true);
      // Swapped out (breakpoint crossed) or disposed while loading.
      if (!mounted || _controller != c) return;
      if (_reduced != true && !_hidden) await c.play();
      setState(() => _ready = true);
    } catch (_) {
      // Keep the poster if the video can't load.
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = KhaoMotion.reduced(context);
    final c = _controller;
    Widget media = Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(_poster, fit: BoxFit.cover),
        if (_ready && c != null && !reduced && !_hidden)
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: c.value.size.width,
              height: c.value.size.height,
              child: VideoPlayer(c),
            ),
          ),
      ],
    );
    if (!reduced) {
      media = media.animate().scaleXY(
        begin: 1.12,
        end: 1,
        duration: 2400.ms,
        curve: KhaoMotion.ease,
      );
    }
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: _onVisibility,
      child: ClipRect(child: ExcludeSemantics(child: media)),
    );
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final k = KhaoColors.black;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: desktop
                ? [
                    k.withValues(alpha: 0.7),
                    k.withValues(alpha: 0.1),
                    k.withValues(alpha: 0.35),
                    k.withValues(alpha: 0.95),
                  ]
                : [
                    k.withValues(alpha: 0.75),
                    k.withValues(alpha: 0.1),
                    k.withValues(alpha: 0.4),
                    k.withValues(alpha: 0.97),
                  ],
            stops: desktop ? const [0, 0.35, 0.6, 1] : const [0, 0.28, 0.52, 1],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- top bar

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.desktop,
    required this.menuOpen,
    required this.onToggleMenu,
    required this.items,
  });

  final bool desktop;
  final bool menuOpen;
  final VoidCallback onToggleMenu;
  final List<(String, VoidCallback)> items;

  @override
  Widget build(BuildContext context) {
    final logo = Semantics(
      label: "KHAO logo",
      image: true,
      child: Image.asset(
        'assets/logo/logo-on-dark.png',
        height: desktop ? 64 : 48,
        filterQuality: FilterQuality.high,
      ),
    );

    if (!desktop) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            logo,
            const Spacer(),
            const _LangToggle(desktop: false),
            const SizedBox(width: 8),
            Hoverable(
              onTap: onToggleMenu,
              borderRadius: 14,
              style: HoverStyle.liftSmall,
              semanticLabel: menuOpen
                  ? context.tr.closeMenu
                  : context.tr.openMenu,
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: KhaoColors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: KhaoColors.cream.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: menuOpen
                    ? KhaoIcons.close(22, KhaoColors.cream)
                    : KhaoIcons.burger(22, KhaoColors.cream),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 24),
      child: Row(
        children: [
          logo,
          const Spacer(),
          for (final (i, (label, onTap)) in items.indexed) ...[
            if (i > 0) const SizedBox(width: 36),
            _NavLink(label: label, onTap: onTap),
          ],
          const Spacer(),
          const _LangToggle(desktop: true),
        ],
      ),
    );
  }
}

/// One-tap language switch in the top bar, styled as the yellow ORDER pill.
/// Shows the language you'd switch *to* ("EN" on the Bangla site, "বাং" on
/// the English one).
class _LangToggle extends StatelessWidget {
  const _LangToggle({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final size = desktop ? 48.0 : 44.0;
    return Hoverable(
      onTap: KhaoL10n.controllerOf(context).toggle,
      semanticLabel: t.langToggleSemantic,
      child: Container(
        height: size,
        constraints: BoxConstraints(minWidth: size + 16),
        padding: EdgeInsets.symmetric(horizontal: desktop ? 24 : 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: KhaoColors.yellow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: LatinText(
          t.langToggleLabel,
          size: desktop ? 22 : 19,
          letterSpacing: 1,
          color: KhaoColors.black,
          height: 1,
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
            child: Text(
              widget.label,
              style: KhaoText.anek(
                17,
                weight: FontWeight.w600,
                color: _hover ? KhaoColors.yellow : KhaoColors.cream,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownNav extends StatelessWidget {
  const _DropdownNav({required this.items});

  final List<(String, Widget Function(double, Color), VoidCallback)> items;

  @override
  Widget build(BuildContext context) {
    final reduced = KhaoMotion.reduced(context);
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.only(left: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, (label, icon, onTap)) in items.indexed) ...[
              if (i > 0) const SizedBox(height: 12),
              _DropdownCard(
                label: label,
                icon: icon,
                onTap: onTap,
                highlighted: i == 0,
                index: i,
                reduced: reduced,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One rounded card in the mobile dropdown: icon disc, label, chevron.
/// The first card is yellow, the rest cream.
class _DropdownCard extends StatelessWidget {
  const _DropdownCard({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.highlighted,
    required this.index,
    required this.reduced,
  });

  static const _paleYellow = Color(0xFFFFEFA8);

  final String label;
  final Widget Function(double, Color) icon;
  final VoidCallback onTap;
  final bool highlighted;
  final int index;
  final bool reduced;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    Widget card = Semantics(
      link: true,
      child: Container(
        decoration: BoxDecoration(
          color: highlighted ? KhaoColors.yellow : KhaoColors.cream,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: KhaoColors.black.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _cardContent(radius),
      ),
    );
    if (!reduced) {
      card = card
          .animate(delay: (60 * index).ms)
          .fadeIn(duration: 350.ms, curve: KhaoMotion.ease)
          .moveY(begin: -12, end: 0, duration: 350.ms, curve: KhaoMotion.ease);
    }
    return card;
  }

  Widget _cardContent(BorderRadius radius) {
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: highlighted
                    ? KhaoColors.cream.withValues(alpha: 0.55)
                    : _paleYellow,
                shape: BoxShape.circle,
              ),
              child: icon(21, KhaoColors.black),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: KhaoText.anek(
                  height: 1,
                  15,
                  weight: FontWeight.w700,
                  color: KhaoColors.black,
                ),
              ),
            ),
            KhaoIcons.chevronRight(21, KhaoColors.black),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- content

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.desktop, required this.onNavigate});

  final bool desktop;
  final SectionNavigator onNavigate;

  @override
  Widget build(BuildContext context) {
    final reduced = KhaoMotion.reduced(context);
    final width = MediaQuery.sizeOf(context).width;
    // CSS: clamp(64px, 10vw, 156px)
    final h1 = desktop ? (width * 0.10).clamp(64.0, 156.0) : 66.0;

    Widget fadeUp(Widget w, Duration delay) => reduced
        ? w
        : w
              .animate(delay: delay)
              .fadeIn(duration: 1.seconds, curve: KhaoMotion.ease)
              .moveY(
                begin: desktop ? 24 : 20,
                end: 0,
                duration: 1.seconds,
                curve: KhaoMotion.ease,
              );

    Widget line(String text, Color color, Duration delay) {
      // scaleDown: the English lines are wider than the Bangla ones.
      final t = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          softWrap: false,
          style: KhaoText.anek(
            h1,
            weight: FontWeight.w800,
            color: color,
            height: desktop ? 0.95 : 0.98,
            letterSpacing: desktop ? -1 : null,
          ),
        ),
      );
      // `.ln { overflow: hidden; padding-bottom: .06em }` + lineUp.
      return ClipRect(
        child: Padding(
          padding: EdgeInsets.only(bottom: h1 * 0.06),
          child: reduced
              ? t
              : t
                    .animate(delay: delay)
                    .slideY(
                      begin: 1.1,
                      end: 0,
                      duration: 1100.ms,
                      curve: KhaoMotion.ease,
                    ),
        ),
      );
    }

    final pill = Container(
      padding: desktop
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: KhaoColors.cream.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KhaoIcons.flame(desktop ? 16 : 14, KhaoColors.orange),
          SizedBox(width: desktop ? 10 : 8),
          LatinText(
            desktop ? context.tr.nowOpenLong : context.tr.nowOpenShort,
            size: desktop ? 18 : 15,
            letterSpacing: desktop ? 2 : 1.5,
            color: KhaoColors.yellow,
            height: 1.2,
          ),
        ],
      ),
    );

    final para = Text(
      desktop ? context.tr.heroBodyLong : context.tr.heroBodyShort,
      style: KhaoText.hind(
        desktop ? 20 : 16,
        height: 1.6,
        color: KhaoColors.cream.withValues(alpha: 0.88),
      ),
    );

    final menuBtn = PillButton(
      label: context.tr.seeMenu,
      background: KhaoColors.orange,
      height: desktop ? 56 : 54,
      expand: !desktop,
      onTap: () => MenuPdfPage.open(context),
    );
    final whereBtn = PillButton(
      label: context.tr.whereAreWe,
      foreground: KhaoColors.cream,
      borderColor: KhaoColors.cream,
      height: desktop ? 56 : 54,
      expand: !desktop,
      onTap: () => onNavigate(KhaoSection.visit),
    );

    final text = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          fadeUp(pill, 600.ms),
          SizedBox(height: desktop ? 24 : 18),
          Semantics(
            header: true,
            label: context.tr.tagline,
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  line(context.tr.taglineLine1, KhaoColors.cream, 150.ms),
                  line(context.tr.taglineLine2, KhaoColors.yellow, 320.ms),
                ],
              ),
            ),
          ),
          SizedBox(height: desktop ? 28 : 16),
          fadeUp(
            desktop
                ? ConstrainedBox(
                    // CSS max-width 560; +4% because CanvasKit sets Hind
                    // Siliguri ~4% wider than hinted Chrome text, which would
                    // otherwise wrap the paragraph to a third line.
                    constraints: const BoxConstraints(maxWidth: 584),
                    child: para,
                  )
                : para,
            600.ms,
          ),
          SizedBox(height: desktop ? 32 : 22),
          fadeUp(
            desktop
                ? Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [menuBtn, whereBtn],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [menuBtn, const SizedBox(height: 10), whereBtn],
                  ),
            800.ms,
          ),
        ],
      ),
    );

    if (!desktop) return text;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Align(alignment: Alignment.bottomLeft, child: text),
        ),
        const SizedBox(width: 40),
        const AnimateWhileVisible(child: _Badge()),
      ],
    );
  }
}

// ---------------------------------------------------------------- badge

/// 190px rotating "GOOD FOOD · BETTER MOOD" ring with a flickering flame.
class _Badge extends StatefulWidget {
  const _Badge();

  @override
  State<_Badge> createState() => _BadgeState();
}

class _BadgeState extends State<_Badge> with TickerProviderStateMixin {
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  );
  late final _flick = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (KhaoMotion.reduced(context)) {
      _spin.stop();
      _flick.stop();
    } else {
      if (!_spin.isAnimating) _spin.repeat();
      if (!_flick.isAnimating) _flick.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _flick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 190,
        height: 190,
        child: Stack(
          children: [
            Positioned.fill(
              child: RotationTransition(
                turns: _spin,
                child: const CustomPaint(painter: _RingTextPainter()),
              ),
            ),
            Positioned.fill(
              left: 52,
              top: 52,
              right: 52,
              bottom: 52,
              child: Container(
                decoration: const BoxDecoration(
                  color: KhaoColors.yellow,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: AnimatedBuilder(
                  animation: _flick,
                  builder: (context, child) {
                    // flick: scale 1→1.08, rotate −2°→3°, ease-in-out
                    final t = Curves.easeInOut.transform(_flick.value);
                    return Transform(
                      alignment: const Alignment(0, 0.8),
                      transform: Matrix4.identity()
                        ..rotateZ((-2 + 5 * t) * math.pi / 180)
                        ..scaleByDouble(1 + 0.08 * t, 1 + 0.08 * t, 1, 1),
                      child: child,
                    );
                  },
                  child: KhaoIcons.flame(44, KhaoColors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws text along a circle, starting at 9 o'clock and running clockwise
/// over the top, like SVG `<textPath>` on the design's ring path. Text that
/// doesn't fit the circumference is dropped, as in the browser.
class _RingTextPainter extends CustomPainter {
  const _RingTextPainter();

  static const _text = 'GOOD FOOD · BETTER MOOD · GOOD FOOD · BETTER MOOD ·';

  @override
  void paint(Canvas canvas, Size size) {
    // SVG viewBox is 200; ring radius 78, font 21, letter-spacing 5.
    final scale = size.width / 200;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    const r = 78.0;
    const circumference = 2 * math.pi * r;
    final style = KhaoText.bebas(21, color: KhaoColors.cream);
    var s = 0.0;
    for (final ch in _text.characters) {
      final tp = TextPainter(
        text: TextSpan(text: ch, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      final mid = s + tp.width / 2;
      if (mid > circumference) break;
      // Angle measured from 9 o'clock, clockwise.
      final a = math.pi + mid / r;
      canvas.save();
      canvas.translate(r * math.cos(a), r * math.sin(a));
      canvas.rotate(a + math.pi / 2);
      // Baseline sits on the path.
      tp.paint(
        canvas,
        Offset(
          -tp.width / 2,
          -tp.computeDistanceToActualBaseline(TextBaseline.alphabetic),
        ),
      );
      canvas.restore();
      s += tp.width + 5;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RingTextPainter oldDelegate) => false;
}
