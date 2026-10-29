import 'dart:convert';

import 'package:flutter/services.dart';

import '../l10n/khao_l10n.dart';
import '../models/menu_models.dart';

/// Loads `assets/data/menu.json` into [KhaoMenu], once per language.
class MenuRepository {
  MenuRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const assetPath = 'assets/data/menu.json';

  final AssetBundle _bundle;
  Future<Map<String, dynamic>>? _raw;
  final _cache = <KhaoLang, Future<KhaoMenu>>{};

  Future<KhaoMenu> load([KhaoLang lang = KhaoLang.bn]) =>
      _cache[lang] ??= _load(lang);

  Future<KhaoMenu> _load(KhaoLang lang) async {
    final raw = await (_raw ??= _bundle
        .loadString(assetPath)
        .then((s) => jsonDecode(s) as Map<String, dynamic>));
    return KhaoMenu.fromJson(raw, lang);
  }
}
