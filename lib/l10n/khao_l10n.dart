import 'package:flutter/widgets.dart';

import '../models/bangla.dart';

/// The two site languages. Bangla is the default.
enum KhaoLang {
  bn,
  en;

  KhaoLang get other => this == bn ? en : bn;
}

/// Holds the current language; the top-bar toggle flips it.
class KhaoLangController extends ValueNotifier<KhaoLang> {
  KhaoLangController([super.value = KhaoLang.bn]);

  void toggle() => value = value.other;
}

/// Provides the current language to the tree and rebuilds dependents when
/// it changes. Wraps the whole app (above MaterialApp).
class KhaoL10n extends InheritedNotifier<KhaoLangController> {
  const KhaoL10n({
    super.key,
    required KhaoLangController controller,
    required super.child,
  }) : super(notifier: controller);

  static KhaoLangController controllerOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<KhaoL10n>()!.notifier!;

  /// Falls back to Bangla when no scope is present (e.g. isolated tests).
  static KhaoStrings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<KhaoL10n>();
    return KhaoStrings(scope?.notifier?.value ?? KhaoLang.bn);
  }
}

extension KhaoL10nContext on BuildContext {
  KhaoStrings get tr => KhaoL10n.of(this);
}

/// Every hard-coded UI string, in both languages. Menu content (items,
/// prices, contact) lives in `assets/data/menu.json` instead.
class KhaoStrings {
  const KhaoStrings(this.lang);

  final KhaoLang lang;

  bool get isBn => lang == KhaoLang.bn;
  String _t(String bn, String en) => isBn ? bn : en;

  // ---------------------------------------------------------------- numbers

  /// 110 → "১১০" (bn) / "110" (en).
  String num(int n) => isBn ? toBanglaDigits(n) : '$n';

  /// "01817988622" → Bangla digits in bn, unchanged in en.
  String digits(String s) => isBn ? banglaDigits(s) : s;

  /// 110 → "৳১১০" (bn) / "৳110" (en).
  String taka(int n) => '৳${num(n)}';

  // ---------------------------------------------------------------- app

  String get appTitle =>
      _t("KHAO — যত খাবে তত চাবে", "KHAO — Eat more, crave more");
  String menuLoadError(Object e) =>
      _t('মেনু লোড হয়নি: $e', "Couldn't load the menu: $e");
  String get linkComingSoon =>
      _t('লিংকটা শীঘ্রই যোগ হবে!', 'This link is coming soon!');

  // ---------------------------------------------------------------- top bar

  /// Label on the toggle: the language you switch *to*.
  String get langToggleLabel => _t('EN', 'বাং');
  String get backToTop => _t('উপরে যাও', 'Back to top');
  String get langToggleSemantic => _t('Switch to English', 'বাংলায় দেখো');
  String get openMenu => _t('মেনু খোলো', 'Open menu');
  String get closeMenu => _t('মেনু বন্ধ করো', 'Close menu');
  String get logoLabel => "KHAO logo";
  String get navMenu => _t('মেনু', 'Menu');
  String get navFindUs => _t('খুঁজে নাও', 'Find us');
  String get navQuickBites => _t('টুকটাক খাও', 'Quick Bites');

  // ---------------------------------------------------------------- menu page

  String get menuPageTitle => _t('পুরো মেনু', 'Full menu');
  String get back => _t('ফিরে যাও', 'Back');
  String get openPdf => _t('PDF খোলো', 'Open PDF');
  String get zoomHint => _t('বড় করে দেখতে দুই আঙুলে টানো', 'Pinch to zoom');
  String get menuImageLabel => _t(
    "KHAO-এর পুরো মেনু: দাম, কম্বো, পানীয় আর সস",
    "KHAO full menu: prices, combo, drinks and sauces",
  );

  // ---------------------------------------------------------------- hero

  String get nowOpenLong =>
      _t('এখন খোলা · মোহাম্মদপুর, ঢাকা', 'NOW OPEN · MOHAMMADPUR, DHAKA');
  String get nowOpenShort =>
      _t('এখন খোলা · মোহাম্মদপুর', 'NOW OPEN · MOHAMMADPUR');
  String get taglineLine1 => _t('যত খাবে', 'Eat more,');
  String get taglineLine2 => _t('তত চাবে', 'crave more.');
  String get tagline => _t('যত খাবে তত চাবে', 'Eat more, crave more');
  String get heroBodyLong => _t(
    'মোহাম্মদপুরের অলিগলিতে এবার জমবে আসল স্বাদের আড্ডা। ঝাল সিঙ্গারা, ক্রিসপি রোল, মোমো, বার্গার আর বিকেলের চা — সব এক জায়গায়।',
    'Real flavour comes to the lanes of Mohammadpur. Fiery singara, crispy rolls, momos, burgers and evening tea — all in one place.',
  );
  String get heroBodyShort => _t(
    'মোহাম্মদপুরের অলিগলিতে এবার জমবে আসল স্বাদের আড্ডা। ঝাল সিঙ্গারা, ক্রিসপি রোল, মোমো আর বার্গার — সব এক জায়গায়।',
    'Real flavour comes to the lanes of Mohammadpur. Fiery singara, crispy rolls, momos and burgers — all in one place.',
  );
  String get seeMenu => _t('মেনু দেখো', 'See menu');
  String get whereAreWe => _t('কোথায় আছি?', 'Where are we?');

  // ---------------------------------------------------------------- signature

  String get signatureKicker => _t('সিগনেচার বাইটস', 'SIGNATURE BITES');
  String get signatureHeading => _t(
    'একটু আলাদা।\nঝালে-মজায় ভরা।',
    'A little different.\nPacked with heat.',
  );
  String get signatureBodyLong => _t(
    'প্রতিটা আইটেম আমরা নিজেরা খেয়ে দেখে তারপর মেনুতে তুলেছি। পছন্দেরটা বেছে নাও, পরিমাণ ঠিক করো — বাকিটা আমাদের।',
    'We tasted every item ourselves before it made the menu. Pick your favourite, choose your size — we’ll do the rest.',
  );
  String get signatureBodyShort => _t(
    'পছন্দেরটা বেছে নাও, পরিমাণ ঠিক করো — বাকিটা আমাদের।',
    'Pick your favourite, choose your size — we’ll do the rest.',
  );
  String fromPrice(int price, {required bool long}) => isBn
      ? '${taka(price)} থেকে শুরু'
      : '${long ? 'STARTING AT' : 'FROM'} ${taka(price)}';
  String get order => _t('অর্ডার করো', 'Order');
  String orderItem(String name) => _t('অর্ডার করো — $name', 'Order — $name');
  String get size => _t('পরিমাণ', 'Size');
  String get spice => _t('ঝাল', 'Heat');
  String spiceLevel(int level) => _t('ঝাল ${num(level)}/৫', 'Heat $level/5');
  String get next => _t('পরেরটা', 'Next');
  String get previous => _t('আগেরটা', 'Previous');
  String carouselPosition(int i, int n) => '${num(i)}/${num(n)}';

  // ---------------------------------------------------------------- menu

  String get menuKicker =>
      _t('ছোট পিস থেকে বড় আড্ডা', 'Small bites, big hangouts');
  String get menuTitle => _t('টুকটাক খাও', 'Quick Bites');
  String get menuExtrasKicker =>
      _t('চুমুক, ভরপেট, আরও', 'Sips, full plates & more');
  String get comboOnly => _t('মাত্র', 'Only');
  String get saucesTitle => _t('এক্সট্রা সস', 'Extra Sauces');
  String get saucesCallout => _t(
    'এক্সট্রা সসে\nমজা আরও\nজমে যাবে!',
    'Extra sauces\nto make it\neven better!',
  );
  String get item => _t('আইটেম', 'Item');
  String get photo => _t('[ছবি]', '[photo]');
  String get photoNeeded => _t('[ছবি দরকার]', '[photo needed]');

  // ---------------------------------------------------------------- day

  String get dayKicker => _t('সকাল ১১টা থেকে রাত ১০টা', '11 am to 10 pm');
  String get dayTitle => _t('KHAO-এর একটা দিন', 'A day at KHAO');

  // ---------------------------------------------------------------- advance

  String get advanceKicker => _t(
    'অনুষ্ঠান, অফিস আর দাওয়াতের জন্য',
    'For events, offices & get-togethers',
  );
  String get advanceTitle => _t('অগ্রিম অর্ডার', 'Advance Order');
  String get advanceMinimum => _t('ন্যূনতম ৫টি', 'Minimum 5');
  String get advanceBody => _t(
    'আগে থেকে জানিয়ে দাও, ঘরোয়া স্বাদের ভরপেট খাবার সময়মতো রেডি থাকবে।',
    'Let us know ahead and we\'ll have hearty, home-style plates ready on time.',
  );
  String get advanceCta => _t('কল করে অর্ডার করো', 'Call to order');
  String get advancePerPlate => _t('প্রতি প্লেট', 'per plate');
  String get advanceNotOnFoodpanda => _t(
    'এই খাবারগুলো ফুডপান্ডায় পাওয়া যাবে না, কল করে অর্ডার করো।',
    'These dishes aren\'t on foodpanda, so call us to order.',
  );

  // ---------------------------------------------------------------- foodpanda

  String get orderOnFoodpanda =>
      _t('ফুডপান্ডায় অর্ডার করো', 'Order on foodpanda');
  String get foodpandaKicker => _t('ঘরে বসেই খাও', 'Eat at home');
  String get foodpandaNote => _t(
    'অগ্রিম অর্ডারের খাবার ছাড়া মেনুর সবকিছুই ফুডপান্ডায় পাবে।',
    'Everything on the menu except the advance-order dishes is on foodpanda.',
  );

  // ---------------------------------------------------------------- find us

  String get findUsKicker => _t('খুঁজে নাও', 'FIND US');
  String get findUsLine1 => _t('একবার খাও,\n', 'Eat once,\n');
  String get findUsLine2 => _t('বারবার আসো!', 'come back again!');
  String get findUsBodyLong => _t(
    'কাউন্টারে অর্ডার দাও, QR দিয়ে পে করো, গরম গরম তুলে নাও। ছোট দোকান, বড় আড্ডা।',
    'Order at the counter, pay by QR, grab it hot. Small shop, big hangouts.',
  );
  String get findUsBodyShort => _t(
    'কাউন্টারে অর্ডার দাও, QR দিয়ে পে করো, গরম গরম তুলে নাও।',
    'Order at the counter, pay by QR, grab it hot.',
  );
  String get viewOnMap => _t('ম্যাপে দেখো', 'View on map');
  String get map => _t('ম্যাপ', 'Map');
  String get call => _t('কল করো', 'Call');
  String get address => _t('ঠিকানা', 'Address');
  String get hours => _t('খোলা', 'Hours');
  String get phone => _t('ফোন', 'Phone');
  String follow({required bool long}) =>
      long ? _t('ফলো করো', 'Follow') : _t('ফলো', 'Follow');
  String website({required bool long}) =>
      long ? _t('ওয়েবসাইট', 'Website') : _t('ওয়েব', 'Web');
  String get shopPhotoLabel =>
      _t("মোহাম্মদপুরে KHAO-এর কাউন্টার", "KHAO counter in Mohammadpur");

  // ---------------------------------------------------------------- footer

  String get footerTagline => _t(
    'ভালো খাবার, ভালো মুড, ভালো আড্ডা',
    'Good food, good mood, good hangouts',
  );
  String get copyright =>
      _t("© ২০২৬ KHAO · মোহাম্মদপুর", "© 2026 KHAO · Mohammadpur");
}
