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
  String langFooterLabel,
  String footerLabel,
  String legalLabel,
  String tagline,
  String home,
  String about,
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
    langFooterLabel: 'Switch language',
    footerLabel: 'Footer',
    legalLabel: 'Legal',
    tagline: 'Cube Algos, Heinsberg. Software studio since 2023.',
    home: 'Home',
    about: 'About',
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
    langFooterLabel: 'Sprache wechseln',
    footerLabel: 'Fußbereich',
    legalLabel: 'Rechtliches',
    tagline: 'Cube Algos, Heinsberg. Softwarestudio seit 2023.',
    home: 'Start',
    about: 'Über',
    contact: 'Kontakt',
    impressum: 'Impressum',
    datenschutz: 'Datenschutz',
    linkedin: 'Cube Algos auf LinkedIn',
    bottom: '© 2026 Cube Algos UG (haftungsbeschränkt)',
  ),
};
