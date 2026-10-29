import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/menu_repository.dart';
import 'l10n/khao_l10n.dart';
import 'pages/home_page.dart';
import 'theme/khao_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _preloadFonts();
  runApp(KhaoApp(repository: MenuRepository()));
}

/// The default web fallback font has no Bangla glyphs, so a frame drawn
/// before the brand fonts load shows Bangla as boxes. Load every face first;
/// the HTML splash stays up until Flutter's first frame, covering the wait.
Future<void> _preloadFonts() async {
  final styles = [
    for (final weight in const [
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700,
      FontWeight.w800,
    ])
      GoogleFonts.anekBangla(fontWeight: weight),
    for (final weight in const [FontWeight.w400, FontWeight.w500])
      GoogleFonts.hindSiliguri(fontWeight: weight),
    GoogleFonts.galada(),
    GoogleFonts.bebasNeue(),
  ];
  try {
    // Don't hold the site hostage to a slow or failed font load.
    await GoogleFonts.pendingFonts(styles).timeout(const Duration(seconds: 6));
  } catch (_) {}
}

class KhaoApp extends StatefulWidget {
  const KhaoApp({super.key, required this.repository});

  final MenuRepository repository;

  @override
  State<KhaoApp> createState() => _KhaoAppState();
}

class _KhaoAppState extends State<KhaoApp> {
  final _lang = KhaoLangController();

  @override
  void dispose() {
    _lang.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KhaoL10n(
      controller: _lang,
      child: Builder(
        builder: (context) => MaterialApp(
          title: context.tr.appTitle,
          debugShowCheckedModeBanner: false,
          theme: buildKhaoTheme(),
          home: HomePage(repository: widget.repository),
        ),
      ),
    );
  }
}
