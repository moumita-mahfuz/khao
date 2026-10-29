import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Registers the bundled brand fonts under the family names google_fonts
/// generates, so layout tests measure real Bangla/Latin text instead of the
/// test font (whose metrics hid real overflows).
Future<void> loadRealFonts() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  const files = {
    'AnekBangla_500': 'AnekBangla-Medium.ttf',
    'AnekBangla_600': 'AnekBangla-SemiBold.ttf',
    'AnekBangla_700': 'AnekBangla-Bold.ttf',
    'AnekBangla_800': 'AnekBangla-ExtraBold.ttf',
    'HindSiliguri_regular': 'HindSiliguri-Regular.ttf',
    'HindSiliguri_500': 'HindSiliguri-Medium.ttf',
    'HindSiliguri_600': 'HindSiliguri-SemiBold.ttf',
    'Galada_regular': 'Galada-Regular.ttf',
    'BebasNeue_regular': 'BebasNeue-Regular.ttf',
  };
  for (final MapEntry(key: family, value: file) in files.entries) {
    final loader = FontLoader(family)
      ..addFont(rootBundle.load('assets/google_fonts/$file'));
    await loader.load();
  }
}
