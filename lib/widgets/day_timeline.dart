import 'package:flutter/material.dart';

import '../l10n/khao_l10n.dart';
import '../models/menu_models.dart';
import '../theme/khao_theme.dart';
import 'common.dart';
import 'reveal_on_scroll.dart';

/// Section 7: "KHAO-এর একটা দিন" — lunch, evening, all-day on cream.
/// Horizontal timeline on desktop, vertical on mobile.
class DayTimelineSection extends StatelessWidget {
  const DayTimelineSection({super.key, required this.menu});

  final KhaoMenu menu;

  static const _dotColors = [
    KhaoColors.yellow,
    KhaoColors.orange,
    KhaoColors.red,
  ];

  @override
  Widget build(BuildContext context) {
    final desktop = KhaoLayout.isDesktop(context);
    final width = MediaQuery.sizeOf(context).width;
    final parts = menu.dayparts;

    final heading = RevealOnScroll(
      child: Column(
        children: [
          Text(
            context.tr.dayKicker,
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
              context.tr.dayTitle,
              textAlign: TextAlign.center,
              style: KhaoText.anek(
                // CSS: clamp(48px, 5.5vw, 84px) / 42px
                desktop ? (width * 0.055).clamp(48.0, 84.0) : 42,
                weight: FontWeight.w800,
                color: KhaoColors.black,
                height: desktop ? 1 : 1.05,
              ),
            ),
          ),
        ],
      ),
    );

    final Widget timeline;
    if (desktop) {
      timeline = Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            top: 23,
            child: DashedLine(color: KhaoColors.black, thickness: 3),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, d) in parts.indexed) ...[
                if (i > 0) const SizedBox(width: 40),
                Expanded(
                  child: RevealOnScroll(
                    delay: Duration(milliseconds: 120 * i),
                    child: _DaypartColumn(
                      daypart: d,
                      quickBites: menu.quickBitesFor(d),
                      dotColor: _dotColors[i % 3],
                      desktop: true,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    } else {
      timeline = Stack(
        children: [
          const Positioned(
            left: 17,
            top: 8,
            bottom: 8,
            child: DashedLine(
              color: KhaoColors.black,
              thickness: 3,
              axis: Axis.vertical,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, d) in parts.indexed) ...[
                  if (i > 0) const SizedBox(height: 40),
                  RevealOnScroll(
                    child: _DaypartColumn(
                      daypart: d,
                      quickBites: menu.quickBitesFor(d),
                      dotColor: _dotColors[i % 3],
                      desktop: false,
                    ),
                  ),
                ],
              ],
            ),
          ),
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
              timeline,
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.label, required this.color, required this.size});

  final String label;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return PopOnScroll(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: KhaoColors.black, width: 3),
        ),
        // Bangla numerals → Anek Bangla (Bebas has no Bangla glyphs).
        child: Text(
          label,
          style: KhaoText.anek(
            size > 40 ? 20 : 16,
            color: color == KhaoColors.red ? Colors.white : KhaoColors.black,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _DaypartColumn extends StatelessWidget {
  const _DaypartColumn({
    required this.daypart,
    required this.quickBites,
    required this.dotColor,
    required this.desktop,
  });

  final Daypart daypart;
  final List<(String, String, int)> quickBites;
  final Color dotColor;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final d = daypart;
    final item = d.item;

    final label = Text(
      d.label,
      style: KhaoText.anek(desktop ? 18 : 16, color: KhaoColors.darkRed),
    );

    final Widget media = item != null
        ? _ImageCard(
            image: item.image,
            alt: item.name,
            height: desktop ? 300 : 200,
            radius: desktop ? 24 : 20,
          )
        : _PriceListCard(daypart: d, quickBites: quickBites, desktop: desktop);

    final titleStyle = KhaoText.anek(
      desktop ? 32 : 26,
      weight: FontWeight.w800,
      color: KhaoColors.black,
    );
    final title = Text.rich(
      item != null
          ? TextSpan(
              children: [
                TextSpan(text: '${item.name} '),
                TextSpan(
                  text: context.tr.taka(item.price),
                  style: const TextStyle(color: KhaoColors.darkRed),
                ),
              ],
            )
          : TextSpan(text: d.title),
      style: titleStyle,
    );

    final desc = Text(
      (item != null ? item.desc : d.desc) ?? '',
      style: KhaoText.hind(
        desktop ? 17 : 15,
        height: 1.6,
        color: KhaoColors.bodyOnCream,
      ),
    );

    if (desktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Dot(label: d.dot, color: dotColor, size: 50),
          const SizedBox(height: 24),
          media,
          const SizedBox(height: 20),
          label,
          const SizedBox(height: 4),
          title,
          const SizedBox(height: 8),
          desc,
        ],
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(padding: const EdgeInsets.only(top: 8), child: label),
            const SizedBox(height: 10),
            media,
            const SizedBox(height: 14),
            title,
            const SizedBox(height: 6),
            desc,
          ],
        ),
        Positioned(
          left: -44,
          top: 0,
          child: _Dot(label: d.dot, color: dotColor, size: 38),
        ),
      ],
    );
  }
}

class _ImageCard extends StatefulWidget {
  const _ImageCard({
    required this.image,
    required this.alt,
    required this.height,
    required this.radius,
  });

  final String? image;
  final String alt;
  final double height;
  final double radius;

  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final reduced = KhaoMotion.reduced(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: KhaoColors.black, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius - 2),
          child: AnimatedScale(
            // Hover (web): photos zoom slightly.
            scale: _hover && !reduced ? 1.06 : 1,
            duration: const Duration(milliseconds: 1200),
            curve: KhaoMotion.ease,
            child: widget.image != null
                ? Image.asset(
                    widget.image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    semanticLabel: widget.alt,
                  )
                : const PhotoPlaceholder(tag: 'PHOTO'),
          ),
        ),
      ),
    );
  }
}

class _PriceListCard extends StatelessWidget {
  const _PriceListCard({
    required this.daypart,
    required this.quickBites,
    required this.desktop,
  });

  final Daypart daypart;

  /// (name, tier detail, price) rows, e.g. "সিঙ্গারা (৪ পিস + ১টি সস)".
  final List<(String, String, int)> quickBites;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    // Items with a shortName (the sauces) aren't listed here.
    final main = daypart.items.where((i) => i.shortName == null).toList();
    // Desktop rows are tight so the list fits the fixed 300px card.
    final rowStyle = KhaoText.anek(
      desktop ? 19 : 17,
      color: KhaoColors.cream,
      height: desktop ? 1.25 : null,
    );
    final smallStyle = KhaoText.anek(
      desktop ? 16 : 14,
      weight: FontWeight.w600,
      color: KhaoColors.cream,
    );

    Widget row(String name, int price, TextStyle style, {String? detail}) =>
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text(name, style: style)),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.tr.taka(price),
                  style: style.copyWith(color: KhaoColors.yellow),
                ),
                if (detail != null && detail.isNotEmpty)
                  Text(
                    detail,
                    style: smallStyle.copyWith(
                      fontSize: 11,
                      height: 1.2,
                      color: KhaoColors.cream.withValues(alpha: 0.75),
                    ),
                  ),
              ],
            ),
          ],
        );

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (quickBites.isNotEmpty) ...[
          for (final (i, (name, detail, price)) in quickBites.indexed) ...[
            if (i > 0) const SizedBox(height: 8),
            row(name, price, rowStyle, detail: detail),
          ],
        ],
        const SizedBox(height: 12),
        DashedLine(color: KhaoColors.cream.withValues(alpha: 0.35)),
        const SizedBox(height: 12),
        for (final (i, it) in main.indexed) ...[
          if (i > 0) const SizedBox(height: 8),
          row(it.name, it.price, rowStyle),
        ],
        // if (sauces.isNotEmpty) ...[
        //   SizedBox(height: desktop ? 10 : 8),
        //   Opacity(
        //     opacity: 0.85,
        //     child: row(
        //       sauces
        //           // Mobile drops the brand prefix to fit ("গ্রিন সস").
        //           .map(
        //             (s) => desktop
        //                 ? s.shortName!
        //                 : s.shortName!.replaceFirst(RegExp(r'^KHAO\s+'), ''),
        //           )
        //           .join(' / '),
        //       sauces.first.price,
        //       smallStyle,
        //     ),
        //   ),
        // ],
      ],
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // quote,
        // SizedBox(height: desktop ? 24 : 16),
        list,
      ],
    );

    return Container(
      // Desktop: same height as the lunch / evening photo cards.
      height: desktop ? 300 : null,
      padding: EdgeInsets.all(desktop ? 16 : 22),
      decoration: BoxDecoration(
        color: KhaoColors.richBrown,
        borderRadius: BorderRadius.circular(desktop ? 24 : 20),
        border: Border.all(color: KhaoColors.black, width: 2),
      ),
      child: desktop
          // Narrow desktop columns wrap names onto two lines; shrink the
          // list to fit rather than overflow the fixed height.
          ? LayoutBuilder(
              builder: (context, c) => FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(width: c.maxWidth, child: content),
              ),
            )
          : content,
    );
  }
}
