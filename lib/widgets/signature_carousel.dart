import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/khao_l10n.dart';
import '../models/menu_models.dart';
import '../models/sections.dart';
import '../theme/khao_theme.dart';
import 'common.dart';
import 'reveal_on_scroll.dart';

/// Section 3: "Signature Bites" header + card carousel on rich brown.
class SignatureSection extends StatelessWidget {
  const SignatureSection({
    super.key,
    required this.menu,
    required this.onNavigate,
  });

  final KhaoMenu menu;
  final SectionNavigator onNavigate;

  @override
  Widget build(BuildContext context) {
    final desktop = KhaoLayout.isDesktop(context);
    final width = MediaQuery.sizeOf(context).width;
    final kicker = LatinText(
      context.tr.signatureKicker,
      size: desktop ? 20 : 17,
      letterSpacing: desktop ? 4 : 3,
      color: KhaoColors.cream.withValues(alpha: 0.75),
      height: 1.2,
    );
    final heading = Text(
      context.tr.signatureHeading,
      style: KhaoText.anek(
        // CSS: clamp(52px, 6.5vw, 100px) / 44px
        desktop ? (width * 0.065).clamp(52.0, 100.0) : 44,
        weight: FontWeight.w800,
        color: KhaoColors.yellow,
        height: desktop ? 0.98 : 1.02,
      ),
    );

    final Widget header;
    if (desktop) {
      header = Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 32,
        runSpacing: 32,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              kicker,
              const SizedBox(height: 10),
              Semantics(header: true, child: heading),
            ],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PixMotif(),
                const SizedBox(width: 24),
                Flexible(
                  child: Text(
                    context.tr.signatureBodyLong,
                    style: KhaoText.hind(
                      17,
                      height: 1.6,
                      color: KhaoColors.cream.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      header = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kicker,
          const SizedBox(height: 6),
          Semantics(header: true, child: heading),
          const SizedBox(height: 14),
          Text(
            context.tr.signatureBodyShort,
            style: KhaoText.hind(
              15,
              height: 1.6,
              color: KhaoColors.cream.withValues(alpha: 0.8),
            ),
          ),
        ],
      );
    }

    return ColoredBox(
      color: KhaoColors.richBrown,
      child: Padding(
        padding: EdgeInsets.only(top: desktop ? 130 : 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ContentWidth(child: RevealOnScroll(child: header)),
            SignatureCarousel(
              items: menu.carouselItems,
              tiers: menu.tiers,
              startIndex: menu.carouselStartIndex,
              onOrder: () => onNavigate(KhaoSection.visit),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4×2 grid of 18px cells, odd cells yellow (two vertical bars).
class _PixMotif extends StatelessWidget {
  const _PixMotif();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 72,
        height: 36,
        child: Row(
          children: [
            for (var i = 0; i < 4; i++)
              Container(
                width: 18,
                height: 36,
                color: i.isEven ? KhaoColors.yellow : null,
              ),
          ],
        ),
      ),
    );
  }
}

/// The carousel itself: 5 cards on desktop (active ±2), 3 on mobile.
class SignatureCarousel extends StatefulWidget {
  const SignatureCarousel({
    super.key,
    required this.items,
    required this.tiers,
    required this.startIndex,
    required this.onOrder,
  });

  final List<MenuItem> items;
  final List<Tier> tiers;
  final int startIndex;
  final VoidCallback onOrder;

  @override
  State<SignatureCarousel> createState() => _SignatureCarouselState();
}

class _SignatureCarouselState extends State<SignatureCarousel> {
  late int _index = widget.startIndex;
  int _tier = 0;

  int get _n => widget.items.length;

  void _go(int delta) => setState(() {
    _index = (_index + delta + _n) % _n;
    _tier = 0; // Changing the slide resets the tier to অল্প.
  });

  @override
  Widget build(BuildContext context) {
    final desktop = KhaoLayout.isDesktop(context);
    final offsets = desktop ? const [-2, -1, 0, 1, 2] : const [-1, 0, 1];
    final active = widget.items[_index];

    final cards = [for (final o in offsets) _slideFor(o, desktop)];

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final (i, c) in cards.indexed) ...[
          if (i > 0) SizedBox(width: desktop ? 22 : 12),
          c,
        ],
      ],
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _go(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _go(1),
      },
      child: Focus(
        child: Column(
          children: [
            Semantics(
              liveRegion: true,
              label:
                  '${active.name}, ${context.tr.taka(_priceOf(active))} — ${context.tr.carouselPosition(_index + 1, _n)}',
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (d) {
                  final v = d.primaryVelocity ?? 0;
                  if (v.abs() > 200) _go(v < 0 ? 1 : -1);
                },
                child: ClipRect(
                  clipBehavior: desktop ? Clip.none : Clip.hardEdge,
                  child: Container(
                    // CSS: min-height 640 (incl. 90 padding-top) / mobile 100.
                    constraints: BoxConstraints(minHeight: desktop ? 640 : 0),
                    padding: EdgeInsets.only(top: desktop ? 90 : 100),
                    alignment: Alignment.bottomCenter,
                    child: OverflowBox(
                      fit: OverflowBoxFit.deferToChild,
                      minWidth: 0,
                      maxWidth: double.infinity,
                      alignment: Alignment.bottomCenter,
                      child: row,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: desktop
                  ? const EdgeInsets.only(top: 36, bottom: 80)
                  : const EdgeInsets.only(top: 28, bottom: 56),
              child: _Controls(
                desktop: desktop,
                count: _n,
                index: _index,
                onPrev: () => _go(-1),
                onNext: () => _go(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _priceOf(MenuItem it) =>
      it.prices[it.hasTiers ? _tier.clamp(0, it.prices.length - 1) : 0];

  Widget _slideFor(int offset, bool desktop) {
    final item = widget.items[(_index + offset + _n) % _n];
    final isActive = offset == 0;
    return _CarouselCard(
      key: ValueKey(item.id),
      item: item,
      desktop: desktop,
      active: isActive,
      far: offset.abs() == 2,
      tiers: widget.tiers,
      tier: _tier,
      price: _priceOf(item),
      onTier: (t) => setState(() => _tier = t),
      onOrder: widget.onOrder,
      onTap: isActive ? null : () => _go(offset),
    );
  }
}

// ---------------------------------------------------------------- card

/// Geometry per state, from the design CSS.
class _CardSpec {
  const _CardSpec({
    required this.width,
    required this.photo,
    required this.overlap,
    required this.topRadius,
    required this.radius,
    required this.lift,
    required this.padH,
    required this.padBottom,
  });

  final double width;
  final double photo;
  final double overlap;
  final double topRadius;
  final double radius;
  final double lift;
  final double padH;
  final double padBottom;

  static const desktopSide = _CardSpec(
    width: 230,
    photo: 170,
    overlap: 70,
    topRadius: 30,
    radius: 30,
    lift: 0,
    padH: 20,
    padBottom: 24,
  );
  static const desktopActive = _CardSpec(
    width: 350,
    photo: 250,
    overlap: 100,
    topRadius: 120,
    radius: 30,
    lift: -24,
    padH: 20,
    padBottom: 24,
  );
  static const mobileSide = _CardSpec(
    width: 150,
    photo: 110,
    overlap: 46,
    topRadius: 26,
    radius: 26,
    lift: 0,
    padH: 12,
    padBottom: 18,
  );
  static const mobileActive = _CardSpec(
    width: 270,
    photo: 190,
    overlap: 80,
    topRadius: 110,
    radius: 26,
    lift: 0,
    padH: 18,
    padBottom: 22,
  );
}

class _CarouselCard extends StatefulWidget {
  const _CarouselCard({
    super.key,
    required this.item,
    required this.desktop,
    required this.active,
    required this.far,
    required this.tiers,
    required this.tier,
    required this.price,
    required this.onTier,
    required this.onOrder,
    this.onTap,
  });

  final MenuItem item;
  final bool desktop;
  final bool active;
  final bool far;
  final List<Tier> tiers;
  final int tier;
  final int price;
  final ValueChanged<int> onTier;
  final VoidCallback onOrder;
  final VoidCallback? onTap;

  @override
  State<_CarouselCard> createState() => _CarouselCardState();
}

class _CarouselCardState extends State<_CarouselCard> {
  bool _hover = false;

  static const _dur = Duration(milliseconds: 550);

  @override
  Widget build(BuildContext context) {
    final reduced = KhaoMotion.reduced(context);
    final dur = reduced ? Duration.zero : _dur;
    final desktop = widget.desktop;
    final side = desktop ? _CardSpec.desktopSide : _CardSpec.mobileSide;
    final act = desktop ? _CardSpec.desktopActive : _CardSpec.mobileActive;
    // Mobile side cards are always dimmed; desktop dims only the far ones.
    final dim = desktop ? widget.far : !widget.active;

    Widget card = TweenAnimationBuilder<double>(
      tween: Tween(end: widget.active ? 1 : 0),
      duration: dur,
      curve: KhaoMotion.ease,
      builder: (context, t, _) {
        double l(double Function(_CardSpec s) f) =>
            lerpDouble(f(side), f(act), t)!;
        final photo = l((s) => s.photo);
        final overlap = l((s) => s.overlap);
        final topR = l((s) => s.topRadius);
        final r = l((s) => s.radius);
        final bg = Color.lerp(KhaoColors.cream, KhaoColors.yellow, t)!;

        return Transform.translate(
          offset: Offset(0, l((s) => s.lift)),
          child: NegativeTopMargin(
            margin: overlap,
            child: SizedBox(
              width: l((s) => s.width),
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.passthrough,
                children: [
                  Positioned.fill(
                    top: overlap,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(topR),
                          bottom: Radius.circular(r),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      l((s) => s.padH),
                      0,
                      l((s) => s.padH),
                      l((s) => s.padBottom),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Photo(
                          item: widget.item,
                          size: photo,
                          desktop: desktop,
                          floating: widget.active && !reduced,
                          hovered: _hover && !reduced,
                        ),
                        _body(context, dur),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    card = TweenAnimationBuilder<double>(
      tween: Tween(end: dim ? 1 : 0),
      duration: dur,
      curve: KhaoMotion.ease,
      builder: (context, f, child) => Opacity(
        opacity: 1 - 0.5 * f,
        child: Transform.scale(scale: 1 - 0.1 * f, child: child),
      ),
      child: card,
    );

    card = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(onTap: widget.onTap, child: card),
    );

    if (reduced) return card;
    // cardIn: plays once when a card first enters the carousel.
    return card
        .animate()
        .fadeIn(duration: (desktop ? 600 : 500).ms, curve: KhaoMotion.ease)
        .moveY(
          begin: desktop ? 30 : 20,
          end: 0,
          duration: (desktop ? 600 : 500).ms,
          curve: KhaoMotion.ease,
        );
  }

  Widget _body(BuildContext context, Duration dur) {
    final desktop = widget.desktop;
    final item = widget.item;
    final active = widget.active;

    final pill = Container(
      margin: EdgeInsets.only(top: desktop ? 18 : 14),
      padding: desktop
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 6)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: KhaoColors.black,
        borderRadius: BorderRadius.circular(desktop ? 10 : 9),
      ),
      child: Text(
        context.tr.fromPrice(item.fromPrice, long: desktop),
        textAlign: TextAlign.center,
        style: KhaoText.anek(desktop ? 15 : 14, color: KhaoColors.yellow),
      ),
    );

    final name = Padding(
      padding: EdgeInsets.only(top: desktop ? 14 : 10, bottom: 4),
      child: Text(
        item.name,
        textAlign: TextAlign.center,
        style: KhaoText.anek(
          desktop ? 24 : 22,
          weight: FontWeight.w800,
          color: KhaoColors.black,
          height: 1.15,
        ),
      ),
    );

    final sub = Text(
      item.subtitle,
      textAlign: TextAlign.center,
      style: KhaoText.hind(
        desktop ? 14 : 13,
        height: 1.45,
        color: KhaoColors.richBrown,
      ),
    );

    final activeBlock = Padding(
      padding: EdgeInsets.only(top: desktop ? 16 : 14),
      // Shrink-to-fit like the CSS flex column, so the mobile order button
      // matches the widest row (the tier selector).
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.hasTiers) ...[
              _TierSelector(
                tiers: widget.tiers,
                selected: widget.tier,
                onSelect: widget.onTier,
                desktop: desktop,
              ),
              SizedBox(height: desktop ? 14 : 12),
            ],
            _SpiceMeter(level: item.spice, desktop: desktop),
            SizedBox(height: desktop ? 14 : 12),
            Text(
              context.tr.taka(widget.price),
              style: KhaoText.anek(
                desktop ? 48 : 42,
                weight: FontWeight.w800,
                color: KhaoColors.black,
                height: 1,
              ),
            ),
            if (!desktop) ...[
              const SizedBox(height: 12),
              Hoverable(
                onTap: widget.onOrder,
                borderRadius: 14,
                style: null,
                semanticLabel: context.tr.order,
                child: Container(
                  height: 48,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: KhaoColors.black,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    context.tr.order,
                    style: KhaoText.anek(16, color: KhaoColors.yellow),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final cta = Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Hoverable(
        onTap: widget.onOrder,
        borderRadius: 12,
        style: HoverStyle.offsetShadow,
        semanticLabel: context.tr.orderItem(item.name),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: KhaoColors.cream,
            border: Border.all(color: KhaoColors.black, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr.order,
                style: KhaoText.anek(14, color: KhaoColors.black),
              ),
              const SizedBox(width: 8),
              KhaoIcons.cart(16, KhaoColors.black),
            ],
          ),
        ),
      ),
    );

    return AnimatedSize(
      duration: dur,
      curve: KhaoMotion.ease,
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          pill,
          name,
          // Mobile side cards show only photo, price pill and name.
          if (desktop || active) sub,
          if (active) activeBlock,
          if (desktop) cta,
        ],
      ),
    );
  }
}

class _Photo extends StatefulWidget {
  const _Photo({
    required this.item,
    required this.size,
    required this.desktop,
    required this.floating,
    required this.hovered,
  });

  final MenuItem item;
  final double size;
  final bool desktop;
  final bool floating;
  final bool hovered;

  @override
  State<_Photo> createState() => _PhotoState();
}

class _PhotoState extends State<_Photo> with SingleTickerProviderStateMixin {
  // floaty: 4s ease-in-out, y 0→−10→0, rotate 0→3°→0
  late final _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_Photo old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.floating) {
      if (!_float.isAnimating) _float.repeat(reverse: true);
    } else {
      _float.animateTo(0, duration: const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final image = item.image;
    final Widget content = image != null
        ? Image.asset(image, fit: BoxFit.cover, semanticLabel: item.name)
        : PhotoPlaceholder(
            tag: context.tr.isBn
                ? item.name
                : item.placeholderTag ?? item.nameEn ?? '',
            tagSize: widget.desktop ? 34 : 28,
            noteSize: widget.desktop ? 11 : 10,
          );
    final lift = widget.desktop ? 10.0 : 8.0;

    // Own layer: the float loops forever and would otherwise repaint the page.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _float,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_float.value);
          return Transform.translate(
            offset: Offset(0, -lift * t),
            child: Transform.rotate(angle: 3 * t * math.pi / 180, child: child),
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: KhaoColors.orange,
            border: Border.all(color: KhaoColors.richBrown, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                offset: Offset(0, widget.desktop ? 18 : 14),
                blurRadius: widget.desktop ? 30 : 24,
              ),
            ],
          ),
          child: ClipOval(
            child: AnimatedScale(
              // .cc:hover .ph { scale(1.1) rotate(5deg) }
              scale: widget.hovered ? 1.1 : 1,
              duration: const Duration(milliseconds: 800),
              curve: KhaoMotion.ease,
              child: AnimatedRotation(
                turns: widget.hovered ? 5 / 360 : 0,
                duration: const Duration(milliseconds: 800),
                curve: KhaoMotion.ease,
                child: SizedBox.expand(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TierSelector extends StatelessWidget {
  const _TierSelector({
    required this.tiers,
    required this.selected,
    required this.onSelect,
    required this.desktop,
  });

  final List<Tier> tiers;
  final int selected;
  final ValueChanged<int> onSelect;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final dur = KhaoMotion.reduced(context)
        ? Duration.zero
        : const Duration(milliseconds: 250);
    return Semantics(
      label: context.tr.size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, t) in tiers.indexed) ...[
            if (i > 0) SizedBox(width: desktop ? 8 : 6),
            // Flexible + scaleDown: long tier names ("ফুচটাক") shrink to fit
            // narrow cards instead of overflowing the row.
            Flexible(
              child: Hoverable(
                onTap: () => onSelect(i),
                borderRadius: 12,
                style: HoverStyle.liftSmall,
                selected: i == selected,
                semanticLabel: '${t.label} · ${t.detail}',
                child: AnimatedContainer(
                  duration: dur,
                  constraints: BoxConstraints(
                    minWidth: desktop ? 64 : 56,
                    minHeight: 44,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: i == selected ? KhaoColors.black : KhaoColors.cream,
                    border: Border.all(color: KhaoColors.black, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        t.short,
                        maxLines: 1,
                        style: KhaoText.anek(
                          14,
                          color: i == selected
                              ? KhaoColors.yellow
                              : KhaoColors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpiceMeter extends StatelessWidget {
  const _SpiceMeter({required this.level, required this.desktop});

  final int level;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr.spiceLevel(level),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr.spice,
              style: KhaoText.anek(desktop ? 14 : 13, color: KhaoColors.black),
            ),
            SizedBox(width: desktop ? 10 : 8),
            for (var k = 0; k < 5; k++) ...[
              if (k > 0) SizedBox(width: desktop ? 4 : 3),
              Container(
                width: desktop ? 16 : 14,
                height: desktop ? 10 : 9,
                decoration: BoxDecoration(
                  color: k < level
                      ? KhaoColors.red
                      : KhaoColors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.desktop,
    required this.count,
    required this.index,
    required this.onPrev,
    required this.onNext,
  });

  final bool desktop;
  final int count;
  final int index;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final dur = KhaoMotion.reduced(context)
        ? Duration.zero
        : const Duration(milliseconds: 300);
    final size = desktop ? 56.0 : 48.0;
    Widget arrow(bool next) => Hoverable(
      onTap: next ? onNext : onPrev,
      style: null,
      semanticLabel: next ? context.tr.next : context.tr.previous,
      builder: (context, hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: size,
        height: size,
        transform: Matrix4.diagonal3Values(
          hovered && desktop ? 1.08 : 1,
          hovered && desktop ? 1.08 : 1,
          1,
        ),
        transformAlignment: Alignment.center,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hovered ? KhaoColors.yellow : Colors.transparent,
          border: Border.all(
            color: hovered ? KhaoColors.yellow : KhaoColors.cream,
            width: 2,
          ),
        ),
        child: (next ? KhaoIcons.chevronRight : KhaoIcons.chevronLeft)(
          desktop ? 22 : 20,
          hovered ? KhaoColors.black : KhaoColors.cream,
        ),
      ),
    );

    final pip = desktop ? 10.0 : 8.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        arrow(false),
        SizedBox(width: desktop ? 28 : 20),
        ExcludeSemantics(
          child: Row(
            children: [
              for (var k = 0; k < count; k++) ...[
                if (k > 0) SizedBox(width: desktop ? 8 : 6),
                AnimatedContainer(
                  duration: dur,
                  width: k == index ? (desktop ? 30 : 24) : pip,
                  height: pip,
                  decoration: BoxDecoration(
                    color: k == index
                        ? KhaoColors.yellow
                        : KhaoColors.cream.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(
                      k == index ? (desktop ? 6 : 5) : pip / 2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: desktop ? 28 : 20),
        arrow(true),
      ],
    );
  }
}

/// CSS-style negative top margin: the child overhangs [margin] px above its
/// layout box, so the overhang doesn't add to the parent's height.
class NegativeTopMargin extends SingleChildRenderObjectWidget {
  const NegativeTopMargin({super.key, required this.margin, super.child});

  final double margin;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderNegativeTopMargin(margin);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderNegativeTopMargin renderObject,
  ) {
    renderObject.margin = margin;
  }
}

class RenderNegativeTopMargin extends RenderShiftedBox {
  RenderNegativeTopMargin(this._margin) : super(null);

  double _margin;
  set margin(double v) {
    if (v == _margin) return;
    _margin = v;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final c = child;
    if (c == null) {
      size = constraints.smallest;
      return;
    }
    c.layout(constraints.loosen(), parentUsesSize: true);
    (c.parentData! as BoxParentData).offset = Offset(0, -_margin);
    size = constraints.constrain(
      Size(c.size.width, math.max(0, c.size.height - _margin)),
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Allow hits on the overhanging part too.
    final c = child;
    if (c == null) return false;
    final offset = (c.parentData! as BoxParentData).offset;
    return result.addWithPaintOffset(
      offset: offset,
      position: position,
      hitTest: (r, p) => c.hitTest(r, position: p),
    );
  }
}
