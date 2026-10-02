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
      title: 'Cube Algos | Software studio in Heinsberg',
      description:
          'Cube Algos is a small software studio in Heinsberg: software of '
          'its own, and apps, internal tools and automations for businesses '
          'and founders.',
      h1:
          'Cube Algos is a small studio that builds software of its own, and '
          'yours.',
    ),
    Lang.de: (
      title: 'Cube Algos | Softwarestudio aus Heinsberg',
      description:
          'Cube Algos ist ein kleines Softwarestudio aus Heinsberg: eigene '
          'Software und Apps, interne Tools und Automatisierungen für '
          'Betriebe und Gründungsteams.',
      h1:
          'Cube Algos ist ein kleines Studio, das eigene Software baut, und '
          'Ihre.',
    ),
  },
  PageKey.about: {
    Lang.en: (
      title: 'About | Cube Algos',
      description:
          'Cube Algos is a software studio in Heinsberg, founded in 2023 by '
          'Kevin Scheeren. Apps, internal tools, automation, and software of '
          'its own.',
      h1: 'The studio and its founder',
    ),
    Lang.de: (
      title: 'Über Cube Algos | Cube Algos',
      description:
          'Cube Algos ist ein Softwarestudio aus Heinsberg, 2023 von Kevin '
          'Scheeren gegründet. Apps, interne Tools, Automatisierung und '
          'eigene Software.',
      h1: 'Das Studio und sein Gründer',
    ),
  },
  PageKey.contact: {
    Lang.en: (
      title: 'Contact | Cube Algos',
      description:
          'Write to Cube Algos in Heinsberg at hello@cubealgos.de. Tell Kevin '
          'what you need and book a free first call about your app or tool.',
      h1: 'Write to Kevin.',
    ),
    Lang.de: (
      title: 'Kontakt | Cube Algos',
      description:
          'Schreiben Sie Cube Algos in Heinsberg an hello@cubealgos.de: kurz '
          'beschreiben, was Sie brauchen, und ein kostenloses Erstgespräch '
          'vereinbaren.',
      h1: 'Schreiben Sie Kevin eine E-Mail.',
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
