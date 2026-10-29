// SPDX-License-Identifier: Apache-2.0

/// Title, meta description and H1 of every page.
///
/// Titles and descriptions come from the brand copy (the reframe copy
/// direction C, brand decisions 56, 58 and 59, with the regulatory edits
/// E-C-1 to E-C-3). Home and Contact name wearenotabank; [pageMetaUnnamed]
/// holds their wording for the state in which the site does not
/// ([namesProduct]).
library;

import 'package:website/src/content/site_content.dart';
import 'package:website/src/outbound.dart';
import 'package:website/src/routes.dart';

/// The head and heading text of one page in one language.
typedef PageMeta = ({String title, String description, String h1});

/// Every page's [PageMeta] per language, for the state in which the site names
/// wearenotabank. The pages of a post take theirs from their data file
/// ([metaFor]).
const Map<PageKey, Map<Lang, PageMeta>> pageMeta = {
  PageKey.home: {
    Lang.en: (
      title: 'Cube Algos UG | Software studio in Heinsberg',
      description:
          'Cube Algos is the software studio behind wearenotabank: smart '
          'contracts, SDKs and Dart libraries for EVM chains. In Heinsberg, '
          'Germany, since 2023.',
      h1: 'Cube Algos is the studio behind wearenotabank.',
    ),
    Lang.de: (
      title: 'Cube Algos UG | Softwarestudio in Heinsberg',
      description:
          'Cube Algos ist das Softwarestudio hinter wearenotabank: Smart '
          'Contracts, SDKs und Dart-Bibliotheken für EVM-Chains. Seit 2023 in '
          'Heinsberg.',
      h1: 'Cube Algos ist das Studio hinter wearenotabank.',
    ),
  },
  PageKey.contact: {
    Lang.en: (
      title: 'Contact | Cube Algos',
      description:
          'Write to Cube Algos about collaboration, grants and press around '
          'wearenotabank. Report vulnerabilities to security@cubealgos.de.',
      h1: 'Write to us.',
    ),
    Lang.de: (
      title: 'Kontakt | Cube Algos',
      description:
          'Schreiben Sie Cube Algos zu Zusammenarbeit, Förderprogrammen und '
          'Presse rund um wearenotabank. Schwachstellen melden Sie an '
          'security@cubealgos.de.',
      h1: 'Schreiben Sie uns.',
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

/// The wording of the pages that name wearenotabank when the site does not
/// ([namesProduct] is false): Home carries the fallback H1 and a description
/// built from it and the fallback subline (copy section 3.5), Contact the
/// description of the live copy v3. Title and H1 of the other pages are the
/// same in both states.
const Map<PageKey, Map<Lang, PageMeta>> pageMetaUnnamed = {
  PageKey.home: {
    Lang.en: (
      title: 'Cube Algos UG | Software studio in Heinsberg',
      description:
          'We build our own software for EVM chains: smart contracts, SDKs '
          'and libraries, with a focus on Dart, from a studio in Heinsberg.',
      h1: 'We build our own software for EVM chains.',
    ),
    Lang.de: (
      title: 'Cube Algos UG | Softwarestudio in Heinsberg',
      description:
          'Wir bauen eigene Software für EVM-Chains: Smart Contracts, SDKs '
          'und Bibliotheken, mit Schwerpunkt auf Dart, aus einem Studio in '
          'Heinsberg.',
      h1: 'Wir bauen eigene Software für EVM-Chains.',
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
          'Schreiben Sie Cube Algos an hello@cubealgos.de, zu '
          'Zusammenarbeit, Integrationen, Förderprogrammen und Presse. '
          'Schwachstellen bitte an security@cubealgos.de.',
      h1: 'Schreiben Sie uns.',
    ),
  },
};

/// The suffix of the title of a post.
const siteTitleSuffix = ' | Cube Algos';

/// The head and heading text of [key] in [lang], a page without a slug, for the
/// state in which the site [named] wearenotabank or not.
PageMeta fixedMeta(PageKey key, Lang lang, {bool named = namesProduct}) =>
    (named ? null : pageMetaUnnamed[key]?[lang]) ?? pageMeta[key]![lang]!;

/// The head and heading text of [route]: the fixed table for the fixed pages,
/// the data file for a post. [named] is whether the site names
/// wearenotabank.
PageMeta metaFor(
  Route route,
  SiteContent content, {
  bool named = namesProduct,
}) {
  switch (route.key) {
    case PageKey.post:
      final post = content.postBySlug(route.lang, route.slug!)!;
      return (
        title: '${post.seoTitle}$siteTitleSuffix',
        description: post.description,
        h1: post.title,
      );
    case PageKey.home ||
        PageKey.contact ||
        PageKey.blog ||
        PageKey.impressum ||
        PageKey.datenschutz ||
        PageKey.notFound:
      return fixedMeta(route.key, route.lang, named: named);
  }
}
