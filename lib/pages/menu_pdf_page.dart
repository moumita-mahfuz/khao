import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/khao_l10n.dart';
import '../theme/khao_theme.dart';
import '../widgets/common.dart';

/// Full printed menu (`assets/menu/khao_menu.pdf`), shown as a zoomable
/// page. The single-page PDF is pre-rendered to `khao_menu.jpg` so it loads
/// fast everywhere without a PDF engine; on web the original PDF can be
/// opened for download / printing.
class MenuPdfPage extends StatelessWidget {
  const MenuPdfPage({super.key});

  static const imageAsset = 'assets/menu/khao_menu.jpg';
  static const pdfAsset = 'assets/menu/khao_menu.pdf';

  static Future<void> open(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const MenuPdfPage()));

  Future<void> _openPdf() async {
    // Flutter web serves bundled assets under `assets/<asset path>`.
    await launchUrl(
      Uri.base.resolve('assets/$pdfAsset'),
      webOnlyWindowName: '_blank',
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final topInset = MediaQuery.paddingOf(context).top;
    final desktop = KhaoLayout.isDesktop(context);

    final bar = Padding(
      padding: EdgeInsets.fromLTRB(
        desktop ? 32 : 12,
        topInset + 12,
        desktop ? 32 : 12,
        12,
      ),
      child: Row(
        children: [
          Tooltip(
            message: t.back,
            child: Hoverable(
              onTap: () => Navigator.of(context).maybePop(),
              semanticLabel: t.back,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: KhaoColors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: KhaoColors.cream.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: KhaoColors.cream,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                t.menuPageTitle,
                overflow: TextOverflow.ellipsis,
                style: KhaoText.anek(
                  desktop ? 28 : 22,
                  weight: FontWeight.w800,
                  color: KhaoColors.cream,
                  height: 1.2,
                ),
              ),
            ),
          ),
          if (kIsWeb)
            PillButton(
              label: t.openPdf,
              background: KhaoColors.yellow,
              height: 44,
              fontSize: 16,
              horizontalPadding: 18,
              onTap: _openPdf,
            ),
        ],
      ),
    );

    final viewer = InteractiveViewer(
      minScale: 1,
      maxScale: 6,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(desktop ? 24 : 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(desktop ? 16 : 8),
            child: Image.asset(
              imageAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              semanticLabel: t.menuImageLabel,
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: KhaoColors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bar,
          Expanded(child: viewer),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + 12,
              top: 4,
            ),
            child: Text(
              t.zoomHint,
              textAlign: TextAlign.center,
              style: KhaoText.hind(
                14,
                color: KhaoColors.cream.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
