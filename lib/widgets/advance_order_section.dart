import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/links.dart';
import '../l10n/khao_l10n.dart';
import '../models/menu_models.dart';
import '../theme/khao_theme.dart';
import 'common.dart';
import 'reveal_on_scroll.dart';

/// "অগ্রিম অর্ডার": dishes taken by advance order only (minimum 5), on the
/// same cream background the day timeline used. A photo card with a
/// "minimum 5" sticker beside a brown price list with a call button.
class AdvanceOrderSection extends StatelessWidget {
  const AdvanceOrderSection({super.key, required this.menu});

  final KhaoMenu menu;

  @override
  Widget build(BuildContext context) {
    final desktop = KhaoLayout.isDesktop(context);
    final width = MediaQuery.sizeOf(context).width;
    final items = menu.advanceOrderItems;
    if (items.isEmpty) return const SizedBox.shrink();
    final t = context.tr;

    final heading = RevealOnScroll(
      child: Column(
        children: [
          Text(
            t.advanceKicker,
            textAlign: TextAlign.center,
            style: KhaoText.galada(
              desktop ? 30 : 24,
              color: KhaoColors.darkRed,
            ),
          ),
          SizedBox(height: desktop ? 4 : 2),
          Semantics(
            header: true,
            child: Text(
              t.advanceTitle,
              textAlign: TextAlign.center,
              style: KhaoText.anek(
                desktop ? (width * 0.055).clamp(48.0, 84.0) : 42,
                weight: FontWeight.w800,
                color: KhaoColors.black,
                height: desktop ? 1 : 1.05,
              ),
            ),
          ),
          SizedBox(height: desktop ? 16 : 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              t.advanceBody,
              textAlign: TextAlign.center,
              style: KhaoText.hind(
                desktop ? 18 : 15,
                height: 1.6,
                color: KhaoColors.bodyOnCream,
              ),
            ),
          ),
        ],
      ),
    );

    // Slideshow photos; falls back to the first dish photo.
    final gallery = menu.advanceGallery.isNotEmpty
        ? menu.advanceGallery
        : [
            for (final i in items)
              if (i.image != null) i.image!,
          ].take(1).toList();

    final list = _PriceList(
      items: items,
      phone: menu.contact.phone,
      desktop: desktop,
    );

    final Widget body;
    if (desktop) {
      // The list sets the height; the photo is overlaid at the same height
      // (rather than IntrinsicHeight, which mis-measures text on web).
      body = LayoutBuilder(
        builder: (context, c) {
          const gap = 40.0;
          final photoW = (c.maxWidth - gap) * 5 / 11;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: photoW + gap),
                  Expanded(
                    child: RevealOnScroll(
                      delay: const Duration(milliseconds: 120),
                      child: list,
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: photoW,
                child: RevealOnScroll(
                  child: _PhotoCard(
                    images: gallery,
                    alt: t.advanceTitle,
                    desktop: true,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RevealOnScroll(
            child: SizedBox(
              height: 300,
              child: _PhotoCard(
                images: gallery,
                alt: t.advanceTitle,
                desktop: false,
              ),
            ),
          ),
          const SizedBox(height: 24),
          RevealOnScroll(child: list),
        ],
      );
    }

    return ColoredBox(
      color: KhaoColors.cream,
      child: ContentWidth(
        horizontal: desktop ? 64 : 16,
        child: Padding(
          padding: desktop
              ? const EdgeInsets.only(top: 120, bottom: 130)
              : const EdgeInsets.only(top: 72, bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heading,
              SizedBox(height: desktop ? 64 : 40),
              body,
            ],
          ),
        ),
      ),
    );
  }
}

/// Fills its parent: a crossfading photo slideshow with a slow zoom on each
/// slide, dot indicators, and a tilted red "minimum 5" sticker. Pauses on
/// hover; shows only the first photo when motion is reduced.
class _PhotoCard extends StatefulWidget {
  const _PhotoCard({
    required this.images,
    required this.alt,
    required this.desktop,
  });

  final List<String> images;
  final String alt;
  final bool desktop;

  @override
  State<_PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<_PhotoCard> {
  static const _interval = Duration(milliseconds: 4500);
  static const _fade = Duration(milliseconds: 900);

  int _index = 0;
  bool _hover = false;
  Timer? _timer;

  bool get _canPlay =>
      widget.images.length > 1 && !KhaoMotion.reduced(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Warm the cache so each crossfade starts with the photo decoded.
    for (final img in widget.images) {
      precacheImage(AssetImage(img), context);
    }
    _restart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restart() {
    _timer?.cancel();
    _timer = _canPlay
        ? Timer.periodic(_interval, (_) {
            if (!_hover) _go(_index + 1);
          })
        : null;
  }

  void _go(int i) {
    if (!mounted || widget.images.isEmpty) return;
    setState(() => _index = i % widget.images.length);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = KhaoMotion.reduced(context);
    final radius = widget.desktop ? 24.0 : 20.0;
    final sticker = widget.desktop ? 128.0 : 92.0;
    final images = widget.images;
    final index = images.isEmpty ? 0 : _index % images.length;

    Widget slide(String img) {
      final image = Image.asset(
        img,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.medium,
        semanticLabel: widget.alt,
      );
      if (reduced) return image;
      // Slow "Ken Burns" push-in while the slide is showing.
      return TweenAnimationBuilder<double>(
        key: ValueKey(img),
        tween: Tween(begin: 1, end: 1.08),
        duration: _interval + _fade,
        curve: Curves.easeOut,
        builder: (_, s, child) => Transform.scale(scale: s, child: child),
        child: image,
      );
    }

    final photo = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: KhaoColors.black, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - 2),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (images.isEmpty)
                const PhotoPlaceholder(tag: 'PRE-ORDER')
              else
                AnimatedSwitcher(
                  duration: reduced ? Duration.zero : _fade,
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  layoutBuilder: (current, previous) => Stack(
                    fit: StackFit.expand,
                    children: [...previous, ?current],
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(index),
                    child: slide(images[index]),
                  ),
                ),
              // Soft shade at the bottom so the dots stay readable.
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 90,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0x8C000000)],
                      ),
                    ),
                  ),
                ),
              ),
              if (images.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: widget.desktop ? 18 : 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < images.length; i++)
                        Semantics(
                          button: true,
                          selected: i == index,
                          label: '${i + 1}/${images.length}',
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _go(i);
                              _restart();
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 8,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: KhaoMotion.ease,
                                  width: i == index ? 26 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == index
                                        ? KhaoColors.yellow
                                        : KhaoColors.cream.withValues(
                                            alpha: 0.6,
                                          ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        photo,
        Positioned(
          top: -sticker * 0.25,
          right: -sticker * (widget.desktop ? 0.25 : 0.1),
          width: sticker,
          height: sticker,
          child: Transform.rotate(
            angle: -8 * math.pi / 180,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KhaoColors.red,
                shape: BoxShape.circle,
                border: Border.all(color: KhaoColors.black, width: 3),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  context.tr.advanceMinimum.replaceFirst(' ', '\n'),
                  textAlign: TextAlign.center,
                  style: KhaoText.anek(
                    widget.desktop ? 26 : 20,
                    weight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.05,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Brown card listing each dish and its per-plate price, with a call button.
class _PriceList extends StatelessWidget {
  const _PriceList({
    required this.items,
    required this.phone,
    required this.desktop,
  });

  final List<MenuItem> items;
  final String phone;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final nameStyle = KhaoText.anek(
      desktop ? 22 : 18,
      weight: FontWeight.w600,
      color: KhaoColors.cream,
      height: 1.3,
    );
    final priceStyle = KhaoText.anek(
      desktop ? 24 : 20,
      weight: FontWeight.w800,
      color: KhaoColors.yellow,
      height: 1.2,
    );

    return Container(
      padding: EdgeInsets.all(desktop ? 32 : 22),
      decoration: BoxDecoration(
        color: KhaoColors.richBrown,
        borderRadius: BorderRadius.circular(desktop ? 24 : 20),
        border: Border.all(color: KhaoColors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              KhaoIcons.flame(desktop ? 22 : 18, KhaoColors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.advanceMinimum,
                  style: KhaoText.anek(
                    desktop ? 18 : 16,
                    weight: FontWeight.w700,
                    color: KhaoColors.yellow,
                  ),
                ),
              ),
              Text(
                t.advancePerPlate,
                style: KhaoText.hind(
                  desktop ? 15 : 13,
                  color: KhaoColors.cream.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DashedLine(color: KhaoColors.cream.withValues(alpha: 0.35)),
          for (final it in items) ...[
            SizedBox(height: desktop ? 14 : 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(it.name, style: nameStyle)),
                const SizedBox(width: 16),
                Text(t.taka(it.price), style: priceStyle),
              ],
            ),
            SizedBox(height: desktop ? 14 : 12),
            DashedLine(color: KhaoColors.cream.withValues(alpha: 0.2)),
          ],
          SizedBox(height: desktop ? 22 : 18),
          Text(
            t.advanceNotOnFoodpanda,
            textAlign: desktop ? TextAlign.start : TextAlign.center,
            style: KhaoText.hind(
              desktop ? 15 : 14,
              height: 1.5,
              color: KhaoColors.cream.withValues(alpha: 0.75),
            ),
          ),
          SizedBox(height: desktop ? 18 : 14),
          Align(
            alignment: desktop ? Alignment.centerLeft : Alignment.center,
            child: PillButton(
              label: t.advanceCta,
              background: KhaoColors.yellow,
              horizontalPadding: desktop ? 30 : 22,
              expand: !desktop,
              leading: KhaoIcons.phone(18, KhaoColors.black),
              onTap: () => KhaoLinks.call(context, phone),
            ),
          ),
        ],
      ),
    );
  }
}
