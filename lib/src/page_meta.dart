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
      title: 'Cube Algos | Apps and tools, fixed prices',
      description:
          'Apps and tools for businesses and founders from €1,000, at a fixed '
          'price after a free first call. Plus automation and self-hosting. '
          'From Heinsberg.',
      h1:
          'Apps and tools for businesses that would rather focus on their '
          'work.',
    ),
    Lang.de: (
      title: 'Cube Algos | Apps und Tools zum Festpreis',
      description:
          'Apps und Tools für Betriebe und Gründungsteams ab 1.000 €, zum '
          'Festpreis nach kostenlosem Erstgespräch. Dazu Automatisierung und '
          'Self-Hosting. Aus Heinsberg.',
      h1:
          'Apps und Tools für Betriebe, die sich lieber um ihr Geschäft '
          'kümmern.',
    ),
  },
  PageKey.about: {
    Lang.en: (
      title: 'About | Cube Algos',
      description:
          'Cube Algos is a software studio in Heinsberg, founded in 2023 and '
          'led by Kevin Scheeren. Apps and internal tools at fixed prices, '
          'with a free first call.',
      h1: 'The studio and its founder',
    ),
    Lang.de: (
      title: 'Über Cube Algos | Cube Algos',
      description:
          'Cube Algos ist ein Softwarestudio aus Heinsberg, 2023 von Kevin '
          'Scheeren gegründet. Apps, Tools und Automatisierung zum Festpreis, '
          'mit kostenlosem Erstgespräch.',
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
