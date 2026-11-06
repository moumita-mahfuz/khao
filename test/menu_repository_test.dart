import 'package:flutter_test/flutter_test.dart';
import 'package:khao_web/data/menu_repository.dart';
import 'package:khao_web/l10n/khao_l10n.dart';
import 'package:khao_web/models/bangla.dart';
import 'package:khao_web/theme/khao_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toBanglaDigits / taka', () {
    expect(toBanglaDigits(0), '০');
    expect(toBanglaDigits(1234567890), '১২৩৪৫৬৭৮৯০');
    expect(taka(110), '৳১১০');
  });

  test('hasBangla guards Bebas usage', () {
    expect(KhaoText.hasBangla('FISH CUTLET'), isFalse);
    expect(KhaoText.hasBangla('৳৮০'), isTrue);
  });

  test('menu.json loads into models', () async {
    final menu = await MenuRepository().load();
    expect(menu.tiers.map((t) => t.short), ['অল্প', 'বেশি', 'অনেক']);
    expect(menu.tiers.first.pieces, '৪ পিস');
    expect(menu.snacks, hasLength(4));
    expect(menu.snacks[1].thumbImage, 'assets/images/snack-roll.jpg');
    expect(menu.combo.price, 160);
    expect(menu.combo.item.name, 'সব একসাথে খাও');
    expect(menu.combo.includesJoined.last, '১টি গ্রিন সস / তেঁতুলের সস');
    expect(menu.carouselItems.map((i) => i.id), menu.carouselOrder);
    expect(menu.carouselItems[menu.carouselStartIndex].id, 'roll');
    expect(menu.dayparts.last.isPriceList, isTrue);
    expect(menu.categoryItems, hasLength(5));
    expect(menu.advanceOrderItems.map((i) => i.price), [
      200,
      170,
      230,
      250,
      260,
      170,
    ]);
    // Every category id resolves to an item.
    for (final c in menu.categories) {
      for (final id in c.itemIds) {
        expect(menu.byId, contains(id));
      }
    }
    for (final id in menu.advanceOrderIds) {
      expect(menu.byId, contains(id));
    }
    expect(menu.byId['momo-signature']!.price, 200);
    expect(menu.byId['burger-bbq']!.price, 210);
    expect(menu.signatureItems.map((i) => i.id), [
      'momo-signature',
      'burger-bbq',
      'bunbahar',
    ]);
    expect(menu.sauces.map((i) => i.price), [10, 10]);
    expect(menu.sauces.every((i) => i.color != null), isTrue);
    expect(menu.contact.phone, '01817988622');
    expect(menu.contact.website, 'khao.online');
    expect(menu.tickerLabels.first, 'সিঙ্গারা');
  });

  test('English menu: same prices, English text', () async {
    final repo = MenuRepository();
    final bn = await repo.load(KhaoLang.bn);
    final en = await repo.load(KhaoLang.en);
    expect(en.tiers.map((t) => t.short), ['Little', 'More', 'Lots']);
    expect(en.tiers.first.pieces, '4 pcs');
    expect(en.tiers.first.sauces, '1 sauce');
    expect(en.combo.name, 'Eat It All Together');
    expect(en.contact.address, contains('Dhaka-1207'));
    // Prices are shared, never translated.
    expect(
      en.byId.map((k, v) => MapEntry(k, v.prices)),
      bn.byId.map((k, v) => MapEntry(k, v.prices)),
    );
    // No Bangla anywhere in English menu text.
    for (final i in en.byId.values) {
      for (final s in [i.name, i.tagline, i.desc, i.carouselSub]) {
        if (s != null) expect(KhaoText.hasBangla(s), isFalse, reason: s);
      }
    }
    for (final l in en.tickerLabels) {
      expect(KhaoText.hasBangla(l), isFalse);
    }
  });

  test('strings: digits and prices follow the language', () {
    const bn = KhaoStrings(KhaoLang.bn);
    const en = KhaoStrings(KhaoLang.en);
    expect(bn.taka(120), '৳১২০');
    expect(en.taka(120), '৳120');
    expect(bn.digits('01817988622'), '০১৮১৭৯৮৮৬২২');
    expect(en.digits('01817988622'), '01817988622');
  });
}
