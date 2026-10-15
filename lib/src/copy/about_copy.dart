// SPDX-License-Identifier: Apache-2.0

/// The about page copy, EN and DE side by side (copy v2, option A with the
/// founder section; all rights reserved).
// Long paragraphs are written as adjacent string literals for line length.
// ignore_for_file: no_adjacent_strings_in_list
library;

import 'package:website/src/outbound.dart';
import 'package:website/src/routes.dart';

/// One item of "how we work": its text and, for the AI item, the label of the
/// link to the blog post (left out while the post does not exist).
typedef HowItem = ({String text, String? postLabel});

/// All copy of the about page in one language.
typedef AboutCopy = ({
  String h1,
  String lede,
  String workTitle,
  List<String> work,
  String howTitle,
  List<HowItem> how,
  String whoTitle,
  String who,

  /// The founder's links, each a `[label](url)` to a URL of `outbound.dart`.
  List<String> links,

  /// The alternative text of the founder's portrait.
  String photoAlt,
  String whereTitle,
  String where,
  String ctaTitle,
  String ctaButton,
});

/// The about copy per language.
const Map<Lang, AboutCopy> aboutCopy = {
  Lang.en: (
    h1: 'About the studio',
    lede:
        'Cube Algos is a small software studio in Heinsberg, founded in '
        '2023. We build our own applications for decentralised finance and '
        'show them here once they are published.',
    workTitle: 'What we work on',
    work: [
      'For us, decentralised finance means software that runs on public '
          'blockchains, and contracts that nobody holds an admin key to, '
          'including us.',
      'Our focus is smart contracts and apps that let wallets do more on '
          'their own: read prices, pay for gas in another token, convert the '
          'tokens they receive. All of it is still in development.',
    ],
    howTitle: 'How we work',
    how: [
      (
        text:
            'Our contracts have no admin, pause or upgrade key. A fix is a '
            'new version.',
        postLabel: null,
      ),
      (
        text:
            'We call existing protocols through our own interfaces instead '
            'of copying their code.',
        postLabel: null,
      ),
      (
        text:
            'Our tests also run against copies of real chains, with the '
            'contracts that are actually deployed there.',
        postLabel: null,
      ),
      (
        text:
            'AI agents implement single tasks. Every change is reviewed '
            'against the specification, and a person confirms every merge.',
        postLabel: 'More on the blog',
      ),
      (text: 'Deploying and publishing are done by hand.', postLabel: null),
    ],
    whoTitle: 'Who is behind it',
    who:
        'Kevin Scheeren founded Cube Algos in 2023 and runs it as managing '
        'director. He has been writing code since 2016, professionally '
        'since 2019, and completed the apprenticeship as a '
        'Mathematisch-technischer Softwareentwickler (MATSE), a German '
        'qualification in mathematics and software engineering.',
    links: [
      '[kevinscheeren.de]($personalSiteUrlEn)',
      '[GitHub]($githubProfileUrl)',
      '[LinkedIn]($linkedinProfileUrl)',
    ],
    photoAlt: 'Kevin Scheeren',
    whereTitle: 'Where we are',
    where:
        'Cube Algos UG (haftungsbeschränkt) is based in Heinsberg, in North '
        'Rhine-Westphalia, Germany.',
    ctaTitle: 'Collaboration, grants or press?',
    ctaButton: 'Write to us',
  ),
  Lang.de: (
    h1: 'Über das Studio',
    lede:
        'Cube Algos ist ein kleines Softwarestudio in Heinsberg, gegründet '
        '2023. Wir bauen eigene Anwendungen für dezentrale Finanzen und '
        'zeigen sie hier, sobald sie veröffentlicht sind.',
    workTitle: 'Woran wir arbeiten',
    work: [
      'Dezentrale Finanzen heißt für uns: Software, die auf öffentlichen '
          'Blockchains läuft, und Smart Contracts, zu denen niemand einen '
          'Admin-Schlüssel hat, auch wir nicht.',
      'Unser Schwerpunkt sind Smart Contracts und Apps, mit denen Wallets '
          'mehr selbst erledigen: Preise lesen, Gas in einem anderen Token '
          'bezahlen, eingehende Token umwandeln. Alles davon ist noch in '
          'Entwicklung.',
    ],
    howTitle: 'So arbeiten wir',
    how: [
      (
        text:
            'Unsere Smart Contracts haben keinen Admin-, Pausen- oder '
            'Upgrade-Schlüssel. Eine Korrektur ist eine neue Version.',
        postLabel: null,
      ),
      (
        text:
            'Bestehende Protokolle rufen wir über eigene Schnittstellen auf, '
            'statt ihren Code zu kopieren.',
        postLabel: null,
      ),
      (
        text:
            'Unsere Tests laufen auch gegen Kopien echter Chains, mit den '
            'Smart Contracts, die dort wirklich bereitgestellt sind.',
        postLabel: null,
      ),
      (
        text:
            'KI-Agenten setzen einzelne Aufgaben um. Jede Änderung wird '
            'gegen die Spezifikation geprüft, und jeden Merge bestätigt ein '
            'Mensch.',
        postLabel: 'Mehr dazu im Blog',
      ),
      (
        text: 'Bereitstellen und veröffentlichen tun wir von Hand.',
        postLabel: null,
      ),
    ],
    whoTitle: 'Wer dahinter steht',
    who:
        'Kevin Scheeren hat Cube Algos 2023 gegründet und führt das Studio '
        'als Geschäftsführer. Er programmiert seit 2016, seit 2019 '
        'beruflich, und hat seine Ausbildung zum Mathematisch-technischen '
        'Softwareentwickler (MATSE) abgeschlossen.',
    links: [
      '[kevinscheeren.de]($personalSiteUrl)',
      '[GitHub]($githubProfileUrl)',
      '[LinkedIn]($linkedinProfileUrl)',
    ],
    photoAlt: 'Kevin Scheeren',
    whereTitle: 'Standort',
    where:
        'Die Cube Algos UG (haftungsbeschränkt) sitzt in Heinsberg in '
        'Nordrhein-Westfalen.',
    ctaTitle: 'Zusammenarbeit, Förderprogramme oder Presse?',
    ctaButton: 'Schreiben Sie uns',
  ),
};
