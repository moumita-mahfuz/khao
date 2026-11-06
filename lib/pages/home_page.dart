import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/menu_repository.dart';
import '../l10n/khao_l10n.dart';
import '../models/menu_models.dart';
import '../models/sections.dart';
import '../theme/khao_theme.dart';
import '../widgets/advance_order_section.dart';
import '../widgets/checker_strip.dart';
import '../widgets/common.dart';
import '../widgets/day_timeline.dart';
import '../widgets/find_us_section.dart';
import '../widgets/hero_video_section.dart';
import '../widgets/khao_footer.dart';
import '../widgets/menu_table.dart';
import '../widgets/signature_carousel.dart';
import '../widgets/ticker_strip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.repository});

  final MenuRepository repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Both languages load up front so the toggle switches instantly and the
  // scroll position survives.
  late final Future<Map<KhaoLang, KhaoMenu>> _menus = Future.wait(
    KhaoLang.values.map(widget.repository.load),
  ).then((m) => {for (final menu in m) menu.lang: menu});
  final _scroll = ScrollController();

  /// Back-to-top button shows once the hero has scrolled mostly away.
  final _showTop = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final threshold = MediaQuery.sizeOf(context).height * 0.8;
      _showTop.value = _scroll.offset > threshold;
    });
  }

  void _toTop() {
    if (KhaoMotion.reduced(context)) {
      _scroll.jumpTo(0);
    } else {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  final _keys = {for (final s in KhaoSection.values) s: GlobalKey()};

  /// Where queued mouse-wheel steps are heading, while they animate.
  double? _wheelTarget;

  /// Flutter web moves a whole wheel notch (~100px) in one frame, which reads
  /// as jerky. Glide notches instead; trackpads send small deltas that are
  /// already smooth, so those are followed 1:1.
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (e) {
      if (!_scroll.hasClients) return;
      final pos = _scroll.position;
      final dy = (e as PointerScrollEvent).scrollDelta.dy;
      if (dy == 0) return;
      double clamp(double v) =>
          v.clamp(pos.minScrollExtent, pos.maxScrollExtent).toDouble();
      if (dy.abs() < 40 || KhaoMotion.reduced(context)) {
        _wheelTarget = null;
        pos.jumpTo(clamp(pos.pixels + dy));
        return;
      }
      final target = clamp((_wheelTarget ?? pos.pixels) + dy);
      if (target == pos.pixels) return;
      _wheelTarget = target;
      _scroll
          .animateTo(
            target,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() {
            if (_wheelTarget == target) _wheelTarget = null;
          });
    });
  }

  void _navigate(KhaoSection section) {
    final ctx = _keys[section]!.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: KhaoMotion.reduced(context)
          ? Duration.zero
          : const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    _showTop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Light status-bar icons over the dark hero.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: KhaoColors.black,
        floatingActionButton: ValueListenableBuilder<bool>(
          valueListenable: _showTop,
          builder: (context, show, _) => _BackToTop(show: show, onTap: _toTop),
        ),
        body: FutureBuilder<Map<KhaoLang, KhaoMenu>>(
          future: _menus,
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(
                child: Text(
                  context.tr.menuLoadError(snap.error!),
                  style: KhaoText.hind(16, color: KhaoColors.cream),
                ),
              );
            }
            final menu = snap.data?[context.tr.lang];
            if (menu == null) {
              return Center(
                child: Image.asset(
                  'assets/logo/logo-on-dark.png',
                  width: 96,
                  filterQuality: FilterQuality.high,
                  semanticLabel: context.tr.logoLabel,
                ),
              );
            }
            return _buildPage(context, menu);
          },
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, KhaoMenu menu) {
    final desktop = KhaoLayout.isDesktop(context);
    final heroH = HeroVideoSection.heightFor(context);
    final bleed = TickerStrip.bleed(desktop);

    // All sections are built eagerly so nav GlobalKeys always have a context.
    return SingleChildScrollView(
      controller: _scroll,
      child: Listener(
        onPointerSignal: _onPointerSignal,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Each section paints on its own layer, so scrolling only
                // re-composites instead of repainting the whole page.
                RepaintBoundary(
                  child: HeroVideoSection(
                    onNavigate: _navigate,
                    foodpandaUrl: menu.contact.foodpanda,
                  ),
                ),
                // Space the ticker occupies (it overlaps hero and next section).
                Container(
                  height:
                      TickerStrip.layoutHeight(desktop) -
                      TickerStrip.overlapTop(desktop) -
                      TickerStrip.overlapBottom(desktop),
                  // Matches whichever section follows the ticker.
                  color: KhaoSection.signature.isVisible
                      ? KhaoColors.richBrown
                      : KhaoColors.black,
                ),
                if (KhaoSection.signature.isVisible) ...[
                  RepaintBoundary(
                    child: SignatureSection(
                      key: _keys[KhaoSection.signature],
                      menu: menu,
                      onNavigate: _navigate,
                    ),
                  ),
                  const CheckerStrip.brownBlack(),
                ],
                RepaintBoundary(
                  child: MenuSection(key: _keys[KhaoSection.menu], menu: menu),
                ),
                const CheckerStrip.blackCream(),
                if (KhaoSection.daypart.isVisible)
                  RepaintBoundary(
                    child: DayTimelineSection(
                      key: _keys[KhaoSection.daypart],
                      menu: menu,
                    ),
                  ),
                if (KhaoSection.advance.isVisible)
                  RepaintBoundary(
                    child: AdvanceOrderSection(
                      key: _keys[KhaoSection.advance],
                      menu: menu,
                    ),
                  ),
                const CheckerStrip.blackCream(flipped: true),
                RepaintBoundary(
                  child: FindUsSection(
                    key: _keys[KhaoSection.visit],
                    contact: menu.contact,
                  ),
                ),
                const CheckerStrip.blackCream(),
                RepaintBoundary(child: KhaoFooter(contact: menu.contact)),
              ],
            ),
            Positioned(
              top: heroH - TickerStrip.overlapTop(desktop),
              left: -bleed,
              right: -bleed,
              child: AnimateWhileVisible(
                child: TickerStrip(labels: menu.tickerLabels),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round yellow "back to top" button; fades/scales in when [show] is true.
class _BackToTop extends StatelessWidget {
  const _BackToTop({required this.show, required this.onTap});

  final bool show;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dur = KhaoMotion.reduced(context)
        ? Duration.zero
        : const Duration(milliseconds: 250);
    return IgnorePointer(
      ignoring: !show,
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: dur,
        child: AnimatedScale(
          scale: show ? 1 : 0.6,
          duration: dur,
          curve: KhaoMotion.ease,
          child: ExcludeSemantics(
            excluding: !show,
            child: Tooltip(
              message: context.tr.backToTop,
              child: Hoverable(
                onTap: onTap,
                semanticLabel: context.tr.backToTop,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: KhaoColors.yellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: KhaoColors.black, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        offset: const Offset(0, 6),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: KhaoColors.black,
                    size: 26,
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
