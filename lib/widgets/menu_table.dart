import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/khao_l10n.dart';
import '../models/menu_models.dart';
import '../theme/khao_theme.dart';
import 'common.dart';
import 'reveal_on_scroll.dart';

/// Section 5: "টুকটাক খাও" — snack prices per tier plus the সব খাও combo.
class MenuSection extends StatelessWidget {
  const MenuSection({super.key, required this.menu});

  final KhaoMenu menu;

  @override
  Widget build(BuildContext context) {
    final desktop = KhaoLayout.isDesktop(context);
    final width = MediaQuery.sizeOf(context).width;

    final heading = RevealOnScroll(
      child: Column(
        children: [
          Text(
            context.tr.menuKicker,
            textAlign: TextAlign.center,
            style: KhaoText.galada(desktop ? 30 : 24, color: KhaoColors.yellow),
          ),
          SizedBox(height: desktop ? 4 : 2),
          Semantics(
            header: true,
            child: Text(
              context.tr.menuTitle,
              textAlign: TextAlign.center,
              style: KhaoText.anek(
                // CSS: clamp(52px, 6vw, 92px) / 50px
                desktop ? (width * 0.06).clamp(52.0, 92.0) : 50,
                weight: FontWeight.w800,
                color: KhaoColors.cream,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );

    return ContentWidth(
      child: Padding(
        padding: desktop
            ? const EdgeInsets.only(top: 130, bottom: 140)
            : const EdgeInsets.only(top: 72, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handwritten "extra sauces" note, pointing at the sauce panel
            // when it sits beside the table.
            if (desktop && menu.sauces.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(child: heading),
                    if (constraints.maxWidth >= _DesktopTable.sideBySideMin)
                      const Positioned(
                        right: 24,
                        bottom: -40,
                        child: _SauceCallout(),
                      ),
                  ],
                ),
              )
            else
              heading,
            SizedBox(height: desktop ? 56 : 32),
            if (desktop)
              RevealOnScroll(child: _DesktopTable(menu: menu))
            else
              _MobileCards(menu: menu),
            if (menu.categories.isNotEmpty) ...[
              SizedBox(height: desktop ? 72 : 40),
              RevealOnScroll(
                child: Text(
                  context.tr.menuExtrasKicker,
                  textAlign: TextAlign.center,
                  style: KhaoText.galada(
                    desktop ? 30 : 24,
                    color: KhaoColors.yellow,
                  ),
                ),
              ),
              SizedBox(height: desktop ? 28 : 18),
              _CategoryGrid(categories: menu.categoryItems),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- shared

const _tierColors = [KhaoColors.yellow, KhaoColors.orange, KhaoColors.red];

class _Thumb extends StatelessWidget {
  const _Thumb({required this.item, required this.size, this.hovered = false});

  final MenuItem item;
  final double size;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    final img = item.thumbImage;
    final dur = KhaoMotion.reduced(context)
        ? Duration.zero
        : const Duration(milliseconds: 500);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: KhaoColors.red,
        border: Border.all(color: KhaoColors.black, width: 2),
      ),
      child: ClipOval(
        // .row:hover .th { scale(1.12) rotate(-4deg) }
        child: AnimatedRotation(
          turns: hovered ? -4 / 360 : 0,
          duration: dur,
          curve: KhaoMotion.ease,
          child: AnimatedScale(
            scale: hovered ? 1.12 : 1,
            duration: dur,
            curve: KhaoMotion.ease,
            child: img != null
                ? Image.asset(
                    img,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    semanticLabel: item.name,
                  )
                : Center(
                    child: Text(
                      context.tr.photo,
                      style: KhaoText.hind(
                        size > 80 ? 11 : 10,
                        color: KhaoColors.cream,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Rotated black price sticker (৳১১০).
class _Sticker extends StatefulWidget {
  const _Sticker({required this.price, required this.size, required this.font});

  final int price;
  final double size;
  final double font;

  @override
  State<_Sticker> createState() => _StickerState();
}

class _StickerState extends State<_Sticker> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final reduced = KhaoMotion.reduced(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedRotation(
        turns: _hover && !reduced ? 0 : -8 / 360,
        duration: reduced ? Duration.zero : const Duration(milliseconds: 400),
        curve: KhaoMotion.ease,
        child: AnimatedScale(
          scale: _hover && !reduced ? 1.04 : 1,
          duration: const Duration(milliseconds: 400),
          curve: KhaoMotion.ease,
          child: Container(
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: KhaoColors.black,
              shape: BoxShape.circle,
            ),
            child: Text(
              context.tr.taka(widget.price),
              style: KhaoText.anek(
                widget.font,
                weight: FontWeight.w800,
                color: KhaoColors.yellow,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _tilted(String text, double size) => Transform.rotate(
  angle: -4 * math.pi / 180,
  child: Text(
    text,
    style: KhaoText.anek(
      size,
      weight: FontWeight.w800,
      color: KhaoColors.black,
      height: 1,
    ),
  ),
);

// ---------------------------------------------------------------- desktop

class _DesktopTable extends StatelessWidget {
  const _DesktopTable({required this.menu});

  final KhaoMenu menu;

  static const _pad = EdgeInsets.symmetric(horizontal: 32, vertical: 22);

  /// Below this width the sauce panel drops under the snack rows instead of
  /// sitting beside them, so the price columns keep their room.
  static const sideBySideMin = 1100.0;

  /// CSS grid: 120px | 2fr | 1fr 1fr 1fr, gap 16.
  static Widget gridRow(List<Widget> cells) => Row(
    children: [
      SizedBox(width: 120, child: cells[0]),
      const SizedBox(width: 16),
      Expanded(flex: 2, child: cells[1]),
      for (final c in cells.skip(2)) ...[
        const SizedBox(width: 16),
        Expanded(child: c),
      ],
    ],
  );

  @override
  Widget build(BuildContext context) {
    final header = Container(
      padding: _pad,
      decoration: const BoxDecoration(
        color: KhaoColors.cream,
        border: Border(bottom: BorderSide(color: KhaoColors.black, width: 2)),
      ),
      child: gridRow([
        const SizedBox(),
        Text(
          context.tr.item,
          style: KhaoText.anek(20, color: KhaoColors.black),
        ),
        for (final (i, t) in menu.tiers.indexed)
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _tierColors[i % 3],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      t.label,
                      style: KhaoText.anek(
                        17,
                        color: KhaoColors.black,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      t.detail,
                      style: KhaoText.hind(
                        11,
                        color: KhaoColors.richBrown,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ]),
    );

    final combo = menu.combo;
    // No IntrinsicHeight here: it under-measured the wrapped title on narrow
    // desktop widths and overflowed. Each half sizes itself; the divider is
    // an overlay spanning the band's full height.
    final comboBand = ColoredBox(
      color: KhaoColors.yellow,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          // 64px at full width, down to 40px just above the breakpoint.
          final titleSize = (w * 0.055).clamp(40.0, 64.0);
          final pad = w < 1000 ? 28.0 : 48.0;
          return Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: pad,
                        vertical: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tilted(combo.name, titleSize),
                          const SizedBox(height: 8),
                          Text(
                            combo.tagline,
                            style: KhaoText.galada(
                              titleSize * 0.375,
                              color: KhaoColors.richBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: pad * 0.6,
                        vertical: 24,
                      ),
                      child: _ComboOfferBox(
                        combo: combo,
                        fontSize: w < 1000 ? 16 : 18,
                        badgeSize: w < 1000 ? 120 : 148,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: w / 2 - 1,
                child: const SizedBox(
                  width: 2,
                  child: ColoredBox(color: KhaoColors.black),
                ),
              ),
            ],
          );
        },
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: KhaoColors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            offset: const Offset(0, 30),
            blurRadius: 80,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _withSauces(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  for (final s in menu.snacks) _TableRow(item: s),
                ],
              ),
            ),
            comboBand,
          ],
        ),
      ),
    );
  }

  /// Puts the sauce panel beside the snack rows on wide screens (cream
  /// column + divider as overlays so they span the full height without
  /// IntrinsicHeight), or as a band under them on narrower desktops.
  Widget _withSauces(Widget table) {
    final sauces = menu.sauces;
    if (sauces.isEmpty) return table;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w < sideBySideMin) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              table,
              ColoredBox(
                color: KhaoColors.cream,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 36),
                  child: _SaucePanel(sauces: sauces, compact: false),
                ),
              ),
              const SizedBox(
                height: 2,
                child: ColoredBox(color: KhaoColors.black),
              ),
            ],
          );
        }
        final panelW = (w * 0.3).clamp(340.0, 440.0);
        // The table sets the height; the panel fills that column, with the
        // sauces stacked and centred so there's no empty block underneath.
        // scaleDown only kicks in if the panel would ever be the taller one.
        return Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: table),
                SizedBox(width: panelW),
              ],
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: panelW,
              child: ColoredBox(
                color: KhaoColors.cream,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: panelW - 56,
                        child: _SaucePanel(
                          sauces: sauces,
                          compact: false,
                          stacked: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: panelW,
              child: const SizedBox(
                width: 2,
                child: ColoredBox(color: KhaoColors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TableRow extends StatefulWidget {
  const _TableRow({required this.item});

  final MenuItem item;

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hovered = _hover && !KhaoMotion.reduced(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: hovered ? KhaoColors.rowHover : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: _DesktopTable._pad,
              child: _DesktopTable.gridRow([
                Align(
                  alignment: Alignment.centerLeft,
                  child: _Thumb(item: item, size: 96, hovered: hovered),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: KhaoText.anek(28, color: KhaoColors.black),
                    ),
                    if (item.tagline != null)
                      Text(
                        item.tagline!,
                        style: KhaoText.hind(16, color: KhaoColors.richBrown),
                      ),
                  ],
                ),
                for (final p in item.prices)
                  Text(
                    context.tr.taka(p),
                    textAlign: TextAlign.center,
                    style: KhaoText.anek(
                      30,
                      weight: FontWeight.w800,
                      color: KhaoColors.black,
                    ),
                  ),
              ]),
            ),
            const DashedLine(color: KhaoColors.dashedBeige),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- mobile

class _MobileCards extends StatelessWidget {
  const _MobileCards({required this.menu});

  final KhaoMenu menu;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in menu.snacks) ...[
          RevealOnScroll(
            child: _MobileItemCard(item: s, tiers: menu.tiers),
          ),
          const SizedBox(height: 14),
        ],
        if (menu.sauces.isNotEmpty) ...[
          RevealOnScroll(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KhaoColors.cream,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: KhaoColors.black, width: 2),
              ),
              child: _SaucePanel(sauces: menu.sauces, compact: true),
            ),
          ),
          const SizedBox(height: 14),
        ],
        RevealOnScroll(child: _MobileComboCard(combo: menu.combo)),
      ],
    );
  }
}

class _MobileItemCard extends StatelessWidget {
  const _MobileItemCard({required this.item, required this.tiers});

  final MenuItem item;
  final List<Tier> tiers;

  @override
  Widget build(BuildContext context) {
    const boxColors = [KhaoColors.yellow, KhaoColors.orange, KhaoColors.red];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KhaoColors.cream,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: KhaoColors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Thumb(item: item, size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: KhaoText.anek(
                        22,
                        color: KhaoColors.black,
                        height: 1.2,
                      ),
                    ),
                    if (item.tagline != null)
                      Text(
                        item.tagline!,
                        style: KhaoText.hind(14, color: KhaoColors.richBrown),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (i, t) in tiers.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    label:
                        '${t.short} · ${t.detail}: ${context.tr.taka(item.prices[i])}',
                    child: ExcludeSemantics(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: boxColors[i % 3],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                t.label,
                                maxLines: 1,
                                style: KhaoText.anek(
                                  12,
                                  weight: FontWeight.w700,
                                  height: 1.5,
                                  color:
                                      // i == 2
                                      //     ? KhaoColors.cream
                                      //     :
                                      KhaoColors.richBrown,
                                ),
                              ),
                            ),

                            Text(
                              context.tr.taka(item.prices[i]),
                              style: KhaoText.anek(
                                22,
                                weight: FontWeight.w800,
                                height: 1.7,
                                color:
                                    // i == 2
                                    //     ? KhaoColors.yellow
                                    //     :
                                    KhaoColors.black,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    t.pieces,
                                    maxLines: 1,
                                    style: KhaoText.anek(
                                      11,
                                      weight: FontWeight.w500,
                                      height: 1.3,
                                      color:
                                          // i == 2
                                          //     ? KhaoColors.cream
                                          //     :
                                          KhaoColors.black,
                                    ),
                                  ),
                                ),
                                if (t.sauces.isNotEmpty)
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '+ ${t.sauces}',
                                      maxLines: 1,
                                      style: KhaoText.anek(
                                        11,
                                        weight: FontWeight.w500,
                                        height: 1.3,
                                        color:
                                            // i == 2
                                            //     ? KhaoColors.cream
                                            //     :
                                            KhaoColors.black,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileComboCard extends StatelessWidget {
  const _MobileComboCard({required this.combo});

  final Combo combo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KhaoColors.yellow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: KhaoColors.black, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _tilted(combo.name, 48),
            ),
            const SizedBox(height: 16),
            Text(
              combo.tagline,
              style: KhaoText.galada(
                19,
                color: KhaoColors.richBrown,
                height: 1,
              ),
            ),
            const SizedBox(height: 18),
            _ComboOfferBox(combo: combo, fontSize: 14, badgeSize: 104),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- combo offer

/// Cream box with the combo's contents as a checklist and the red
/// "Only ৳120" badge beside it.
class _ComboOfferBox extends StatelessWidget {
  const _ComboOfferBox({
    required this.combo,
    required this.fontSize,
    required this.badgeSize,
  });

  final Combo combo;
  final double fontSize;
  final double badgeSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        fontSize,
        fontSize * 1.1,
        fontSize * 0.6,
        fontSize * 1.1,
      ),
      decoration: BoxDecoration(
        color: KhaoColors.cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2A900), width: 2),
        boxShadow: [
          BoxShadow(
            color: KhaoColors.richBrown.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (i, line) in combo.includesJoined.indexed) ...[
                  if (i > 0) SizedBox(height: fontSize * 0.55),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CheckDot(size: fontSize * 1.25),
                      SizedBox(width: fontSize * 0.6),
                      Expanded(
                        child: Text(
                          line,
                          style: KhaoText.anek(
                            fontSize,
                            weight: FontWeight.w600,
                            color: KhaoColors.black,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Room for the sparks either side of the badge.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: badgeSize * 0.16),
            child: _OnlyBadge(price: combo.price, size: badgeSize),
          ),
        ],
      ),
    );
  }
}

/// Yellow-to-orange disc with a black tick.
class _CheckDot extends StatelessWidget {
  const _CheckDot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [KhaoColors.yellow, Color(0xFFFF9500)],
        ),
      ),
      child: KhaoIcons.check(size * 0.7, KhaoColors.black),
    );
  }
}

/// Red scalloped seal: "Only" in script over the price, with yellow sparks.
/// Straightens a little on hover, like the old price sticker.
class _OnlyBadge extends StatefulWidget {
  const _OnlyBadge({required this.price, required this.size});

  final int price;
  final double size;

  @override
  State<_OnlyBadge> createState() => _OnlyBadgeState();
}

class _OnlyBadgeState extends State<_OnlyBadge> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final reduced = KhaoMotion.reduced(context);
    final size = widget.size;
    final active = _hover && !reduced;
    const dur = Duration(milliseconds: 400);
    return Semantics(
      label: '${context.tr.comboOnly} ${context.tr.taka(widget.price)}',
      child: ExcludeSemantics(
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: AnimatedRotation(
            turns: active ? 0 : -6 / 360,
            duration: reduced ? Duration.zero : dur,
            curve: KhaoMotion.ease,
            child: AnimatedScale(
              scale: active ? 1.05 : 1,
              duration: dur,
              curve: KhaoMotion.ease,
              child: CustomPaint(
                painter: const _SealPainter(),
                child: SizedBox.square(
                  dimension: size,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr.comboOnly,
                        style: KhaoText.galada(
                          size * 0.17,
                          color: KhaoColors.cream,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: size * 0.02),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          context.tr.taka(widget.price),
                          style: KhaoText.anek(
                            size * 0.24,
                            weight: FontWeight.w800,
                            color: KhaoColors.cream,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SealPainter extends CustomPainter {
  const _SealPainter();

  static const _bumps = 14;

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final r = s.shortestSide / 2;

    // Soft scalloped edge: radius rides a cosine around the circle.
    final seal = Path();
    for (var i = 0; i <= 360; i++) {
      final a = i * math.pi / 180;
      final rr = r * (0.94 + 0.06 * math.cos(_bumps * a));
      final p = c + Offset(math.cos(a), math.sin(a)) * rr;
      i == 0 ? seal.moveTo(p.dx, p.dy) : seal.lineTo(p.dx, p.dy);
    }
    seal.close();

    canvas.drawShadow(seal, Colors.black, 6, false);
    canvas.drawPath(
      seal,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.35),
          radius: 0.85,
          colors: [Color(0xFFE0584F), Color(0xFFCA4742), Color(0xFFA8302C)],
          stops: [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // Fine inner ring for a stamped-seal finish.
    canvas.drawCircle(
      c,
      r * 0.8,
      Paint()
        ..color = KhaoColors.cream.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Yellow sparks radiating out on both sides.
    final spark = Paint()
      ..color = KhaoColors.yellow
      ..strokeWidth = math.max(2.5, r * 0.05)
      ..strokeCap = StrokeCap.round;
    for (final deg in const [-150, -175, 160, -30, 10, 35]) {
      final a = deg * math.pi / 180;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + dir * r * 1.12, c + dir * r * 1.32, spark);
    }
  }

  @override
  bool shouldRepaint(_SealPainter old) => false;
}

// ---------------------------------------------------------------- sauces

/// "Extra Sauces" on a brush stroke, then one tile per sauce with a divider:
/// side by side, or [stacked] in the tall column beside the desktop table.
class _SaucePanel extends StatelessWidget {
  const _SaucePanel({
    required this.sauces,
    required this.compact,
    this.stacked = false,
  });

  final List<MenuItem> sauces;
  final bool compact;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final title = _BrushLabel(
      text: context.tr.saucesTitle,
      fontSize: compact ? 26 : 32,
      sparks: true,
    );
    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          title,
          const SizedBox(height: 20),
          for (final (i, s) in sauces.indexed) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                child: _OrnamentDivider(),
              ),
            _SauceTile(item: s, compact: false, large: true),
          ],
        ],
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            title,
            SizedBox(height: compact ? 4 : 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, s) in sauces.indexed) ...[
                  if (i > 0)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 8 : 12,
                        vertical: 4,
                      ),
                      child: SizedBox(
                        height: compact ? 96 : 116,
                        child: const _OrnamentDivider(axis: Axis.vertical),
                      ),
                    ),
                  Expanded(
                    child: _SauceTile(item: s, compact: compact),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SauceTile extends StatelessWidget {
  const _SauceTile({
    required this.item,
    required this.compact,
    this.large = false,
  });

  final MenuItem item;
  final bool compact;

  /// Full-width tile in the stacked desktop column: bigger type, and the
  /// tagline fits in two lines there.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final descSize = compact ? 9.1 : (large ? 16.0 : 14.5);
    final descHeight = large ? 1.35 : 1.1;
    final descLines = large ? 2 : 3;
    final nameSize = compact ? 17.0 : (large ? 24.0 : 20.0);
    final priceSize = compact ? 20.0 : (large ? 26.0 : 24.0);
    return Semantics(
      label: '${item.name}, ${context.tr.taka(item.price)}',
      child: ExcludeSemantics(
        child: Column(
          children: [
            // SizedBox.square(
            //   dimension: bowl,
            //   child: img != null
            //       ? ClipOval(child: Image.asset(img, fit: BoxFit.cover))
            //       : CustomPaint(
            //           painter: _SauceBowlPainter(
            //             Color(item.color ?? 0xFFB32D00),
            //           ),
            //         ),
            // ),
            // SizedBox(height: compact ? 8 : 12),
            // One line for the name and a fixed three-line block for the
            // tagline, so every tile is the same height and the price tags
            // line up whether the tagline is short or long.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.name,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: KhaoText.anek(
                  nameSize,
                  weight: FontWeight.w800,
                  color: KhaoColors.black,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: MediaQuery.textScalerOf(
                context,
              ).scale(descSize * descHeight * descLines),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  item.desc ?? '',
                  maxLines: descLines,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: KhaoText.hind(
                    descSize,
                    color: KhaoColors.bodyOnCream,
                    height: descHeight,
                  ),
                ),
              ),
            ),

            // SizedBox(height: compact ? 12 : 16),
            _BrushLabel(
              text: context.tr.taka(item.price),
              fontSize: priceSize,
            ),
          ],
        ),
      ),
    );
  }
}

/// Hairlines that fade out at both ends, meeting at a small orange diamond
/// flanked by two dots: the separator between sauces.
class _OrnamentDivider extends StatelessWidget {
  const _OrnamentDivider({this.axis = Axis.horizontal});

  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final horizontal = axis == Axis.horizontal;
    final ink = KhaoColors.richBrown.withValues(alpha: 0.45);

    Widget line({required bool towardsEnd}) => Expanded(
      child: Container(
        width: horizontal ? null : 1,
        height: horizontal ? 1 : null,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: horizontal ? Alignment.centerLeft : Alignment.topCenter,
            end: horizontal ? Alignment.centerRight : Alignment.bottomCenter,
            colors: towardsEnd
                ? [ink, ink.withValues(alpha: 0)]
                : [ink.withValues(alpha: 0), ink],
          ),
        ),
      ),
    );

    Widget dot() => Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
    );

    const gap = SizedBox(width: 6, height: 6);
    return ExcludeSemantics(
      child: Flex(
        direction: axis,
        children: [
          line(towardsEnd: false),
          gap,
          dot(),
          gap,
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: KhaoColors.orange,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          gap,
          dot(),
          gap,
          line(towardsEnd: true),
        ],
      ),
    );
  }
}

/// Text on a tilted dry-brush stroke: yellow with sparks, or plain orange.
class _BrushLabel extends StatelessWidget {
  const _BrushLabel({
    required this.text,
    required this.fontSize,
    this.sparks = false,
  });

  final String text;
  final double fontSize;
  final bool sparks;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -3 * math.pi / 180,
      child: Container(
        // The art has transparent margins around the paint, so the text is
        // inset a little more than the visible stroke edge.
        padding: EdgeInsets.symmetric(
          horizontal: fontSize * 1.1,
          vertical: fontSize * 0.5,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              sparks
                  ? 'assets/images/yellow_spark_stroke.png'
                  : 'assets/images/orange_stroke.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Text(
          text,
          style: KhaoText.anek(
            fontSize,
            weight: FontWeight.w800,
            color: KhaoColors.black,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

/// Handwritten note with an arrow and a crown doodle, beside the heading.
class _SauceCallout extends StatelessWidget {
  const _SauceCallout();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Transform.rotate(
        angle: -8 * math.pi / 180,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            KhaoIcons.curvedArrow(44, KhaoColors.yellow),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.tr.saucesCallout,
                  textAlign: TextAlign.right,
                  style: KhaoText.galada(
                    24,
                    color: KhaoColors.yellow,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                KhaoIcons.crown(28, KhaoColors.yellow),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- categories

/// Drinks, lunch, evening and sauces: one cream card per category,
/// 2 columns on desktop and tablets, 1 on phones.
class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories});

  final List<(String, List<MenuItem>)> categories;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 560 ? 2 : 1;
        final gap = cols == 1 ? 14.0 : 20.0;
        final rows = <Widget>[];
        for (var r = 0; r < categories.length; r += cols) {
          if (r > 0) rows.add(SizedBox(height: gap));
          // Top-aligned rather than IntrinsicHeight + stretch, which can
          // mis-measure text on web and overflow (see the combo band).
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var c = 0; c < cols; c++) ...[
                  if (c > 0) SizedBox(width: gap),
                  Expanded(
                    child: r + c < categories.length
                        ? RevealOnScroll(
                            delay: Duration(milliseconds: 100 * c),
                            child: _CategoryCard(
                              title: categories[r + c].$1,
                              items: categories[r + c].$2,
                              compact: cols == 1,
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.items,
    required this.compact,
  });

  final String title;
  final List<MenuItem> items;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        color: KhaoColors.cream,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: KhaoColors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: KhaoText.anek(
                compact ? 22 : 26,
                weight: FontWeight.w800,
                color: KhaoColors.black,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const DashedLine(color: KhaoColors.dashedBeige),
          for (final (i, it) in items.indexed) ...[
            SizedBox(height: i == 0 ? 14 : 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    it.name,
                    style: KhaoText.anek(
                      compact ? 19 : 21,
                      weight: FontWeight.w600,
                      color: KhaoColors.black,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.tr.taka(it.price),
                  style: KhaoText.anek(
                    compact ? 21 : 24,
                    weight: FontWeight.w800,
                    color: KhaoColors.darkRed,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            if ((it.desc ?? it.tagline) != null) ...[
              const SizedBox(height: 4),
              Text(
                (it.desc ?? it.tagline)!,
                style: KhaoText.hind(
                  compact ? 14 : 15,
                  height: 1.5,
                  color: KhaoColors.richBrown,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
