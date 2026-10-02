// SPDX-License-Identifier: Apache-2.0

/// Title, meta description and H1 placeholder of every page shell.
///
/// Titles and descriptions come from the brand copy; the real page content
/// arrives in #10 to #16.
library;

import 'package:website/src/routes.dart';

/// The head and heading text of one page in one language.
typedef PageMeta = ({String title, String description, String h1});

/// Every page's [PageMeta] per language.
const Map<PageKey, Map<Lang, PageMeta>> pageMeta = {
  PageKey.home: {
    Lang.en: (
      title: 'Cube Algos | Websites and apps, fixed prices',
      description:
          'Websites, apps and MVPs for owner-led businesses and founders. '
          'Fixed prices, built in Heinsberg by one person, cared for after '
          'launch.',
      h1: "Websites and apps for people who'd rather run their business.",
    ),
    Lang.de: (
      title: 'Cube Algos | Websites und Apps zum Festpreis',
      description:
          'Websites, Apps und MVPs für Inhaber:innen und Gründer:innen. '
          'Festpreise, gebaut in Heinsberg von einer Person, betreut nach '
          'dem Launch.',
      h1: 'Websites und Apps für alle, die lieber ihr Geschäft führen.',
    ),
  },
  PageKey.about: {
    Lang.en: (
      title: 'About | Cube Algos',
      description:
          "I'm Kevin Scheeren, and I build websites and apps at Cube Algos "
          'in Heinsberg. One person, fixed prices, and care after launch.',
      h1: "Hi, I'm Kevin.",
    ),
    Lang.de: (
      title: 'Über mich | Cube Algos',
      description:
          'Ich bin Kevin Scheeren und baue bei Cube Algos in Heinsberg '
          'Websites und Apps. Eine Person, feste Preise, Betreuung nach dem '
          'Launch.',
      h1: 'Hallo, ich bin Kevin.',
    ),
  },
  PageKey.contact: {
    Lang.en: (
      title: 'Contact | Cube Algos',
      description:
          'Write to Cube Algos in Heinsberg at hello@cubealgos.de. Tell me '
          "what you need, and I'll write back and suggest the next step.",
      h1: 'Contact',
    ),
    Lang.de: (
      title: 'Kontakt | Cube Algos',
      description:
          'Schreiben Sie Cube Algos in Heinsberg an hello@cubealgos.de. '
          'Erzählen Sie mir, was Sie brauchen, ich antworte und schlage den '
          'nächsten Schritt vor.',
      h1: 'Kontakt',
    ),
  },
  PageKey.impressum: {
    Lang.en: (
      title: 'Impressum | Cube Algos',
      description:
          'Legal notice under section 5 DDG for Cube Algos UG '
          '(haftungsbeschränkt), operator of cubealgos.de.',
      h1: 'Impressum',
    ),
    Lang.de: (
      title: 'Impressum | Cube Algos',
      description:
          'Angaben gemäß § 5 DDG für die Cube Algos UG (haftungsbeschränkt), '
          'Betreiberin von cubealgos.de.',
      h1: 'Impressum',
    ),
  },
  PageKey.datenschutz: {
    Lang.en: (
      title: 'Datenschutz | Cube Algos',
      description:
          'How Cube Algos UG (haftungsbeschränkt) handles personal data on '
          'cubealgos.de: no cookies, no tracking, no access logs.',
      h1: 'Datenschutz',
    ),
    Lang.de: (
      title: 'Datenschutz | Cube Algos',
      description:
          'Wie Cube Algos UG (haftungsbeschränkt) auf cubealgos.de mit '
          'personenbezogenen Daten umgeht: keine Cookies, kein Tracking, '
          'keine Zugriffsprotokolle.',
      h1: 'Datenschutz',
    ),
  },
  PageKey.notFound: {
    Lang.en: (
      title: 'Page not found | Cube Algos',
      description: 'The page you were looking for does not exist.',
      h1: 'This page swam off.',
    ),
    Lang.de: (
      title: 'Seite nicht gefunden | Cube Algos',
      description: 'Die gesuchte Seite existiert nicht.',
      h1: 'Diese Seite ist davongeschwommen.',
    ),
  },
};
