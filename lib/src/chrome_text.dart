// SPDX-License-Identifier: Apache-2.0

/// The words of the shared page frame (header, footer, skip link) per
/// language. The footer text is the brand copy, character for character.
library;

import 'package:website/src/routes.dart';

/// The frame text of one language.
typedef ChromeText = ({
  String skip,
  String homeLabel,
  String navLabel,
  String langLabel,
  String footerLabel,
  String legalLabel,
  String tagline,
  String home,
  String about,
  String contact,
  String impressum,
  String datenschutz,
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
    footerLabel: 'Footer',
    legalLabel: 'Legal',
    tagline: 'Cube Algos, Heinsberg. Apps and internal tools, fixed prices.',
    home: 'Home',
    about: 'About',
    contact: 'Contact',
    impressum: 'Impressum',
    datenschutz: 'Datenschutz',
    bottom: '© 2026 Cube Algos UG (haftungsbeschränkt)',
  ),
  Lang.de: (
    skip: 'Zum Inhalt springen',
    homeLabel: 'Cube Algos, Startseite',
    navLabel: 'Hauptnavigation',
    langLabel: 'Sprache',
    footerLabel: 'Fußbereich',
    legalLabel: 'Rechtliches',
    tagline: 'Cube Algos, Heinsberg. Apps und interne Tools zum Festpreis.',
    home: 'Start',
    about: 'Über',
    contact: 'Kontakt',
    impressum: 'Impressum',
    datenschutz: 'Datenschutz',
    bottom: '© 2026 Cube Algos UG (haftungsbeschränkt)',
  ),
};
