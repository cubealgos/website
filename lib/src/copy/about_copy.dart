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
    h1: "Hi, I'm Kevin.",
    lede:
        "I'm the person behind Cube Algos in Heinsberg. I build websites and "
        'apps, and I do the work myself.',
    whoTitle: 'Who I am',
    who: [
      ("I've been writing code since 2016, first at school and in my spare "
          'time, and professionally since 2019. '
          "I'm a trained developer: I completed the apprenticeship as a "
          'Mathematisch-technischer Softwareentwickler (MATSE), a German IT '
          'qualification built on mathematics and software engineering.'),
      ('I started Cube Algos because I love building software and want to do '
          'it on my own terms: carefully, creatively, and for people '
          "who'll actually use it."),
    ],
    oneTitle: 'One person, on purpose',
    one:
        'Cube Algos is me. That means you talk to the person who builds your '
        'project, with no account manager in between and nothing lost in '
        'handover. It also means I can only take on so much at a time, and '
        "I'll tell you honestly when I can start.",
    howTitle: 'How I work',
    how: [
      'Fixed prices, in writing, before I build.',
      'You see progress as it happens.',
      'Every build is accessible from the start.',
      "When it's live, I can keep looking after it.",
      ('I work with AI tools every day, because they make me faster. '
          "I'm also a trained developer, so I read and understand every line "
          "before it ships. AI helps me write code; it doesn't decide what "
          'goes live.'),
    ],
    whereTitle: 'Where I am',
    where:
        'Cube Algos UG (haftungsbeschränkt) is based in Heinsberg, in North '
        'Rhine-Westphalia, Germany. Most of my work happens remotely. Where '
        'it helps and fits, we can also meet in person around Heinsberg and '
        'Aachen. Just ask.',
    ctaTitle: 'Want to talk?',
  ),
  Lang.de: (
    h1: 'Hallo, ich bin Kevin.',
    lede:
        'Ich bin die Person hinter Cube Algos in Heinsberg. Ich baue '
        'Websites und Apps und mache die Arbeit selbst.',
    whoTitle: 'Wer ich bin',
    who: [
      ('Ich programmiere seit 2016, zuerst in der Schule und in meiner '
          'Freizeit, beruflich seit 2019. Ich bin ausgebildeter Entwickler: '
          'Meine Ausbildung zum Mathematisch-technischen '
          'Softwareentwickler (MATSE) habe ich abgeschlossen.'),
      ('Cube Algos habe ich gegründet, weil ich Software zu bauen liebe und '
          'das zu meinen eigenen Bedingungen tun möchte: sorgfältig, '
          'kreativ und für Menschen, die sie wirklich benutzen.'),
    ],
    oneTitle: 'Eine Person, mit Absicht',
    one:
        'Cube Algos bin ich. Das heißt, Sie sprechen mit der Person, die '
        'Ihr Projekt baut, ohne Account-Manager dazwischen und ohne '
        'Informationsverlust bei der Übergabe. Es heißt auch, dass ich nur '
        'eine begrenzte Menge gleichzeitig annehmen kann, und ich sage '
        'Ihnen ehrlich, wann ich anfangen kann.',
    howTitle: 'Wie ich arbeite',
    how: [
      'Feste Preise, schriftlich, bevor ich baue.',
      'Sie sehen den Fortschritt, während er entsteht.',
      'Jedes Projekt wird von Anfang an barrierearm gebaut.',
      'Wenn es online ist, kann ich mich weiter darum kümmern.',
      ('Ich arbeite jeden Tag mit KI-Werkzeugen, weil sie mich schneller '
          'machen. Als ausgebildeter Entwickler lese und verstehe ich jede '
          'Zeile, bevor sie live geht. KI hilft mir beim Schreiben, '
          'entscheiden tue ich.'),
    ],
    whereTitle: 'Wo ich sitze',
    where:
        'Cube Algos UG (haftungsbeschränkt) hat ihren Sitz in Heinsberg, '
        'Nordrhein-Westfalen. Die meiste Arbeit läuft remote. Wenn es hilft '
        'und passt, treffen wir uns auf Anfrage auch vor Ort, rund um '
        'Heinsberg und Aachen.',
    ctaTitle: 'Sollen wir sprechen?',
  ),
};
