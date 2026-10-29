import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// KHAO brand palette (Design A — "Street Fire").
abstract final class KhaoColors {
  static const yellow = Color(0xFFFFC107);
  static const orange = Color(0xFFFF6A00);
  static const red = Color(0xFFCA4742);
  //static const red = Color(0xFFE63900);
  static const black = Color(0xFF111111);
  static const cream = Color(0xFFFFF6E6);
  static const richBrown = Color(0xFF4A2C15);
  static const darkRed = Color(0xFFB32D00);
  static const surfaceDark = Color(0xFF1C1C1C);
  static const lineDark = Color(0xFF262626);
  static const dashedBeige = Color(0xFFC9B48F);
  static const rowHover = Color(0xFFFFE9B0);
  static const bodyOnCream = Color(0xFF333333);
}

/// Layout constants shared by every section.
abstract final class KhaoLayout {
  static const breakpoint = 860.0;
  static const maxWidth = 1440.0;
  static const sidePadDesktop = 56.0;
  static const sidePadMobile = 16.0;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= breakpoint;

  static double sidePad(BuildContext context) =>
      isDesktop(context) ? sidePadDesktop : sidePadMobile;
}

/// Motion helpers. CSS `cubic-bezier(.2,.8,.2,1)` is used throughout the design.
abstract final class KhaoMotion {
  static const ease = Cubic(0.2, 0.8, 0.2, 1);

  /// True when the user asked for reduced motion (web: `prefers-reduced-motion`).
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// Typography. Each helper maps to one brand font role.
///
/// Bebas Neue has no Bangla glyphs, so [bebas] asserts the text it styles is
/// Latin-only; use it through [LatinText].
abstract final class KhaoText {
  // CSS `line-height: normal` for each font (hhea ascent+descent+gap / upm),
  // so unspecified line heights match the browser design.
  static const normalAnek = 1.866;
  static const normalHind = 1.617;
  static const normalGalada = 1.627;
  static const normalBebas = 1.2;

  /// Bangla display / headings / prices.
  static TextStyle anek(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? height,
    double? letterSpacing,
  }) => GoogleFonts.anekBangla(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height ?? normalAnek,
    letterSpacing: letterSpacing,
  );

  /// English labels / kickers / ticker. Latin only.
  static TextStyle bebas(
    double size, {
    Color? color,
    double? letterSpacing,
    double? height,
  }) => GoogleFonts.bebasNeue(
    fontSize: size,
    color: color,
    letterSpacing: letterSpacing,
    height: height ?? normalBebas,
  );

  /// Handwritten accent lines.
  static TextStyle galada(double size, {Color? color, double? height}) =>
      GoogleFonts.galada(
        fontSize: size,
        color: color,
        height: height ?? normalGalada,
      );

  /// Body copy.
  static TextStyle hind(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) => GoogleFonts.hindSiliguri(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height ?? normalHind,
  );

  static final _bangla = RegExp(r'[ঀ-৿]');

  static bool hasBangla(String s) => _bangla.hasMatch(s);
}

/// A [Text] in Bebas Neue for Latin accent labels ("ORDER", "FIND US").
/// Bebas has no Bangla glyphs, so Bangla text (the Bangla-language site)
/// is set in Anek Bangla instead, scaled to Bebas's visual size.
class LatinText extends StatelessWidget {
  const LatinText(
    this.text, {
    super.key,
    required this.size,
    this.color,
    this.letterSpacing,
    this.height,
    this.textAlign,
  });

  final String text;
  final double size;
  final Color? color;
  final double? letterSpacing;
  final double? height;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    if (KhaoText.hasBangla(text)) {
      return Text(
        text,
        textAlign: textAlign,
        style: KhaoText.anek(
          size * 0.8,
          weight: FontWeight.w700,
          color: color,
          height: height == null ? null : height! + 0.2,
        ),
      );
    }
    return Text(
      text,
      textAlign: textAlign,
      style: KhaoText.bebas(
        size,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      ),
    );
  }
}

ThemeData buildKhaoTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: KhaoColors.black,
    colorScheme: const ColorScheme.dark(
      primary: KhaoColors.yellow,
      secondary: KhaoColors.orange,
      surface: KhaoColors.black,
      onSurface: KhaoColors.cream,
      error: KhaoColors.red,
    ),
  );
  return base.copyWith(
    textTheme: GoogleFonts.hindSiliguriTextTheme(
      base.textTheme,
    ).apply(bodyColor: KhaoColors.cream, displayColor: KhaoColors.cream),
  );
}
