import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khao_web/l10n/khao_l10n.dart';
import 'package:khao_web/pages/menu_pdf_page.dart';

import 'real_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadRealFonts);

  for (final lang in KhaoLang.values) {
    for (final size in const [Size(360, 740), Size(1440, 900)]) {
      testWidgets('menu page renders in ${lang.name} at ${size.width}', (
        t,
      ) async {
        t.view.physicalSize = size;
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          KhaoL10n(
            controller: KhaoLangController(lang),
            child: const MaterialApp(home: MenuPdfPage()),
          ),
        );
        await t.pump();
        expect(t.takeException(), isNull);
        expect(find.text(KhaoStrings(lang).menuPageTitle), findsOneWidget);
        expect(find.byType(InteractiveViewer), findsOneWidget);
      });
    }
  }
}
