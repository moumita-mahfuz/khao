/// Data models for `assets/data/menu.json`.
///
/// Text fields in the JSON are either a plain string (same in both
/// languages) or a `{"bn": …, "en": …}` pair; each `fromJson` takes the
/// language and resolves them, so widgets just read plain strings.
library;

import '../l10n/khao_l10n.dart';

/// Resolves a plain string or a `{"bn","en"}` map; falls back to Bangla.
String? _text(Object? v, KhaoLang lang) => switch (v) {
  null => null,
  String s => s,
  Map m => (m[lang.name] ?? m['bn']) as String?,
  _ => throw FormatException('Expected text, got $v'),
};

String _req(Object? v, KhaoLang lang) => _text(v, lang)!;

List<String> _list(Object? v, KhaoLang lang) => switch (v) {
  List l => l.cast<String>(),
  Map m => ((m[lang.name] ?? m['bn']) as List).cast<String>(),
  _ => throw FormatException('Expected list, got $v'),
};

/// "#RRGGBB" -> 0xFFRRGGBB.
int? _color(Object? v) => v is String
    ? 0xFF000000 | int.parse(v.replaceFirst('#', ''), radix: 16)
    : null;

class Tier {
  const Tier({
    required this.id,
    required this.label,
    required this.short,
    required this.detail,
  });

  factory Tier.fromJson(Map<String, dynamic> j, KhaoLang lang) => Tier(
    id: j['id'] as String,
    label: _req(j['label'], lang),
    short: _req(j['short'], lang),
    detail: _req(j['detail'], lang),
  );

  final String id;

  /// "অল্প খাও" / "Eat a Little"
  final String label;

  /// "অল্প" / "Little"
  final String short;

  /// "৪ পিস + ১টি সস" / "4 pcs + 1 sauce"
  final String detail;

  /// "৪ পিস" / "4 pcs"
  String get pieces => detail.split('+').first.trim();

  /// "১টি সস" / "1 sauce" (empty if the detail has no "+").
  String get sauces {
    final i = detail.indexOf('+');
    return i < 0 ? '' : detail.substring(i + 1).trim();
  }
}

/// Any orderable thing: snacks, the combo, daypart dishes and drinks.
class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.prices,
    this.nameEn,
    this.shortName,
    this.tagline,
    this.desc,
    this.carouselSub,
    this.spice = 0,
    this.image,
    this.thumb,
    this.placeholderTag,
    this.color,
  });

  factory MenuItem.fromJson(Map<String, dynamic> j, KhaoLang lang) => MenuItem(
    id: j['id'] as String,
    name: _req(j['name'], lang),
    nameEn: j['nameEn'] as String?,
    shortName: _text(j['shortName'], lang),
    tagline: _text(j['tagline'], lang),
    desc: _text(j['desc'], lang),
    carouselSub: _text(j['carouselSub'], lang),
    prices: j['prices'] != null
        ? (j['prices'] as List).cast<int>()
        : [j['price'] as int],
    spice: (j['spice'] as int?) ?? 0,
    image: j['image'] as String?,
    thumb: j['thumb'] as String?,
    placeholderTag: j['placeholderTag'] as String?,
    color: _color(j['color']),
  );

  final String id;
  final String name;

  /// Uppercase Latin name for the ticker (English mode).
  final String? nameEn;
  final String? shortName;
  final String? tagline;
  final String? desc;
  final String? carouselSub;

  /// One price per tier for snacks; a single price otherwise.
  final List<int> prices;

  /// 0–5.
  final int spice;
  final String? image;

  /// Optional alternative photo for small circular thumbnails.
  final String? thumb;
  final String? placeholderTag;

  /// Accent colour as 0xAARRGGBB (sauce bowls), from "#RRGGBB" in the JSON.
  final int? color;

  bool get hasTiers => prices.length > 1;
  int get fromPrice => prices.first;
  int get price => prices.first;
  String? get thumbImage => thumb ?? image;

  /// Subtitle shown on carousel cards.
  String get subtitle => carouselSub ?? tagline ?? desc ?? '';
}

class Combo {
  const Combo({
    required this.item,
    required this.name,
    required this.tagline,
    required this.includes,
  });

  factory Combo.fromJson(Map<String, dynamic> j, KhaoLang lang) => Combo(
    item: MenuItem.fromJson({
      ...j,
      'name': j['carouselName'] ?? j['name'],
    }, lang),
    name: _req(j['name'], lang),
    tagline: _req(j['tagline'], lang),
    includes: _list(j['includes'], lang),
  );

  /// Carousel representation.
  final MenuItem item;

  /// Table name ("সব একসাথে খাও").
  final String name;
  final String tagline;
  final List<String> includes;
  int get price => item.price;

  /// Includes, with a trailing "+ ২টি সস" folded into the previous line.
  List<String> get includesJoined {
    final out = <String>[];
    for (final s in includes) {
      if (s.trimLeft().startsWith('+') && out.isNotEmpty) {
        out[out.length - 1] = '${out.last} $s';
      } else {
        out.add(s);
      }
    }
    return out;
  }
}

class Daypart {
  const Daypart({
    required this.id,
    required this.dot,
    required this.label,
    required this.title,
    this.item,
    this.quote,
    this.desc,
    this.items = const [],
    this.quickBiteIds = const [],
  });

  factory Daypart.fromJson(Map<String, dynamic> j, KhaoLang lang) => Daypart(
    id: j['id'] as String,
    dot: _req(j['dot'], lang),
    label: _req(j['label'], lang),
    title: _req(j['title'], lang),
    item: j['item'] == null
        ? null
        : MenuItem.fromJson(j['item'] as Map<String, dynamic>, lang),
    quote: _text(j['quote'], lang),
    desc: _text(j['desc'], lang),
    items: [
      for (final i in (j['items'] as List?) ?? const [])
        MenuItem.fromJson(i as Map<String, dynamic>, lang),
    ],
    quickBiteIds: (j['quickBites'] as List?)?.cast<String>() ?? const [],
  );

  final String id;

  /// Hour shown in the timeline dot ("১১" / "11").
  final String dot;

  /// "দুপুর · ১১টা – ৪টা"
  final String label;
  final String title;

  /// Featured dish (lunch / evening).
  final MenuItem? item;

  /// Price-list variant (all-day drinks & sauces).
  final String? quote;
  final String? desc;
  final List<MenuItem> items;

  /// Snack ids listed at their smallest tier (all-day price list).
  final List<String> quickBiteIds;

  bool get isPriceList => item == null;
}

class Contact {
  const Contact({
    required this.address,
    required this.hours,
    required this.phone,
    required this.facebook,
    required this.instagram,
    required this.mapUrl,
    this.instagramHandle,
    this.website,
  });

  factory Contact.fromJson(Map<String, dynamic> j, KhaoLang lang) => Contact(
    address: _req(j['address'], lang),
    hours: _req(j['hours'], lang),
    phone: j['phone'] as String,
    facebook: j['facebook'] as String,
    instagram: j['instagram'] as String,
    instagramHandle: j['instagramHandle'] as String?,
    website: j['website'] as String?,
    mapUrl: j['mapUrl'] as String,
  );

  final String address;
  final String hours;

  /// Raw digits ("01817988622"); localise digits only for display.
  final String phone;
  final String facebook;
  final String instagram;

  /// "official.khaobd" (shown as "@official.khaobd").
  final String? instagramHandle;

  /// "khao.online"
  final String? website;
  final String mapUrl;

  /// Placeholders look like "[link]"; they are not launchable yet.
  static bool isPlaceholder(String v) => v.trim().startsWith('[');
}

/// A titled group of non-tiered items (drinks, lunch, sauces…) shown as a
/// card in the menu section. Items are referenced by id so prices live in
/// one place.
class MenuCategory {
  const MenuCategory({required this.title, required this.itemIds});

  factory MenuCategory.fromJson(Map<String, dynamic> j, KhaoLang lang) =>
      MenuCategory(
        title: _req(j['title'], lang),
        itemIds: (j['items'] as List).cast<String>(),
      );

  final String title;
  final List<String> itemIds;
}

class KhaoMenu {
  const KhaoMenu({
    required this.lang,
    required this.currency,
    required this.tiers,
    required this.snacks,
    required this.combo,
    required this.dayparts,
    this.categories = const [],
    this.sauceIds = const [],
    required this.carouselOrder,
    required this.tickerOrder,
    required this.carouselStartIndex,
    required this.contact,
  });

  factory KhaoMenu.fromJson(
    Map<String, dynamic> j, [
    KhaoLang lang = KhaoLang.bn,
  ]) {
    final snacks = [
      for (final s in j['snacks'] as List)
        MenuItem.fromJson(s as Map<String, dynamic>, lang),
    ];
    final carouselOrder = (j['carouselOrder'] as List).cast<String>();
    return KhaoMenu(
      lang: lang,
      currency: j['currency'] as String,
      tiers: [
        for (final t in j['tiers'] as List)
          Tier.fromJson(t as Map<String, dynamic>, lang),
      ],
      snacks: snacks,
      combo: Combo.fromJson(j['combo'] as Map<String, dynamic>, lang),
      dayparts: [
        for (final d in j['dayparts'] as List)
          Daypart.fromJson(d as Map<String, dynamic>, lang),
      ],
      categories: [
        for (final c in (j['menuCategories'] as List?) ?? const [])
          MenuCategory.fromJson(c as Map<String, dynamic>, lang),
      ],
      sauceIds: (j['sauces'] as List?)?.cast<String>() ?? const [],
      carouselOrder: carouselOrder,
      tickerOrder: (j['tickerOrder'] as List?)?.cast<String>() ?? carouselOrder,
      carouselStartIndex: (j['carouselStartIndex'] as int?) ?? 0,
      contact: Contact.fromJson(j['contact'] as Map<String, dynamic>, lang),
    );
  }

  final KhaoLang lang;
  final String currency;
  final List<Tier> tiers;
  final List<MenuItem> snacks;
  final Combo combo;
  final List<Daypart> dayparts;
  final List<MenuCategory> categories;

  /// Extra sauces shown beside the snack table.
  final List<String> sauceIds;
  final List<String> carouselOrder;
  final List<String> tickerOrder;
  final int carouselStartIndex;
  final Contact contact;

  /// Every item by id (snacks, combo, daypart dishes, drinks).
  Map<String, MenuItem> get byId => {
    for (final s in snacks) s.id: s,
    combo.item.id: combo.item,
    for (final d in dayparts) ...{
      if (d.item != null) d.item!.id: d.item!,
      for (final i in d.items) i.id: i,
    },
  };

  /// Categories with their ids resolved; unknown ids are skipped.
  List<(String, List<MenuItem>)> get categoryItems {
    final m = byId;
    return [
      for (final c in categories)
        (
          c.title,
          [
            for (final id in c.itemIds)
              if (m[id] != null) m[id]!,
          ],
        ),
    ];
  }

  List<MenuItem> get sauces {
    final m = byId;
    return [
      for (final id in sauceIds)
        if (m[id] != null) m[id]!,
    ];
  }

  /// [d]'s quick bites as (name, smallest-tier detail, price), e.g.
  /// ("নাগা সিঙ্গারা", "৪ পিস + ১টি সস", 60). Unknown ids are skipped.
  List<(String, String, int)> quickBitesFor(Daypart d) {
    final m = byId;
    final detail = tiers.isEmpty ? '' : tiers.first.detail;
    return [
      for (final id in d.quickBiteIds)
        if (m[id] != null) (m[id]!.name, detail, m[id]!.fromPrice),
    ];
  }

  List<MenuItem> get carouselItems {
    final m = byId;
    return [
      for (final id in carouselOrder)
        if (m[id] != null) m[id]!,
    ];
  }

  /// Ticker labels: uppercase Latin names in English, item names in Bangla.
  List<String> get tickerLabels {
    final m = byId;
    return [
      for (final id in tickerOrder)
        if (m[id] != null)
          if (lang == KhaoLang.bn)
            m[id]!.name
          else if (m[id]!.nameEn != null)
            m[id]!.nameEn!,
    ];
  }
}
