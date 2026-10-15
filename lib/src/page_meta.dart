// SPDX-License-Identifier: Apache-2.0

/// Title, meta description and H1 of every page.
///
/// Titles and descriptions come from the brand copy (copy v3, brand
/// decisions 56 and 57).
library;

import 'package:website/src/content/site_content.dart';
import 'package:website/src/routes.dart';

/// The head and heading text of one page in one language.
typedef PageMeta = ({String title, String description, String h1});

/// Every page's [PageMeta] per language. The pages of a work and of a post
/// take theirs from their data file ([metaFor]).
const Map<PageKey, Map<Lang, PageMeta>> pageMeta = {
  PageKey.home: {
    Lang.en: (
      title: 'Cube Algos | Studio for decentralised finance',
      description:
          'Cube Algos is a decentralised-finance studio in Heinsberg. We build '
          'software that lets wallets do more on their own: read prices, pay '
          'for gas, convert tokens.',
      h1: 'We build software that lets wallets do more on their own.',
    ),
    Lang.de: (
      title: 'Cube Algos | Studio für dezentrale Finanzanwendungen',
      description:
          'Studio für dezentrale Finanzen in Heinsberg. Wir bauen Software, '
          'mit der Wallets mehr selbst erledigen: Preise lesen, Gas bezahlen, '
          'Token umwandeln.',
      h1: 'Wir bauen Software, mit der Wallets mehr selbst erledigen.',
    ),
  },
  PageKey.about: {
    Lang.en: (
      title: 'About | Cube Algos',
      description:
          'Cube Algos is a small studio in Heinsberg, founded in 2023. We '
          'build our own software for decentralised finance, mostly smart '
          'contracts and apps.',
      h1: 'About the studio',
    ),
    Lang.de: (
      title: 'Über Cube Algos | Cube Algos',
      description:
          'Cube Algos ist ein kleines Studio aus Heinsberg, gegründet 2023. '
          'Wir bauen eigene Software für dezentrale Finanzen, vor allem '
          'Smart Contracts und Apps.',
      h1: 'Über das Studio',
    ),
  },
  PageKey.contact: {
    Lang.en: (
      title: 'Contact | Cube Algos',
      description:
          'Write to Cube Algos at hello@cubealgos.de about collaborations, '
          'integrations, grants or press. Report vulnerabilities to '
          'security@cubealgos.de.',
      h1: 'Write to us.',
    ),
    Lang.de: (
      title: 'Kontakt | Cube Algos',
      description:
          'Schreiben Sie Cube Algos an hello@cubealgos.de, zu Zusammenarbeit, '
          'Integrationen, Förderprogrammen und Presse. Schwachstellen bitte '
          'an security@cubealgos.de.',
      h1: 'Schreiben Sie uns.',
    ),
  },
  PageKey.works: {
    Lang.en: (
      title: 'Work | Cube Algos',
      description:
          'The published work of Cube Algos: smart contracts and apps for '
          'decentralised finance, each with its status, licence and source '
          'code.',
      h1: 'Work',
    ),
    Lang.de: (
      title: 'Arbeiten | Cube Algos',
      description:
          'Die veröffentlichten Arbeiten von Cube Algos: Smart Contracts und '
          'Apps für dezentrale Finanzen, jeweils mit Status, Lizenz und '
          'Quelltext.',
      h1: 'Arbeiten',
    ),
  },
  PageKey.blog: {
    Lang.en: (
      title: 'Blog | Cube Algos',
      description:
          'Notes from the Cube Algos studio: how we work and what we learn '
          'along the way.',
      h1: 'Blog',
    ),
    Lang.de: (
      title: 'Blog | Cube Algos',
      description:
          'Notizen aus dem Studio von Cube Algos: wie wir arbeiten und was '
          'wir dabei lernen.',
      h1: 'Blog',
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

/// The suffix of the title of a work or a post.
const siteTitleSuffix = ' | Cube Algos';

/// The head and heading text of [route]: the fixed table for the fixed pages,
/// the data file for a work or a post.
PageMeta metaFor(Route route, SiteContent content) {
  switch (route.key) {
    case PageKey.work:
      final work = content.workBySlug(route.slug!)!;
      final name = work.nameIn(route.lang);
      return (
        title: '$name$siteTitleSuffix',
        description: work.line[route.lang]!.replaceAll('`', ''),
        h1: name,
      );
    case PageKey.post:
      final post = content.postBySlug(route.lang, route.slug!)!;
      return (
        title: '${post.seoTitle}$siteTitleSuffix',
        description: post.description,
        h1: post.title,
      );
    case PageKey.home ||
        PageKey.about ||
        PageKey.contact ||
        PageKey.works ||
        PageKey.blog ||
        PageKey.impressum ||
        PageKey.datenschutz ||
        PageKey.notFound:
      return pageMeta[route.key]![route.lang]!;
  }
}
