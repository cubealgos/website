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

const _controllerDe = Facts([
  (
    label: 'Verantwortlicher',
    lines: [
      [companyName],
      [addressStreet],
      [addressCity],
      ['Deutschland'],
      ['E-Mail: ', _mail],
      ['Telefon: ', _tel],
    ],
  ),
]);

const _datenschutzDe = LegalDoc(
  sections: [
    Section('1. Verantwortlicher', [
      Para([
        'Verantwortlich für die Datenverarbeitung auf dieser Website im Sinne '
            'der Datenschutz-Grundverordnung (DSGVO) ist:',
      ]),
      _controllerDe,
    ]),
    Section('2. Hosting', [
      Para([
        'Diese Website wird von einem Server in Deutschland ausgeliefert. '
            'Den Server mietet Cube Algos bei der STRATO AG (Berlin) und '
            'betreibt ihn selbst. Sie ist dabei als Auftragsverarbeiterin für '
            'uns tätig; es gilt ihr Vertrag zur Auftragsverarbeitung.',
      ]),
    ]),
    Section('3. Keine Zugriffsprotokolle, keine Speicherung von IP-Adressen', [
      Para([
        'Der Webserver und der vorgeschaltete Reverse Proxy sind so '
            'konfiguriert, dass sie für diese Website keine Zugriffsprotokolle '
            '(Access Logs) schreiben. Auf diesem Server werden deshalb keine '
            'IP-Adressen der Besucherinnen und Besucher gespeichert.',
      ]),
      Para([
        'Damit der Server Ihnen die Seite senden kann, verarbeitet er Ihre '
            'IP-Adresse technisch notwendig für die Dauer der Verbindung. Sie '
            'wird nicht gespeichert. Rechtsgrundlage ist Art. 6 Abs. 1 lit. f '
            'DSGVO (berechtigtes Interesse an der Bereitstellung der Website).',
      ]),
    ]),
    Section('4. Keine Cookies, kein Tracking, keine Analyse', [
      Para([
        'Diese Website setzt keine Cookies, verwendet kein Tracking und keine '
            'Analysedienste. Sie lädt keine Inhalte von Dritten und bindet '
            'keine externen Inhalte ein; es gibt deshalb keinen '
            'Cookie-Banner. Die Website hat kein Formular. Sie legt nichts '
            'auf Ihrem Gerät ab, weder Cookies noch Einträge im lokalen '
            'Speicher Ihres Browsers. Wie bei jeder Website kann Ihr Browser '
            'die geladenen Dateien, etwa Schriftarten und Bilder, in seinem '
            'Zwischenspeicher (Cache) behalten, damit Seiten schneller laden; '
            'diesen können Sie jederzeit in Ihrem Browser leeren.',
      ]),
    ]),
    Section('5. Schriftarten', [
      Para([
        'Die Schriftarten dieser Website sind selbst gehostet und werden '
            'von diesem Server ausgeliefert. Ihr Browser stellt dafür keine '
            'Verbindung zu Google Fonts oder einem anderen Dritten her.',
      ]),
    ]),
    Section('6. Links zu anderen Websites', [
      Para([
        'Diese Website enthält Links auf Seiten Dritter, namentlich auf '
            'kevinscheeren.de, GitHub und LinkedIn (darunter die '
            'LinkedIn-Seite von Cube Algos). Es sind gewöhnliche Links: '
            'Erst wenn Sie einen anklicken, verlässt Ihr Browser '
            'diese Website und ruft die verlinkte Seite auf; vorher werden '
            'keine Daten an diese Anbieter übertragen. Was dort mit Ihren '
            'Daten geschieht, richtet sich nach deren eigenen '
            'Datenschutzhinweisen.',
      ]),
    ]),
    Section('7. Kontakt per E-Mail', [
      Para([
        'Die Website bietet kein Kontaktformular, sondern nur die Adresse ',
        _mail,
        ' als „mailto:“-Link. Beim Anklicken überträgt die Website selbst '
            'keine Daten; Ihr E-Mail-Programm versendet die Nachricht.',
      ]),
      Para([
        'Wenn Sie uns schreiben, verarbeiten wir Ihre Nachricht und Ihre '
            'E-Mail-Adresse, um Ihre Anfrage zu beantworten. Rechtsgrundlage '
            'ist Art. 6 Abs. 1 lit. b DSGVO, wenn Ihre Anfrage auf einen '
            'Vertrag zielt, sonst Art. 6 Abs. 1 lit. f DSGVO (berechtigtes '
            'Interesse an der Beantwortung von Anfragen). Ihre Angaben sind '
            'freiwillig; ohne sie können wir Ihre Anfrage aber nicht '
            'beantworten.',
      ]),
      Para([
        'Das Postfach stellt Proton AG (Schweiz) bereit, die dabei als '
            'Auftragsverarbeiterin für uns tätig ist. Für die Schweiz besteht '
            'ein Angemessenheitsbeschluss der Europäischen Kommission. Wir '
            'speichern die Nachrichten so lange, wie es für Ihre Anfrage '
            'erforderlich ist und gesetzliche Aufbewahrungspflichten es '
            'verlangen.',
      ]),
    ]),
    Section('8. Keine automatisierte Entscheidungsfindung', [
      Para([
        'Wir setzen im Zusammenhang mit dieser Website keine automatisierte '
            'Entscheidungsfindung und kein Profiling ein.',
      ]),
    ]),
    Section('9. Datenschutzbeauftragter', [
      Para([
        'Wir haben keinen Datenschutzbeauftragten bestellt. Das ist nach '
            '§ 38 BDSG nicht erforderlich, da in der Regel weniger als 20 '
            'Personen ständig mit der automatisierten Verarbeitung '
            'personenbezogener Daten beschäftigt sind.',
      ]),
    ]),
    Section('10. Ihre Rechte', [
      Para([
        'Sie haben das Recht auf Auskunft (Art. 15 DSGVO), Berichtigung '
            '(Art. 16), Löschung (Art. 17), Einschränkung der Verarbeitung '
            '(Art. 18), Datenübertragbarkeit (Art. 20) und Widerspruch '
            '(Art. 21) sowie, wo eine Verarbeitung auf einer Einwilligung '
            'beruht, das Recht, diese jederzeit zu widerrufen (Art. 7 '
            'Abs. 3). Wenden Sie sich dafür an die Kontaktdaten in Abschnitt '
            '1.',
      ]),
      Para([
        'Widerspruchsrecht: Soweit wir Daten auf Grundlage von Art. 6 '
            'Abs. 1 lit. f DSGVO verarbeiten (Abschnitte 3 und 7), können Sie '
            'dieser Verarbeitung aus Gründen, die sich aus Ihrer besonderen '
            'Situation ergeben, jederzeit widersprechen (Art. 21 Abs. 1 '
            'DSGVO).',
      ]),
      Para([
        'Sie haben außerdem das Recht, sich bei einer '
            'Datenschutzaufsichtsbehörde zu beschweren (Art. 77 DSGVO). Für '
            'uns zuständig ist '
            'die Landesbeauftragte für Datenschutz und Informationsfreiheit '
            'Nordrhein-Westfalen (LDI NRW).',
      ]),
    ]),
    Section('Stand', [
      Para(['3. Oktober 2026']),
    ]),
  ],
);

const _datenschutzEn = LegalDoc(
  notice: authoritativeNotice,
  sections: [
    Section('1. Controller', [
      Para([
        'The controller responsible for data processing on this website '
            'within the meaning of the General Data Protection Regulation '
            '(GDPR) is:',
      ]),
      Facts([
        (
          label: 'Controller',
          lines: [
            [companyName],
            [addressStreet],
            [addressCity],
            ['Germany'],
            ['Email: ', _mail],
            ['Phone: ', _tel],
          ],
        ),
      ]),
    ]),
    Section('2. Hosting', [
      Para([
        'This website is served from a server in Germany. Cube Algos rents '
            'the server from STRATO AG (Berlin) and operates it itself. '
            'It acts for us as a processor under its data processing '
            'agreement.',
      ]),
    ]),
    Section('3. No access logs, no storage of IP addresses', [
      Para([
        'The web server and the reverse proxy in front of it are configured '
            "to write no access logs for this website. Visitors' IP "
            'addresses are therefore not stored on this server.',
      ]),
      Para([
        'To send you the page, the server processes your IP address as '
            'technically necessary for the duration of the connection. It is '
            'not stored. The legal basis is Art. 6(1)(f) GDPR (legitimate '
            'interest in providing the website).',
      ]),
    ]),
    Section('4. No cookies, no tracking, no analytics', [
      Para([
        'This website sets no cookies and uses no tracking or analytics. It '
            'loads no content from third parties and embeds no external '
            'content, so there is no cookie banner. The website has no form.'
            ' It '
            'puts nothing on your device: no cookies and no entries in your '
            "browser's local storage. As with any website, your browser may "
            'keep the files it loaded, such as fonts and images, in its cache '
            'so pages load faster; you can clear it in your browser at any '
            'time.',
      ]),
    ]),
    Section('5. Fonts', [
      Para([
        'The fonts of this website are self-hosted and served from this '
            'server. Your browser makes no request to Google Fonts or to any '
            'other third party for them.',
      ]),
    ]),
    Section('6. Links to other websites', [
      Para([
        'This website contains links to pages of third parties, namely '
            'kevinscheeren.de, GitHub and LinkedIn (including the LinkedIn '
            'page of Cube Algos). They are plain links: only when you '
            'click one does your browser leave this website '
            'and request the linked page; before that, no data is sent to '
            'these providers. What happens to your data there is governed by '
            'their own privacy notices.',
      ]),
    ]),
    Section('7. Contact by email', [
      Para([
        'The website has no contact form, only the address ',
        _mail,
        ' as a "mailto:" link. Clicking it transmits no data from the '
            'website itself; your email program sends the message.',
      ]),
      Para([
        'If you write to us, we process your message and your email address '
            'to answer your request. The legal basis is Art. 6(1)(b) GDPR if '
            'your request aims at a contract, otherwise Art. 6(1)(f) GDPR '
            '(legitimate interest in answering enquiries). Providing your '
            'details is voluntary, but without them we cannot answer your '
            'request.',
      ]),
      Para([
        'The mailbox is provided by Proton AG (Switzerland), which acts for '
            'us as a processor. The European Commission has issued an '
            'adequacy decision for Switzerland. We keep messages as long as '
            'your request requires and statutory retention obligations '
            'demand.',
      ]),
    ]),
    Section('8. No automated decision-making', [
      Para([
        'We use no automated decision-making and no profiling in connection '
            'with this website.',
      ]),
    ]),
    Section('9. Data protection officer', [
      Para([
        'We have not appointed a data protection officer. Under § 38 BDSG '
            'this is not required, because as a rule fewer than 20 people are '
            'constantly engaged in the automated processing of personal data.',
      ]),
    ]),
    Section('10. Your rights', [
      Para([
        'You have the right of access (Art. 15 GDPR), rectification '
            '(Art. 16), erasure (Art. 17), restriction of processing '
            '(Art. 18), data portability (Art. 20) and objection (Art. 21) '
            'and, where processing is based on consent, the right to withdraw '
            'it at any time (Art. 7(3)). Contact us using the details in '
            'section 1.',
      ]),
      Para([
        'Right to object: where we process data on the basis of Art. 6(1)(f) '
            'GDPR (sections 3 and 7), you may object to this processing at '
            'any time on grounds relating to your particular situation '
            '(Art. 21(1) GDPR).',
      ]),
      Para([
        'You also have the right to lodge a complaint with a data '
            'protection supervisory authority (Art. 77 GDPR). The authority '
            'responsible for '
            'us is the North Rhine-Westphalia State Commissioner for Data '
            'Protection and Freedom of Information (Landesbeauftragte für '
            'Datenschutz und Informationsfreiheit Nordrhein-Westfalen, LDI '
            'NRW).',
      ]),
    ]),
    Section('Last updated', [
      Para(['3 October 2026']),
    ]),
  ],
);

/// The legal pages' text per page and language.
const Map<PageKey, Map<Lang, LegalDoc>> legalDocs = {
  PageKey.impressum: {Lang.en: _impressumEn, Lang.de: _impressumDe},
  PageKey.datenschutz: {Lang.en: _datenschutzEn, Lang.de: _datenschutzDe},
};
