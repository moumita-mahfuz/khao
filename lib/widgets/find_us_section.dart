import 'package:flutter/material.dart';

import '../l10n/khao_l10n.dart';
import '../data/links.dart';
import '../models/menu_models.dart';
import '../theme/khao_theme.dart';
import 'common.dart';
import 'reveal_on_scroll.dart';

/// Section 9: shop photo + address, hours, phone, socials and map/call CTAs.
class FindUsSection extends StatelessWidget {
  const FindUsSection({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final desktop = KhaoLayout.isDesktop(context);
    final width = MediaQuery.sizeOf(context).width;

    final photo = ClipRRect(
      borderRadius: BorderRadius.circular(desktop ? 32 : 24),
      child: SizedBox(
        height: desktop ? 620 : 320,
        child: desktop
            ? const _ParallaxImage(asset: 'assets/images/shop.jpg')
            : Image.asset(
                'assets/images/shop.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
                semanticLabel: context.tr.shopPhotoLabel,
              ),
      ),
    );

    final heading = Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: context.tr.findUsLine1),
            TextSpan(
              text: context.tr.findUsLine2,
              style: const TextStyle(color: KhaoColors.yellow),
            ),
          ],
        ),
        style: KhaoText.anek(
          // CSS: clamp(44px, 5vw, 76px) / 44px
          desktop ? (width * 0.05).clamp(44.0, 76.0) : 44,
          weight: FontWeight.w800,
          color: KhaoColors.cream,
          height: desktop ? 1 : 1.02,
        ),
      ),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: desktop ? 0 : 32),
        LatinText(
          context.tr.findUsKicker,
          size: desktop ? 22 : 17,
          letterSpacing: 3,
          color: KhaoColors.orange,
        ),
        SizedBox(height: desktop ? 8 : 6),
        heading,
        SizedBox(height: desktop ? 20 : 14),
        Text(
          desktop ? context.tr.findUsBodyLong : context.tr.findUsBodyShort,
          style: KhaoText.hind(
            desktop ? 19 : 16,
            height: 1.6,
            color: KhaoColors.cream.withValues(alpha: 0.75),
          ),
        ),
        SizedBox(height: desktop ? 32 : 24),
        _DefinitionList(contact: contact, desktop: desktop),
        SizedBox(height: desktop ? 36 : 28),
        if (desktop)
          PillButton(
            label: context.tr.viewOnMap,
            background: KhaoColors.yellow,
            horizontalPadding: 30,
            trailing: KhaoIcons.arrowRight(18, KhaoColors.black),
            onTap: () => KhaoLinks.open(context, contact.mapUrl),
          )
        else
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: context.tr.map,
                  background: KhaoColors.yellow,
                  height: 54,
                  fontSize: 17,
                  horizontalPadding: 12,
                  expand: true,
                  leading: KhaoIcons.pin(18, KhaoColors.black),
                  onTap: () => KhaoLinks.open(context, contact.mapUrl),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PillButton(
                  label: context.tr.call,
                  foreground: KhaoColors.cream,
                  borderColor: KhaoColors.cream,
                  height: 54,
                  fontSize: 17,
                  horizontalPadding: 12,
                  expand: true,
                  leading: KhaoIcons.phone(18, KhaoColors.cream),
                  onTap: () => KhaoLinks.call(context, contact.phone),
                ),
              ),
            ],
          ),
      ],
    );

    return ContentWidth(
      child: Padding(
        padding: desktop
            ? const EdgeInsets.only(top: 130, bottom: 140)
            : const EdgeInsets.only(top: 72, bottom: 80),
        child: desktop
            ? RevealOnScroll(
                child: Row(
                  children: [
                    Expanded(child: photo),
                    const SizedBox(width: 56),
                    Expanded(child: info),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RevealOnScroll(child: photo),
                  RevealOnScroll(child: info),
                ],
              ),
      ),
    );
  }
}

class _DefinitionList extends StatelessWidget {
  const _DefinitionList({required this.contact, required this.desktop});

  final Contact contact;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final ddStyle = KhaoText.hind(desktop ? 17 : 16, color: KhaoColors.cream);
    final linkStyle = ddStyle.copyWith(
      color: KhaoColors.yellow,
      decoration: TextDecoration.underline,
      decorationColor: KhaoColors.yellow,
    );
    final handle = contact.instagramHandle;
    final social = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!Contact.isPlaceholder(contact.facebook)) ...[
          _TextLink(
            label: 'Facebook',
            style: linkStyle,
            onTap: () => KhaoLinks.open(context, contact.facebook),
          ),
          Text(' · ', style: ddStyle),
        ],
        _TextLink(
          label: handle != null ? '@$handle' : 'Instagram',
          style: linkStyle,
          onTap: () => KhaoLinks.open(context, contact.instagram),
        ),
      ],
    );
    final website = contact.website;
    final entries = <(String, Widget)>[
      (context.tr.address, Text(contact.address, style: ddStyle)),
      (context.tr.hours, Text(contact.hours, style: ddStyle)),
      (
        context.tr.phone,
        _TextLink(
          label: context.tr.digits(contact.phone),
          style: linkStyle,
          onTap: () => KhaoLinks.call(context, contact.phone),
        ),
      ),
      (context.tr.follow(long: desktop), social),
      if (website != null)
        (
          context.tr.website(long: desktop),
          _TextLink(
            label: website,
            style: linkStyle,
            onTap: () => KhaoLinks.open(context, website),
          ),
        ),
    ];
    final dtStyle = KhaoText.anek(desktop ? 18 : 17, color: KhaoColors.yellow);

    if (desktop) {
      Widget cell((String, Widget) e) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.$1, style: dtStyle),
          const SizedBox(height: 4),
          e.$2,
        ],
      );
      return Column(
        children: [
          for (var r = 0; r < entries.length; r += 2) ...[
            if (r > 0) const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cell(entries[r])),
                const SizedBox(width: 32),
                Expanded(
                  child: r + 1 < entries.length
                      ? cell(entries[r + 1])
                      : const SizedBox(),
                ),
              ],
            ),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (final (i, e) in entries.indexed) ...[
          if (i > 0) const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.only(bottom: i < entries.length - 1 ? 14 : 0),
            decoration: i < entries.length - 1
                ? const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: KhaoColors.lineDark),
                    ),
                  )
                : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 72, child: Text(e.$1, style: dtStyle)),
                const SizedBox(width: 14),
                Expanded(child: e.$2),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TextLink extends StatefulWidget {
  const _TextLink({
    required this.label,
    required this.style,
    required this.onTap,
  });

  final String label;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  State<_TextLink> createState() => _TextLinkState();
}

class _TextLinkState extends State<_TextLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = _hover ? KhaoColors.orange : KhaoColors.yellow;
    return Semantics(
      link: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hover = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Text(
            widget.label,
            style: widget.style.copyWith(color: color, decorationColor: color),
          ),
        ),
      ),
    );
  }
}

/// Top-pinned image that zooms out 1.12 → 1 as it crosses the viewport.
class _ParallaxImage extends StatelessWidget {
  const _ParallaxImage({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: context.tr.shopPhotoLabel,
    );
    final scrollable = Scrollable.maybeOf(context);
    if (KhaoMotion.reduced(context) || scrollable == null) return image;
    return Flow(
      delegate: _ParallaxDelegate(scrollable: scrollable, itemContext: context),
      children: [image],
    );
  }
}

class _ParallaxDelegate extends FlowDelegate {
  _ParallaxDelegate({required this.scrollable, required this.itemContext})
    : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext itemContext;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) =>
      BoxConstraints.tight(constraints.biggest);

  @override
  void paintChildren(FlowPaintingContext context) {
    final viewport = scrollable.context.findRenderObject() as RenderBox?;
    final box = itemContext.findRenderObject() as RenderBox?;
    if (viewport == null || box == null || !box.hasSize) {
      context.paintChild(0);
      return;
    }
    final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    final vh = viewport.size.height;
    final h = context.size.height;
    // 0 when the box enters at the bottom, 1 when it leaves at the top.
    final p = ((vh - top) / (vh + h)).clamp(0.0, 1.0);
    // Pinned to the top edge so the photo's top is never cropped; the motion
    // is a gentle zoom-out (1.12 → 1) instead of a vertical drift.
    final s = 1.12 - 0.12 * p;
    final w = context.size.width;
    context.paintChild(
      0,
      transform: Matrix4.identity()
        ..translateByDouble(w / 2, 0, 0, 1)
        ..scaleByDouble(s, s, 1, 1)
        ..translateByDouble(-w / 2, 0, 0, 1),
    );
  }

  @override
  bool shouldRepaint(_ParallaxDelegate old) =>
      scrollable != old.scrollable || itemContext != old.itemContext;
}
