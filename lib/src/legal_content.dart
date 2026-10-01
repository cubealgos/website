// SPDX-License-Identifier: Apache-2.0

/// The text of the legal pages. The German text is authoritative; the English
/// text is a courtesy translation. The structure follows the August prototype
/// (CW-46), updated to the current facts.
library;

// Long paragraphs are written as adjacent string literals for line length.
// ignore_for_file: no_adjacent_strings_in_list

import 'package:website/src/legal_facts.dart';
import 'package:website/src/legal_model.dart';
import 'package:website/src/routes.dart';

/// The line at the top of every English legal page.
const authoritativeNotice =
    'The German version of this page is legally authoritative.';

const _mail = Link(email, 'mailto:$email');
const _tel = Link(phone, phoneUri);

const _impressumDe = LegalDoc(
  sections: [
    Section('Angaben gemäß § 5 DDG', [
      Facts([
        (
          label: 'Anbieter',
          lines: [
            [companyName],
            [addressStreet],
            [addressCity],
            ['Deutschland'],
          ],
        ),
        (
          label: 'Vertreten durch',
          lines: [
            ['$managingDirector (Geschäftsführer)'],
          ],
        ),
        (
          label: 'Kontakt',
          lines: [
            ['E-Mail: ', _mail],
            ['Telefon: ', _tel],
          ],
        ),
        (
          label: 'Registereintrag',
          lines: [
            ['Eingetragen im Handelsregister.'],
            ['Registergericht: $registerCourt'],
            ['Registernummer: $registerNumber'],
          ],
        ),
        (
          label: 'Umsatzsteuer-ID',
          lines: [
            [
              'Umsatzsteuer-Identifikationsnummer gemäß § 27a '
                  'Umsatzsteuergesetz:',
            ],
            [vatId],
          ],
        ),
      ]),
    ]),
    Section('Haftung für Inhalte', [
      Para([
        'Als Diensteanbieter sind wir gemäß § 7 Abs. 1 DDG für eigene Inhalte '
            'auf diesen Seiten nach den allgemeinen Gesetzen verantwortlich. '
            'Nach §§ 8 bis 10 DDG sind wir als Diensteanbieter jedoch nicht '
            'verpflichtet, übermittelte oder gespeicherte fremde Informationen '
            'zu überwachen oder nach Umständen zu forschen, die auf eine '
            'rechtswidrige Tätigkeit hinweisen. Verpflichtungen zur Entfernung '
            'oder Sperrung der Nutzung von Informationen nach den allgemeinen '
            'Gesetzen bleiben hiervon unberührt. Eine diesbezügliche Haftung '
            'ist jedoch erst ab dem Zeitpunkt der Kenntnis einer konkreten '
            'Rechtsverletzung möglich. Bei Bekanntwerden von entsprechenden '
            'Rechtsverletzungen werden wir diese Inhalte umgehend entfernen.',
      ]),
    ]),
    Section('Haftung für Links', [
      Para([
        'Unser Angebot kann Links zu externen Webseiten Dritter enthalten, '
            'auf deren Inhalte wir keinen Einfluss haben. Deshalb können wir '
            'für diese fremden Inhalte auch keine Gewähr übernehmen. Für die '
            'Inhalte der verlinkten Seiten ist stets der jeweilige Anbieter '
            'oder Betreiber der Seiten verantwortlich.',
      ]),
    ]),
  ],
);

const _impressumEn = LegalDoc(
  notice: authoritativeNotice,
  sections: [
    Section('Information pursuant to § 5 DDG', [
      Facts([
        (
          label: 'Provider',
          lines: [
            [companyName],
            [addressStreet],
            [addressCity],
            ['Germany'],
          ],
        ),
        (
          label: 'Represented by',
          lines: [
            ['$managingDirector (Managing Director, Geschäftsführer)'],
          ],
        ),
        (
          label: 'Contact',
          lines: [
            ['Email: ', _mail],
            ['Phone: ', _tel],
          ],
        ),
        (
          label: 'Commercial register entry',
          lines: [
            ['Registered with the commercial register (Handelsregister).'],
            ['Register court: $registerCourt'],
            ['Register number: $registerNumber'],
          ],
        ),
        (
          label: 'VAT ID (Umsatzsteuer-ID)',
          lines: [
            [
              'VAT identification number pursuant to § 27a of the German VAT '
                  'Act (Umsatzsteuergesetz):',
            ],
            [vatId],
          ],
        ),
      ]),
    ]),
    Section('Liability for content', [
      Para([
        'As a service provider, we are responsible for our own content on '
            'these pages under general law pursuant to § 7(1) DDG. Under '
            '§§ 8 to 10 DDG, however, we are not obliged to monitor '
            'transmitted or stored third-party information, or to investigate '
            'circumstances indicating unlawful activity. Obligations to remove '
            'or block the use of information under general law remain '
            'unaffected. Liability in this respect is only possible from the '
            'point in time at which we become aware of a specific '
            'infringement. Upon becoming aware of any such infringements, we '
            'will remove the relevant content immediately.',
      ]),
    ]),
    Section('Liability for links', [
      Para([
        'Our site may contain links to external third-party websites over '
            'whose content we have no control. We therefore cannot accept any '
            'liability for this external content. The respective provider or '
            "operator of a linked page is always responsible for that page's "
            'content.',
      ]),
    ]),
  ],
);

/// The legal pages' text per page and language.
const Map<PageKey, Map<Lang, LegalDoc>> legalDocs = {
  PageKey.impressum: {Lang.en: _impressumEn, Lang.de: _impressumDe},
};
