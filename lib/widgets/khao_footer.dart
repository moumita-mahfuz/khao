import 'package:flutter/material.dart';

import '../l10n/khao_l10n.dart';
import '../models/menu_models.dart';
import '../theme/khao_theme.dart';
import 'common.dart';

/// Section 10: cream footer with logo, tagline, contact and copyright.
class KhaoFooter extends StatelessWidget {
  const KhaoFooter({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final desktop = KhaoLayout.isDesktop(context);
    final logo = Semantics(
      label: "KHAO",
      image: true,
      child: Image.asset(
        'assets/logo/logo-on-light.png',
        height: desktop ? 56 : 60,
        filterQuality: FilterQuality.high,
      ),
    );
    final tagline = Text(
      context.tr.footerTagline,
      textAlign: TextAlign.center,
      style: KhaoText.galada(desktop ? 26 : 22, color: KhaoColors.black),
    );
    final contactStyle = KhaoText.hind(
      desktop ? 15 : 14,
      height: 1.6,
      color: KhaoColors.black,
    );
    final contactInfo = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          contact.address.replaceAll('\n', ', '),
          textAlign: TextAlign.center,
          style: contactStyle,
        ),
        Text(
          [
            context.tr.digits(contact.phone),
            if (contact.instagramHandle != null) '@${contact.instagramHandle}',
            if (contact.website != null) contact.website!,
          ].join('  ·  '),
          textAlign: TextAlign.center,
          style: contactStyle.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
    final copyright = Text(
      context.tr.copyright,
      textAlign: TextAlign.center,
      style: KhaoText.hind(desktop ? 14 : 13, color: KhaoColors.richBrown),
    );

    return ColoredBox(
      color: KhaoColors.cream,
      child: desktop
          ? ContentWidth(
              horizontal: 64,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 48),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: [logo, tagline, contactInfo, copyright],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 36, 16, 40),
              child: Column(
                children: [
                  logo,
                  const SizedBox(height: 14),
                  tagline,
                  const SizedBox(height: 14),
                  contactInfo,
                  const SizedBox(height: 14),
                  copyright,
                ],
              ),
            ),
    );
  }
}
