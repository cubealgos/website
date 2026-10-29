// SPDX-License-Identifier: Apache-2.0

/// The words of the shared page frame (header, footer, skip link) per
/// language.
library;

import 'package:website/src/routes.dart';

/// The frame text of one language.
typedef ChromeText = ({
  String skip,
  String homeLabel,
  String navLabel,
  String langLabel,
  String legalLabel,
  String blog,
  String contact,
  String impressum,
  String datenschutz,
  String linkedin,
  String bottom,
});

/// The e-mail address shown in the footer.
const contactEmail = 'hello@cubealgos.de';

/// The frame text per language.
const Map<Lang, ChromeText> chromeText = {
  Lang.en: (
    skip: 'Skip to content',
    homeLabel: 'Cube Algos, Home',
    navLabel: 'Main',
    langLabel: 'Language',
    legalLabel: 'Legal',
    blog: 'Blog',
    contact: 'Contact',
    impressum: 'Impressum',
    datenschutz: 'Datenschutz',
    linkedin: 'Cube Algos on LinkedIn',
    bottom: '© 2026 Cube Algos UG (haftungsbeschränkt)',
  ),
  Lang.de: (
    skip: 'Zum Inhalt springen',
    homeLabel: 'Cube Algos, Startseite',
    navLabel: 'Hauptnavigation',
    langLabel: 'Sprache',
    legalLabel: 'Rechtliches',
    blog: 'Blog',
    contact: 'Kontakt',
    impressum: 'Impressum',
    datenschutz: 'Datenschutz',
    linkedin: 'Cube Algos auf LinkedIn',
    bottom: '© 2026 Cube Algos UG (haftungsbeschränkt)',
  ),
};
