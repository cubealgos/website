// SPDX-License-Identifier: Apache-2.0

/// The about page copy, EN and DE side by side (final brand copy, character
/// for character; all rights reserved).
// ignore_for_file: unnecessary_parenthesis
library;

import 'package:website/src/outbound.dart';
import 'package:website/src/routes.dart';

/// All copy of the about page in one language.
typedef AboutCopy = ({
  String h1,
  String lede,
  String whoTitle,
  List<String> who,

  /// The line before the founder's links, and the links, each a
  /// `[label](url)` to a URL of `outbound.dart`.
  String linksIntro,
  List<String> links,

  /// The alternative text of the founder's portrait.
  String photoAlt,
  String oneTitle,
  String one,
  String ownTitle,
  String own,

  /// The pointer to the studio's public code, with a `[label](url)` link.
  String ownCode,
  String howTitle,
  List<String> how,
  String whereTitle,
  String where,
  String ctaTitle,
});

/// The about copy per language.
const Map<Lang, AboutCopy> aboutCopy = {
  Lang.en: (
    h1: 'The studio and its founder',
    lede:
        'Cube Algos is a software studio in Heinsberg, founded in 2023 '
        'and run by Kevin Scheeren.',
    whoTitle: 'The founder',
    who: [
      ('Kevin Scheeren has been writing code since 2016, first at '
          'school and in his spare time, and professionally since 2019. '
          'He is a trained developer: he completed the apprenticeship as '
          'a Mathematisch-technischer Softwareentwickler (MATSE), a '
          'German IT qualification built on mathematics and software '
          'engineering.'),
      ('He founded Cube Algos in 2023 to build apps, SaaS and internal '
          'tools. He loves building software and wants to do it on his own '
          'terms: carefully, creatively, and for people who will actually '
          'use it.'),
    ],
    linksIntro: 'His CV and projects are on his own site:',
    links: [
      '[kevinscheeren.de]($personalSiteUrlEn)',
      '[GitHub]($githubProfileUrl)',
      '[LinkedIn]($linkedinProfileUrl)',
    ],
    photoAlt: 'Kevin Scheeren',
    oneTitle: 'One person, on purpose',
    one:
        'Cube Algos is run by one person. You talk directly to the '
        'person who builds your project, with no account manager in '
        'between and nothing lost in handover. Capacity is limited, so '
        'you get an honest start date before you sign.',
    ownTitle: 'Software of its own',
    own:
        'Cube Algos builds software of its own, and software for '
        'businesses and founders. The first product of its own is in '
        'development.',
    ownCode:
        'The code of this website and the Cube Algos brand are public on '
        '[GitHub]($githubOrgUrl|The Cube Algos GitHub organisation).',
    howTitle: 'How Cube Algos works',
    how: [
      'You see progress as it happens.',
      'Every build is accessible from the start.',
      'A free first call, then a written offer in about 3 working days.',
      ('AI tools are used every day, because they make the work '
          'faster. Kevin is also a trained developer, so he reads and '
          'understands every line before it ships. AI helps write the '
          'code; Kevin decides what goes live.'),
    ],
    whereTitle: 'Where Cube Algos is based',
    where:
        'Cube Algos UG (haftungsbeschränkt) is based in Heinsberg, in '
        'North Rhine-Westphalia, Germany. Most of the work happens '
        'remotely. Where it helps and fits, Kevin can also meet you in '
        'person around Heinsberg and Aachen. Just ask.',
    ctaTitle: 'Want to talk?',
  ),
  Lang.de: (
    h1: 'Das Studio und sein Gründer',
    lede:
        'Cube Algos ist ein Softwarestudio aus Heinsberg. Kevin Scheeren hat '
        'es 2023 gegründet und führt es bis heute selbst.',
    whoTitle: 'Der Gründer',
    who: [
      ('Kevin Scheeren programmiert seit 2016, erst in der Schule und in der '
          'Freizeit, seit 2019 beruflich. Seine Ausbildung zum '
          'Mathematisch-technischen Softwareentwickler (MATSE) hat er '
          'abgeschlossen.'),
      ('2023 hat er Cube Algos gegründet, um Apps, interne Tools und '
          'Automatisierungen zu bauen, und zwar so, wie er Software am '
          'liebsten baut: sorgfältig, mit eigenen Ideen und für Menschen, die '
          'sie wirklich nutzen.'),
    ],
    linksIntro: 'Lebenslauf und Projekte stehen auf Kevins eigener Website:',
    links: [
      '[kevinscheeren.de]($personalSiteUrl)',
      '[GitHub]($githubProfileUrl)',
      '[LinkedIn]($linkedinProfileUrl)',
    ],
    photoAlt: 'Kevin Scheeren',
    oneTitle: 'Eine Person, mit Absicht',
    one:
        'Bei Cube Algos sprechen Sie direkt mit dem Menschen, der Ihr '
        'Projekt baut. Es gibt keinen Account-Manager dazwischen, und bei '
        'keiner Übergabe geht etwas verloren. Weil die Zeit begrenzt ist, '
        'erhalten Sie vor Vertragsabschluss einen ehrlichen Starttermin.',
    ownTitle: 'Eigene Software',
    own:
        'Cube Algos entwickelt eigene Software und baut Software für '
        'Betriebe und Gründungsteams. Das erste eigene Produkt ist in '
        'Entwicklung.',
    ownCode:
        'Der Code dieser Website und die Marke von Cube Algos liegen '
        'öffentlich auf '
        '[GitHub]($githubOrgUrl|GitHub-Organisation von Cube Algos).',
    howTitle: 'So arbeitet Cube Algos',
    how: [
      'Den Fortschritt sehen Sie laufend.',
      'Jedes Projekt ist von Anfang an barrierearm.',
      ('Zuerst ein kostenloses Gespräch, dann innerhalb von etwa drei '
          'Werktagen ein schriftliches Angebot.'),
      ('KI-Werkzeuge gehören zum Alltag, weil sie die Arbeit schneller '
          'machen. Kevin ist ausgebildeter Entwickler und liest und versteht '
          'jede Zeile, bevor sie live geht. Die KI hilft beim Schreiben, die '
          'Entscheidung trifft Kevin.'),
    ],
    whereTitle: 'Standort',
    where:
        'Die Cube Algos UG (haftungsbeschränkt) sitzt in Heinsberg in '
        'Nordrhein-Westfalen. Die meiste Arbeit läuft remote. Wenn es hilft '
        'und passt, trifft Kevin Sie auch persönlich, rund um Heinsberg und '
        'Aachen.',
    ctaTitle: 'Interesse an einem Gespräch?',
  ),
};
