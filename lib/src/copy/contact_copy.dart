// SPDX-License-Identifier: Apache-2.0

/// The contact page copy, EN and DE side by side (final brand copy, character
/// for character; all rights reserved).
// ignore_for_file: unnecessary_parenthesis
library;

import 'package:website/src/routes.dart';

/// All copy of the contact page in one language.
typedef ContactCopy = ({
  String h1,
  String lede,
  String includeTitle,
  String includeIntro,
  List<String> include,
  String includeOutro,
  String nextTitle,
  List<String> next,
  String nextNote,
});

/// The contact copy per language.
const Map<Lang, ContactCopy> contactCopy = {
  Lang.en: (
    h1: 'Write to Kevin.',
    lede:
        'No form and no sales pitch. Tell Kevin what you need; he reads '
        'every email himself and writes back with a suggested next '
        'step.',
    includeTitle: 'What to include',
    includeIntro: 'A few lines are enough. If you can, tell Kevin:',
    include: [
      'What your business or project is, in a sentence.',
      ('What you want built: a booking tool, a customer portal, a '
          'dashboard, an MVP, or "not sure yet".'),
      'Who will use it.',
      "Whether there's a date it needs to be ready by.",
      ('Roughly what you have already: nothing, a sketch, a '
          'spreadsheet, an existing app.'),
      "Anything you've seen that you like or don't like.",
    ],
    includeOutro:
        'Not sure about any of it? Write anyway. Working that out is '
        'what the free call is for.',
    nextTitle: 'What happens next',
    next: [
      'You write. Kevin reads it himself.',
      'He writes back, with questions or a suggestion.',
      ('If it fits, you have a free call of 30 to 45 minutes, by video '
          'or phone.'),
      ('Within about 3 working days after the call, you get a written '
          'scope with a fixed price and a start date.'),
      "You decide. If you don't go ahead, it costs nothing.",
    ],
    nextNote: 'Your email stays confidential. This page has no tracking.',
  ),
  Lang.de: (
    h1: 'Schreiben Sie Kevin.',
    lede:
        'Kein Formular und kein Verkaufsdruck. Erzählen Sie Kevin, '
        'was Sie brauchen; er liest jede E-Mail selbst und antwortet '
        'mit einem Vorschlag für den nächsten Schritt.',
    includeTitle: 'Was in die erste E-Mail gehört',
    includeIntro: 'Ein paar Zeilen genügen. Wenn Sie können, nennen Sie Kevin:',
    include: [
      'Was Ihr Unternehmen oder Projekt ist, in einem Satz.',
      ('Was gebaut werden soll: Terminbuchung, Kundenportal, Dashboard, '
          'MVP oder „noch unklar“.'),
      'Wer es nutzen wird.',
      'Ob es einen Termin gibt, bis zu dem es fertig sein muss.',
      ('Was schon vorhanden ist: nichts, eine Skizze, eine Tabelle, '
          'eine bestehende App.'),
      'Was Sie anderswo gesehen haben und mögen oder nicht mögen.',
    ],
    includeOutro:
        'Bei etwas unsicher? Schreiben Sie trotzdem. Genau dafür ist '
        'das kostenlose Gespräch da.',
    nextTitle: 'Wie es weitergeht',
    next: [
      'Sie schreiben. Kevin liest es selbst.',
      'Er antwortet, mit Rückfragen oder einem Vorschlag.',
      ('Passt es, folgt ein kostenloses Gespräch von 30 bis 45 Minuten, '
          'per Video oder Telefon.'),
      ('Innerhalb von etwa 3 Werktagen nach dem Gespräch erhalten Sie '
          'einen schriftlichen Umfang mit Festpreis und Starttermin.'),
      'Sie entscheiden. Entscheiden Sie sich dagegen, kostet es nichts.',
    ],
    nextNote:
        'Ihre E-Mail bleibt vertraulich. Diese Seite verwendet kein '
        'Tracking.',
  ),
};
