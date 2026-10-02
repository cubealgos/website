// SPDX-License-Identifier: Apache-2.0

/// The home page copy, EN and DE side by side (final brand copy, character
/// for character; all rights reserved). Components render it, tests compare
/// the built pages against it.
library;

import 'package:website/src/routes.dart';

/// One offer; its heading reads `name, price`.
typedef Offer = ({String id, String name, String price, String text});

/// One of the two "where do you start" lanes; its `offerIds` link to offers.
typedef Lane = ({String title, String text, List<String> offerIds});

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
  String afterTitle,
  String afterText,
  String afterNote,
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
            'You run a business with a few people to a few dozen: a trade, '
            'a practice, a studio, a restaurant, a shop. You need a booking '
            'tool, a customer portal or a dashboard for your team. Cube '
            'Algos builds it around how your work already flows, so you can '
            'keep running the business.',
        offerIds: ['tool'],
      ),
      (
        title: 'For your idea',
        text:
            "You have an idea for an app or a product, and you're deciding "
            'on your own what happens next. Cube Algos helps you find out '
            'what to build first, then builds it. You start with a free '
            'call, and you know what it costs before anything is built.',
        offerIds: ['mvp'],
      ),
    ],
    offersTitle: 'What it costs',
    offersIntro:
        'Fixed prices, agreed before work starts. If your project is '
        'bigger than a "from" price, the written scope says so.',
    offers: [
      (
        id: 'call',
        name: 'First call',
        price: 'free',
        text:
            '30 to 45 minutes by video or phone. Within about 3 working '
            'days you get a written scope with a fixed price and a start '
            "date. If you don't go ahead, it costs nothing.",
      ),
      (
        id: 'tool',
        name: 'Internal tool',
        price: 'from €5,900',
        text:
            'A booking tool, a customer portal or an ops dashboard for your '
            'team, built around one core flow and how your business '
            'actually works.',
      ),
      (
        id: 'mvp',
        name: 'MVP / SaaS v1',
        price: 'from €6,900',
        text:
            'The first working version of your product, built around one '
            'core flow and small enough to put in front of real users and '
            'learn from.',
      ),
      (
        id: 'after',
        name: 'After launch',
        price: '€95 an hour',
        text:
            'Follow-up work and updates, on request. You are told the cost '
            'before work starts, and nothing is billed without your yes.',
      ),
    ],
    vatNote: 'All prices plus 19% VAT.',
    accessibleNote: 'Every build is accessible from the start.',
    workflowTitle: 'The workflow',
    steps: [
      (
        title: 'Free call.',
        text: 'You and Kevin talk for 30 to 45 minutes, by video or phone.',
      ),
      (
        title: 'Written scope.',
        text:
            'Within about 3 working days you get what will be built, a '
            'fixed price and a start date, in writing. If you '
            "don't go ahead, it costs nothing.",
      ),
      (
        title: 'Build.',
        text:
            'Kevin builds it. You see progress along the way, not only at '
            'the end.',
      ),
      (
        title: 'Launch.',
        text: 'It goes live, and Cube Algos makes sure it works.',
      ),
      (
        title: 'After launch.',
        text:
            'The app is yours. Follow-up work and updates are available on '
            'request.',
      ),
    ],
    afterTitle: 'After launch',
    afterText:
        "Once it's live, it's yours. Software drifts out of date over "
        'time, so updates and follow-up work are available on request, at '
        '€95 an hour. You are told the cost before work starts.',
    afterNote:
        'There are no care subscriptions and no retainers. Nobody '
        'monitors your app unless you ask for it.',
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
            'Beschäftigten: Handwerk, Praxis, Studio, Gastronomie, '
            'Einzelhandel. Sie brauchen eine Online-Terminbuchung, ein '
            'Kundenportal oder eine Übersicht für Ihr Team. Cube Algos baut '
            'sie passend zu Ihren Abläufen, und Sie kümmern sich weiter um '
            'Ihr Geschäft.',
        offerIds: ['tool'],
      ),
      (
        title: 'Für Ihre Idee',
        text:
            'Sie haben eine Idee für eine App oder ein Produkt und '
            'entscheiden allein, wie es weitergeht. Cube Algos hilft Ihnen '
            'herauszufinden, was zuerst gebaut werden sollte, und baut genau '
            'das. Am Anfang steht ein kostenloses Gespräch, und den Preis '
            'kennen Sie, bevor etwas gebaut wird.',
        offerIds: ['mvp'],
      ),
    ],
    offersTitle: 'Was es kostet',
    offersIntro:
        'Feste Preise, vereinbart vor Beginn der Arbeit. Ist Ihr Projekt '
        'größer als der „ab“-Preis, steht das im schriftlichen Angebot.',
    offers: [
      (
        id: 'call',
        name: 'Erstgespräch',
        price: 'kostenlos',
        text:
            '30 bis 45 Minuten per Video oder Telefon. Danach erhalten Sie '
            'innerhalb von etwa drei Werktagen ein schriftliches Angebot mit '
            'Festpreis und Starttermin. Sagen Sie ab, kostet Sie das nichts.',
      ),
      (
        id: 'tool',
        name: 'Internes Tool',
        price: 'ab 5.900 €',
        text:
            'Zum Beispiel eine Online-Terminbuchung, ein Kundenportal oder '
            'eine Übersicht für Ihr Team. Gebaut rund um einen zentralen '
            'Ablauf und so, wie Ihr Betrieb wirklich arbeitet.',
      ),
      (
        id: 'mvp',
        name: 'MVP / SaaS v1',
        price: 'ab 6.900 €',
        text:
            'Die erste funktionierende Version Ihres Produkts. Gebaut rund '
            'um einen zentralen Ablauf und klein genug, um früh echte '
            'Rückmeldungen zu bekommen und daraus zu lernen.',
      ),
      (
        id: 'after',
        name: 'Nach dem Start',
        price: '95 € pro Stunde',
        text:
            'Änderungen und Updates auf Anfrage. Sie kennen die Kosten '
            'vorher, und ohne Ihre Zustimmung wird nichts abgerechnet.',
      ),
    ],
    vatNote: 'Alle Preise zzgl. 19 % USt.',
    accessibleNote: 'Jedes Projekt ist von Anfang an barrierearm.',
    workflowTitle: 'So läuft es ab',
    steps: [
      (
        title: 'Kostenloses Gespräch.',
        text: '30 bis 45 Minuten mit Kevin, per Video oder Telefon.',
      ),
      (
        title: 'Schriftliches Angebot.',
        text:
            'Innerhalb von etwa drei Werktagen: was gebaut wird, zu welchem '
            'Festpreis und ab wann. Sagen Sie ab, kostet es nichts.',
      ),
      (
        title: 'Umsetzung.',
        text:
            'Kevin baut. Den Fortschritt sehen Sie laufend, nicht erst am '
            'Ende.',
      ),
      (
        title: 'Start.',
        text:
            'Die Anwendung geht online, und Cube Algos sorgt dafür, dass sie '
            'läuft.',
      ),
      (
        title: 'Danach.',
        text:
            'Die Anwendung gehört Ihnen. Änderungen und Updates gibt es auf '
            'Anfrage.',
      ),
    ],
    afterTitle: 'Nach dem Start',
    afterText:
        'Sobald die Anwendung online ist, gehört sie Ihnen. Software braucht '
        'mit der Zeit Pflege. Updates und Änderungen gibt es deshalb auf '
        'Anfrage, für 95 € pro Stunde, und die Kosten kennen Sie vorher.',
    afterNote:
        'Es gibt keine Wartungsverträge und keine monatlichen Pauschalen. '
        'Ihre Anwendung wird nur überwacht, wenn Sie das beauftragen.',
    faqTitle: 'Fragen',
    faq: [
      (
        question: 'Was kostet es, und ist die Umsatzsteuer enthalten?',
        answer:
            'Alle Preise auf dieser Seite sind Nettopreise, zuzüglich 19 % '
            'Umsatzsteuer. Das erste Gespräch ist kostenlos. Danach erhalten '
            'Sie ein schriftliches Angebot mit Festpreis. Sagen Sie ab, '
            'kostet Sie das nichts.',
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
        question: 'Was passiert nach dem Start?',
        answer:
            'Ihre Anwendung ist online und gehört Ihnen. Änderungen und '
            'Updates übernimmt Kevin auf Anfrage zum Stundensatz aus „Was es '
            'kostet“, mit einem Angebot vorab. Es gibt keine '
            'Wartungsverträge, und niemand überwacht Ihre Anwendung, wenn '
            'Sie das nicht beauftragen. Sie können damit jederzeit auch zu '
            'jemand anderem gehen.',
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
        question: 'Ist die Anwendung barrierearm?',
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
