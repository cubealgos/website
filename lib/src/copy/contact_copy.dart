// SPDX-License-Identifier: Apache-2.0

/// The contact page copy, EN and DE side by side (copy v3, brand decisions 56
/// and 57; all rights reserved). Collaboration, integrations, grants and
/// press; no investor line (regulatory check of 2026-10-14, C-2).
library;

import 'package:website/src/routes.dart';

/// One topic: a bold `lead` and its `text`.
typedef Topic = ({String lead, String text});

/// All copy of the contact page in one language.
typedef ContactCopy = ({
  String h1,
  String lede,
  String note,
  String topicsTitle,
  List<Topic> topics,
  String securityTitle,

  /// The paragraph on vulnerability reports; `[label](mailto:…)` link and
  /// `code` span.
  String security,
});

/// The address vulnerability reports go to.
const securityEmail = 'security@cubealgos.de';

/// The contact copy per language.
const Map<Lang, ContactCopy> contactCopy = {
  Lang.en: (
    h1: 'Write to us.',
    lede: 'Email us about collaborations, integrations, grants or press.',
    note: 'We treat your email as confidential.',
    topicsTitle: 'What to write about',
    topics: [
      (
        lead: 'Collaboration.',
        text:
            'You research or build something related and want to work with '
            'us on something public.',
      ),
      (
        lead: 'Integrations.',
        text:
            'You plan to build one of our works into your wallet, app or '
            'protocol. Questions about using it are answered in public, in '
            "that repository's issues, so every reader benefits.",
      ),
      (
        lead: 'Grants.',
        text:
            'Public grant programmes and grants from foundations or '
            'protocols that fit our work.',
      ),
      (lead: 'Press.', text: 'Questions about Cube Algos and our work.'),
    ],
    securityTitle: 'Report a vulnerability',
    security:
        'Please send vulnerability reports to '
        '[$securityEmail](mailto:$securityEmail). What a report should '
        'include is in the `SECURITY.md` file of each repository. Please '
        'wait for a fix before you disclose anything publicly. We pass on '
        'what you report only as far as a fix or a legally required report '
        'needs it, and your name only with your consent.',
  ),
  Lang.de: (
    h1: 'Schreiben Sie uns.',
    lede:
        'Per E-Mail erreichen Sie uns für Zusammenarbeit, Integrationen, '
        'Förderprogramme und Presse.',
    note: 'Ihre E-Mail behandeln wir vertraulich.',
    topicsTitle: 'Worum es gehen kann',
    topics: [
      (
        lead: 'Zusammenarbeit.',
        text:
            'Sie forschen oder bauen an etwas Verwandtem und möchten '
            'gemeinsam an einer öffentlichen Arbeit ansetzen.',
      ),
      (
        lead: 'Integrationen.',
        text:
            'Sie möchten eine unserer Arbeiten in Ihre Wallet, App oder Ihr '
            'Protokoll einbinden. Fragen zur Nutzung beantworten wir '
            'öffentlich, in den Issues des jeweiligen Repositorys, damit '
            'alle etwas davon haben.',
      ),
      (
        lead: 'Förderprogramme.',
        text:
            'Öffentliche Förderprogramme und Grants von Stiftungen oder '
            'Protokollen, die zu unseren Arbeiten passen.',
      ),
      (lead: 'Presse.', text: 'Fragen zu Cube Algos und unseren Arbeiten.'),
    ],
    securityTitle: 'Schwachstellen melden',
    security:
        'Hinweise auf Schwachstellen schicken Sie bitte an '
        '[$securityEmail](mailto:$securityEmail). Was eine Meldung enthalten '
        'sollte, steht in der Datei `SECURITY.md` des jeweiligen '
        'Repositorys. Bitte veröffentlichen Sie Ihren Fund erst, wenn es '
        'eine Korrektur gibt. Was Sie melden, geben wir nur weiter, soweit '
        'eine Korrektur oder eine gesetzliche Meldung es verlangt; Ihren '
        'Namen nur mit Ihrer Zustimmung.',
  ),
};
