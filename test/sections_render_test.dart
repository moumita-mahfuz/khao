import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khao_web/data/menu_repository.dart';
import 'package:khao_web/l10n/khao_l10n.dart';
import 'package:khao_web/widgets/day_timeline.dart';
import 'package:khao_web/widgets/find_us_section.dart';
import 'package:khao_web/widgets/khao_footer.dart';
import 'package:khao_web/widgets/menu_table.dart';
import 'package:khao_web/widgets/signature_carousel.dart';

import 'real_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadRealFonts);

  for (final lang in KhaoLang.values) {
    for (final size in const [
      Size(360, 740),
      Size(390, 844),
      Size(820, 1180),
      Size(870, 900),
      Size(925, 900),
      Size(960, 900),
      Size(1100, 900),
      Size(1440, 900),
    ]) {
      testWidgets('sections render in ${lang.name} at ${size.width}', (
        t,
      ) async {
        final menu = (await t.runAsync(() => MenuRepository().load(lang)))!;
        t.view.physicalSize = size;
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          KhaoL10n(
            controller: KhaoLangController(lang),
            child: MaterialApp(
              home: MediaQuery(
                // Reduced motion: skip scroll-reveal timers.
                data: MediaQueryData(size: size, disableAnimations: true),
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SignatureSection(menu: menu, onNavigate: (_) {}),
                        MenuSection(menu: menu),
                        DayTimelineSection(menu: menu),
                        FindUsSection(contact: menu.contact),
                        KhaoFooter(contact: menu.contact),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await t.pump();
        expect(t.takeException(), isNull);
        expect(find.text(KhaoStrings(lang).menuTitle), findsOneWidget);
      });
    }
  }

  testWidgets('toggle flips between Bangla and English', (t) async {
    final controller = KhaoLangController();
    await t.pumpWidget(
      KhaoL10n(
        controller: controller,
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: KhaoL10n.controllerOf(context).toggle,
              child: Text(context.tr.langToggleLabel),
            ),
          ),
        ),
      ),
    );
    expect(find.text('EN'), findsOneWidget);
    await t.tap(find.byType(TextButton));
    await t.pump();
    expect(controller.value, KhaoLang.en);
    expect(find.text('বাং'), findsOneWidget);
    await t.tap(find.byType(TextButton));
    await t.pump();
    expect(controller.value, KhaoLang.bn);
  });
}
