import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/khao_l10n.dart';
import '../models/menu_models.dart';

/// Opens contact links from `menu.json`. Placeholder values ("[link]") are
/// not launchable yet, so we tell the visitor instead of failing silently.
abstract final class KhaoLinks {
  static Future<void> open(BuildContext context, String value) async {
    final uri = _toUri(value);
    if (uri == null) {
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.tr.linkComingSoon)));
      return;
    }
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }

  static Future<void> call(BuildContext context, String phone) =>
      open(context, Contact.isPlaceholder(phone) ? phone : 'tel:$phone');

  static Uri? _toUri(String value) {
    if (Contact.isPlaceholder(value)) return null;
    final v = value.trim();
    if (v.startsWith('tel:')) {
      return Uri(scheme: 'tel', path: v.substring(4).replaceAll(' ', ''));
    }
    final uri = Uri.tryParse(v.contains('://') ? v : 'https://$v');
    return (uri == null || uri.host.isEmpty) ? null : uri;
  }
}
