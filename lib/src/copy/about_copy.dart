// SPDX-License-Identifier: Apache-2.0

/// The about page copy, EN and DE side by side (final brand copy, character
/// for character; all rights reserved).
// ignore_for_file: unnecessary_parenthesis
library;

import 'package:website/src/routes.dart';

/// All copy of the about page in one language.
typedef AboutCopy = ({
  String h1,
  String lede,
  String whoTitle,
  List<String> who,
  String oneTitle,
  String one,
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
      ('He founded Cube Algos in 2023 because he loves building '
          'software and wants to do it on his own terms: carefully, '
          'creatively, and for people who will actually use it.'),
    ],
    oneTitle: 'One person, on purpose',
    one:
        'Cube Algos is run by one person. You talk directly to the '
        'person who builds your project, with no account manager in '
        'between and nothing lost in handover. Capacity is limited, so '
        'you get an honest start date before you sign.',
    howTitle: 'How Cube Algos works',
    how: [
      'Fixed prices, in writing, before the build.',
      'You see progress as it happens.',
      'Every build is accessible from the start.',
      "When it's live, Cube Algos can keep looking after it.",
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
        'Cube Algos ist ein Softwarestudio in Heinsberg, 2023 gegründet '
        'und geführt von Kevin Scheeren.',
    whoTitle: 'Der Gründer',
    who: [
      ('Kevin Scheeren programmiert seit 2016, zuerst in der Schule '
          'und in seiner Freizeit, beruflich seit 2019. Er ist '
          'ausgebildeter Entwickler: Seine Ausbildung zum '
          'Mathematisch-technischen Softwareentwickler (MATSE) hat er '
          'abgeschlossen.'),
      ('Cube Algos hat er 2023 gegründet, weil er Software zu bauen '
          'liebt und das zu seinen eigenen Bedingungen tun möchte: '
          'sorgfältig, kreativ und für Menschen, die sie wirklich '
          'benutzen.'),
    ],
    oneTitle: 'Eine Person, mit Absicht',
    one:
        'Cube Algos wird von einer Person geführt. Sie sprechen direkt '
        'mit dem Menschen, der Ihr Projekt baut, ohne Account-Manager '
        'dazwischen und ohne Informationsverlust bei der Übergabe. Die '
        'Kapazität ist begrenzt, deshalb erhalten Sie vor '
        'Vertragsabschluss einen ehrlichen Starttermin.',
    howTitle: 'Wie Cube Algos arbeitet',
    how: [
      'Feste Preise, schriftlich, bevor gebaut wird.',
      'Sie sehen den Fortschritt, während er entsteht.',
      'Jedes Projekt wird von Anfang an barrierearm gebaut.',
      'Wenn es online ist, kann Cube Algos sich weiter darum kümmern.',
      ('KI-Werkzeuge kommen jeden Tag zum Einsatz, weil sie die Arbeit '
          'schneller machen. Als ausgebildeter Entwickler liest und '
          'versteht Kevin jede Zeile, bevor sie live geht. KI hilft beim '
          'Schreiben; was live geht, entscheidet Kevin.'),
    ],
    whereTitle: 'Wo Cube Algos sitzt',
    where:
        'Cube Algos UG (haftungsbeschränkt) hat ihren Sitz in '
        'Heinsberg, Nordrhein-Westfalen. Die meiste Arbeit läuft '
        'remote. Wenn es hilft und passt, trifft Kevin Sie auf Anfrage '
        'auch vor Ort, rund um Heinsberg und Aachen.',
    ctaTitle: 'Möchten Sie sprechen?',
  ),
};
