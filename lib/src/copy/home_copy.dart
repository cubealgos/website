// SPDX-License-Identifier: Apache-2.0

/// The home page copy, EN and DE side by side (final brand copy, character
/// for character; all rights reserved). Components render it, tests compare
/// the built pages against it.
library;

import 'package:website/src/routes.dart';

/// One example price under an offer: `label · price`.
typedef Example = ({String label, String price});

/// One offer; its heading reads `name, price`. `examples` are shown as a
/// compact inline list after `text`.
typedef Offer = ({
  String id,
  String name,
  String price,
  String text,
  List<Example> examples,
});

/// One of the three "where do you start" lanes; its link reads `link` and
/// points at the offer `offerId`.
typedef Lane = ({String title, String text, String link, String offerId});

/// One workflow step: a bold `title` followed by `text`.
typedef Step = ({String title, String text});

/// One FAQ entry.
typedef Faq = ({String question, String answer});

/// All copy of the home page in one language.
typedef HomeCopy = ({
  String eyebrow,
  String h1,

  /// The part of `h1` that carries the drawn underline.
  String h1Mark,
  String subline,

  /// The shorter subline shown on phones (below 30rem) instead of `subline`.
  String sublineShort,
  String secondaryCta,
  String studioTitle,
  String studioText,
  String lanesTitle,
  List<Lane> lanes,
  String offersTitle,
  String offersIntro,
  List<Offer> offers,
  String vatNote,
  String accessibleNote,
  String workflowTitle,
  List<Step> steps,
  String faqTitle,
  List<Faq> faq,
  String ctaTitle,
  String ctaText,
  String ctaButton,
});

/// The home copy per language.
const Map<Lang, HomeCopy> homeCopy = {
  Lang.en: (
    eyebrow: 'AI-native software studio · Heinsberg',
    h1: 'Apps and tools for businesses that would rather focus on their work.',
    h1Mark: 'focus on their work',
    subline:
        'Cube Algos designs and builds internal tools, apps and MVPs for '
        'owner-led businesses and founders: AI-accelerated, reviewed line '
        'by line by a trained developer, at a fixed price agreed before '
        'work starts.',
    sublineShort:
        'Built faster with AI, checked by a trained developer, at a fixed '
        'price.',
    secondaryCta: 'Services and prices',
    studioTitle: 'A small studio, deliberately',
    studioText:
        'One developer, start to finish. Kevin Scheeren founded Cube '
        'Algos in 2023 and builds every project himself, so the person '
        'you talk to is the person who writes your code. Fewer projects '
        'at a time means a start date you can rely on, agreed before you '
        'sign.',
    lanesTitle: 'Where do you start?',
    lanes: [
      (
        title: 'For your business',
        text:
            'You run a business with a few people to a few dozen. Cube '
            'Algos builds you a booking tool, a customer portal or an '
            'internal dashboard that fits how your work already flows.',
        link: 'Apps and tools',
        offerId: 'apps',
      ),
      (
        title: 'For your idea',
        text:
            'You have an idea for an app or a product. Cube Algos helps you '
            'cut the first version down to what matters, then builds it. '
            'You know the price before anything is built.',
        link: 'MVP',
        offerId: 'apps',
      ),
      (
        title: 'For your processes',
        text:
            'Your team loses time copying between spreadsheets and tools. '
            'Cube Algos automates that work and, if you like, runs it on '
            'servers in the EU, GDPR-compliant.',
        link: 'Automation and self-hosting',
        offerId: 'automation',
      ),
    ],
    offersTitle: 'What it costs',
    offersIntro:
        'Fixed prices, agreed before work starts. You get the fixed price '
        'for your project in writing after the free call.',
    offers: [
      (
        id: 'call',
        name: 'First call',
        price: 'free',
        text:
            '30 to 45 minutes by video or phone, then a written scope with a '
            'fixed price and a start date within about 3 working days. If '
            "you don't go ahead, it costs nothing.",
        examples: [],
      ),
      (
        id: 'apps',
        name: 'Apps and tools',
        price: 'from €1,000',
        text: 'Priced by scope. For orientation:',
        examples: [
          (
            label: 'Small tool, e.g. a form with an overview',
            price: 'about €1,500',
          ),
          (label: 'Internal tool with logins and roles', price: 'about €6,000'),
          (label: 'MVP for founders', price: 'about €9,000'),
        ],
      ),
      (
        id: 'automation',
        name: 'Automation and self-hosting',
        price: 'from €3,000',
        text:
            'Automate workflows, bring data together and run systems on EU '
            'servers, GDPR-compliant. Ongoing work: €110 an hour.',
        examples: [],
      ),
      (
        id: 'after',
        name: 'After launch',
        price: '€95 an hour',
        text:
            'Follow-up work and updates, on request. You know the cost before '
            'work starts.',
        examples: [],
      ),
    ],
    vatNote: 'All prices plus 19% VAT.',
    accessibleNote: 'Every build is accessible from the start.',
    workflowTitle: 'The workflow',
    steps: [
      (title: 'Free call.', text: '30 to 45 minutes, by video or phone.'),
      (
        title: 'Written scope.',
        text: 'A fixed price and a start date in about 3 working days.',
      ),
      (title: 'Build.', text: 'Kevin builds; you see progress along the way.'),
      (title: 'Launch.', text: 'It goes live and is yours.'),
      (title: 'After launch.', text: 'Changes and updates on request.'),
    ],
    faqTitle: 'Questions',
    faq: [
      (
        question: 'What does it cost, and is VAT included?',
        answer:
            'The prices on this page are net. VAT of 19% is added on top. '
            'The first call is free. Afterwards you get a written scope '
            "with a fixed price, and if you don't go ahead, it costs "
            'nothing.',
      ),
      (
        question: 'Does Cube Algos use AI, and what happens to your data?',
        answer:
            'Yes. AI is part of the whole workflow: planning, writing and '
            'checking code. Kevin is a trained developer and reviews every '
            'line before it ships. Personal data from your customers never '
            'goes into AI tools, and the AI tools in use are set not to '
            'train on your project.',
      ),
      (
        question: 'How long does it take?',
        answer:
            'It depends on the scope. Cube Algos gives no number before it '
            'knows what you need. After the free call, you get a written '
            'scope with a fixed price and a start date within about 3 '
            'working days.',
      ),
      (
        question: 'Who owns the code?',
        answer:
            'You do. Once the project is paid in full, the code and content '
            'are yours. Cube Algos keeps the right to reuse its own general '
            "building blocks, like templates and libraries, that aren't "
            'specific to your project.',
      ),
      (
        question: 'What happens after launch?',
        answer:
            'Your project is live and stays yours. If you want changes or '
            'updates later, Kevin does them on request at the hourly rate '
            'shown under "What it costs", quoted before work starts. There '
            'are no care subscriptions, and nobody monitors your app unless '
            'you ask for it. You can also take it elsewhere.',
      ),
      (
        question: 'What if Kevin is busy or away?',
        answer:
            'Cube Algos is run by one person and says so. Projects are '
            'scheduled in advance: you get a confirmed start date before '
            'signing, and planned absences are announced early. There is no '
            'stand-in developer and no guaranteed response time. If Kevin '
            'falls ill, you hear about it as soon as possible.',
      ),
      (
        question: 'Is it accessible?',
        answer:
            'Every build is accessible from the start: it works with a '
            'keyboard and screen readers, text is readable and contrast is '
            "checked. It's part of how Cube Algos builds, not an extra. "
            'Cube Algos makes no legal compliance promises for your '
            'business, and your own content matters too.',
      ),
      (
        question: 'Do you need to know what you want before you write?',
        answer:
            'No. A few sentences are enough. If the idea is still vague, '
            "that's what the free call is for.",
      ),
    ],
    ctaTitle: 'Start with a short email.',
    ctaText:
        'A few lines about what you need are enough. Kevin reads every '
        'enquiry himself and replies with a suggested next step, usually a '
        'free call.',
    ctaButton: 'Write to hello@cubealgos.de',
  ),
  Lang.de: (
    eyebrow: 'KI-gestütztes Softwarestudio · Heinsberg',
    h1: 'Apps und Tools für Betriebe, die sich lieber um ihr Geschäft kümmern.',
    h1Mark: 'um ihr Geschäft kümmern',
    subline:
        'Cube Algos entwickelt interne Tools, Apps und erste '
        'Produktversionen für inhabergeführte Betriebe und Gründungsteams. '
        'Mit KI schneller gebaut, Zeile für Zeile von einem ausgebildeten '
        'Entwickler geprüft und zu einem Festpreis, den Sie vorher kennen.',
    sublineShort:
        'Mit KI schneller gebaut, von einem ausgebildeten Entwickler '
        'geprüft, zum Festpreis.',
    secondaryCta: 'Leistungen und Preise',
    studioTitle: 'Klein, und das mit Absicht',
    studioText:
        'Ein Entwickler, von Anfang bis Ende. Kevin Scheeren hat Cube Algos '
        '2023 gegründet und setzt jedes Projekt selbst um. Wer mit Ihnen '
        'spricht, schreibt auch Ihren Code. Weil nur wenige Projekte '
        'gleichzeitig laufen, steht Ihr Starttermin verlässlich fest, bevor '
        'Sie unterschreiben.',
    lanesTitle: 'Wo stehen Sie?',
    lanes: [
      (
        title: 'Für Ihren Betrieb',
        text:
            'Sie führen einen Betrieb mit wenigen bis ein paar Dutzend '
            'Beschäftigten. Cube Algos baut Ihnen eine Online-Terminbuchung, '
            'ein Kundenportal oder ein internes Dashboard, passend zu Ihren '
            'Abläufen.',
        link: 'Apps und Tools',
        offerId: 'apps',
      ),
      (
        title: 'Für Ihre Idee',
        text:
            'Sie haben eine Idee für eine App oder ein Produkt. Cube Algos '
            'hilft Ihnen, die erste Version auf das Wesentliche zu '
            'beschränken, und baut sie. Den Preis kennen Sie, bevor etwas '
            'gebaut wird.',
        link: 'MVP',
        offerId: 'apps',
      ),
      (
        title: 'Für Ihre Prozesse',
        text:
            'Ihr Team verliert Zeit mit Tabellen, Kopieren und Abgleichen. '
            'Cube Algos automatisiert solche Arbeit und betreibt sie auf '
            'Wunsch datenschutzkonform auf Servern in der EU.',
        link: 'Automatisierung und Self-Hosting',
        offerId: 'automation',
      ),
    ],
    offersTitle: 'Was es kostet',
    offersIntro:
        'Feste Preise, vereinbart vor Beginn der Arbeit. Den Festpreis für '
        'Ihr Projekt erhalten Sie schriftlich nach dem kostenlosen '
        'Gespräch.',
    offers: [
      (
        id: 'call',
        name: 'Erstgespräch',
        price: 'kostenlos',
        text:
            '30 bis 45 Minuten per Video oder Telefon. Innerhalb von etwa '
            'drei Werktagen folgt ein schriftliches Angebot mit Festpreis und '
            'Starttermin. Wenn Sie nicht beauftragen, entstehen Ihnen keine '
            'Kosten.',
        examples: [],
      ),
      (
        id: 'apps',
        name: 'Apps und Tools',
        price: 'ab 1.000 €',
        text: 'Preis nach Umfang. Zur Orientierung:',
        examples: [
          (
            label: 'Kleines Tool, etwa ein Formular mit Übersicht',
            price: 'ca. 1.500 €',
          ),
          (label: 'Internes Tool mit Logins und Rollen', price: 'ca. 6.000 €'),
          (label: 'MVP für Gründungsteams', price: 'ca. 9.000 €'),
        ],
      ),
      (
        id: 'automation',
        name: 'Automatisierung und Self-Hosting',
        price: 'ab 3.000 €',
        text:
            'Abläufe automatisieren, Daten zusammenführen und Systeme '
            'datenschutzkonform auf Servern in der EU betreiben. Laufende '
            'Arbeit: 110 € pro Stunde.',
        examples: [],
      ),
      (
        id: 'after',
        name: 'Nach der Übergabe',
        price: '95 € pro Stunde',
        text:
            'Änderungen und Updates auf Anfrage. Die Kosten kennen Sie '
            'vorher.',
        examples: [],
      ),
    ],
    vatNote: 'Alle Preise zzgl. 19 % USt.',
    accessibleNote: 'Jedes Projekt ist von Anfang an barrierearm.',
    workflowTitle: 'So läuft es ab',
    steps: [
      (
        title: 'Kostenloses Gespräch.',
        text: '30 bis 45 Minuten, per Video oder Telefon.',
      ),
      (
        title: 'Schriftliches Angebot.',
        text: 'Festpreis und Starttermin in etwa drei Werktagen.',
      ),
      (
        title: 'Umsetzung.',
        text: 'Kevin baut, Sie sehen den Fortschritt laufend.',
      ),
      (title: 'Übergabe.', text: 'Ihre App geht online und gehört Ihnen.'),
      (title: 'Danach.', text: 'Änderungen und Updates auf Anfrage.'),
    ],
    faqTitle: 'Fragen',
    faq: [
      (
        question: 'Was kostet es, und ist die Umsatzsteuer enthalten?',
        answer:
            'Alle Preise auf dieser Seite sind Nettopreise, zuzüglich 19 % '
            'Umsatzsteuer. Das erste Gespräch ist kostenlos. Danach erhalten '
            'Sie ein schriftliches Angebot mit Festpreis. Wenn Sie nicht '
            'beauftragen, entstehen Ihnen keine Kosten.',
      ),
      (
        question:
            'Arbeitet Cube Algos mit KI, und was geschieht mit Ihren Daten?',
        answer:
            'Ja. KI hilft bei Planung, Programmierung und Tests. Kevin ist '
            'ausgebildeter Entwickler und prüft jede Zeile, bevor sie live '
            'geht. Personenbezogene Daten Ihrer Kundschaft kommen nie in '
            'KI-Werkzeuge, und die eingesetzten Werkzeuge sind so '
            'eingestellt, dass sie nicht mit Ihrem Projekt trainiert werden.',
      ),
      (
        question: 'Wie lange dauert ein Projekt?',
        answer:
            'Das hängt vom Umfang ab, deshalb gibt es vorab keine '
            'Pauschalzahl. Nach dem kostenlosen Gespräch erhalten Sie '
            'innerhalb von etwa drei Werktagen ein Angebot mit Festpreis und '
            'Starttermin.',
      ),
      (
        question: 'Wem gehört der Code?',
        answer:
            'Ihnen, sobald das Projekt vollständig bezahlt ist: Code und '
            'Inhalte. Allgemeine Bausteine von Cube Algos, etwa Vorlagen und '
            'Bibliotheken, die nicht eigens für Ihr Projekt entstehen, '
            'dürfen weiterverwendet werden.',
      ),
      (
        question: 'Was passiert nach der Übergabe?',
        answer:
            'Ihre App ist online und gehört Ihnen. Änderungen und Updates '
            'übernimmt Kevin auf Anfrage zum Stundensatz aus „Was es '
            'kostet“, mit einem Angebot vorab. Es gibt keine '
            'Wartungsverträge, und niemand überwacht sie, wenn Sie das nicht '
            'beauftragen. Sie können damit jederzeit auch zu jemand anderem '
            'gehen.',
      ),
      (
        question: 'Was ist, wenn Kevin ausgelastet oder nicht erreichbar ist?',
        answer:
            'Cube Algos ist ein Ein-Personen-Studio und sagt das offen. '
            'Projekte werden im Voraus eingeplant: Sie erhalten vor '
            'Vertragsabschluss einen verbindlichen Starttermin, und geplante '
            'Abwesenheiten werden früh angekündigt. Eine Vertretung gibt es '
            'nicht, feste Reaktionszeiten auch nicht. Fällt Kevin '
            'krankheitsbedingt aus, erfahren Sie das so schnell wie möglich.',
      ),
      (
        question: 'Ist die App barrierearm?',
        answer:
            'Ja. Jedes Projekt ist von Anfang an auf Barrierefreiheit '
            'ausgelegt: per Tastatur und Screenreader bedienbar, mit gut '
            'lesbaren Texten und geprüften Kontrasten. Das gehört zur '
            'Arbeitsweise und ist kein Aufpreis. Eine rechtliche Konformität '
            'für Ihr Unternehmen wird nicht zugesagt, auch weil Ihre eigenen '
            'Inhalte eine Rolle spielen.',
      ),
      (
        question: 'Müssen Sie schon genau wissen, was Sie wollen?',
        answer:
            'Nein. Ein paar Sätze reichen. Ist die Idee noch vage, ist genau '
            'dafür das kostenlose Gespräch da.',
      ),
    ],
    ctaTitle: 'Alles beginnt mit einer kurzen E-Mail.',
    ctaText:
        'Ein paar Zeilen zu Ihrem Vorhaben genügen. Kevin liest jede Anfrage '
        'selbst und antwortet mit einem Vorschlag für den nächsten Schritt, '
        'meist einem kostenlosen Gespräch.',
    ctaButton: 'E-Mail an hello@cubealgos.de',
  ),
};
