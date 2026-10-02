// SPDX-License-Identifier: Apache-2.0

/// The home page copy, EN and DE side by side (final brand copy, character
/// for character; all rights reserved). Components render it, tests compare
/// the built pages against it.
library;

import 'package:website/src/routes.dart';

/// One offer card; its heading reads `name, price`.
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
  String lanesTitle,
  List<Lane> lanes,
  String offersTitle,
  String offersIntro,
  List<Offer> offers,
  String vatNote,
  String accessibleNote,
  String workflowTitle,
  List<Step> steps,
  String careTitle,
  String careText,
  List<String> carePlans,
  String carePlansNote,
  String studioTitle,
  String studioText,
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
    h1:
        'Websites and apps for businesses that would rather focus on '
        'their work.',
    h1Mark: 'focus on their work.',
    subline:
        'Cube Algos designs and builds websites, internal tools and '
        'MVPs for owner-led businesses and founders: AI-accelerated, '
        'reviewed line by line by a trained developer, at a fixed price '
        'agreed before work starts.',
    secondaryCta: 'Services and prices',
    lanesTitle: 'Where do you start?',
    lanes: [
      (
        title: 'For your business',
        text:
            'You run a business with a few people to a few dozen: a trade, '
            'a practice, a studio, a restaurant, a shop. You need a website '
            'that works, a way for customers to book, a customer portal or '
            'a tool for your team. Cube Algos builds it around how your '
            'work already flows, so you can keep running the business.',
        offerIds: ['website', 'app'],
      ),
      (
        title: 'For your idea',
        text:
            "You have an idea for an app or a product, and you're deciding "
            'on your own what happens next. Cube Algos helps you find out '
            'what to build first, then builds it. You start with an idea '
            'check, and you know what it costs before anything is built.',
        offerIds: ['idea', 'mvp'],
      ),
    ],
    offersTitle: 'What it costs',
    offersIntro:
        'Fixed prices, agreed before work starts. If your project is '
        'bigger than a "from" price, the quote says so.',
    offers: [
      (
        id: 'idea',
        name: 'Idea check',
        price: '€490',
        text:
            'A workshop with you, a written scope and a fixed quote. If you '
            'then commission the build, the €490 is credited against the '
            'price.',
      ),
      (
        id: 'website',
        name: 'Website',
        price: 'from €2,490',
        text:
            'A website for your business: who you are, what you do and how '
            'people reach or book you.',
      ),
      (
        id: 'app',
        name: 'App or tool',
        price: 'from €8,900',
        text:
            'A booking app, a customer portal or an internal tool, built '
            'around how your business actually works.',
      ),
      (
        id: 'mvp',
        name: 'MVP',
        price: 'from €9,900',
        text:
            'The first working version of your product, small enough to put '
            'in front of real users and learn from.',
      ),
      (
        id: 'extra',
        name: 'Extra work',
        price: '€95 an hour',
        text:
            'For changes beyond what was agreed. You are told before work '
            'starts, and nothing is billed without your yes.',
      ),
    ],
    vatNote: 'All prices plus 19% VAT.',
    accessibleNote: 'Every build is accessible from the start.',
    workflowTitle: 'The workflow',
    steps: [
      (
        title: 'Idea check.',
        text:
            'You and Kevin talk; the result is a written note of what to '
            'build and what to leave out.',
      ),
      (
        title: 'Fixed quote.',
        text: 'You get a price in writing before anything is built.',
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
        title: 'Care.',
        text:
            "Cube Algos keeps it running, so you don't have to think about "
            'it.',
      ),
    ],
    careTitle: 'Cared for after launch',
    careText:
        'Software drifts out of date when nobody looks after it. Care '
        'means updates, small fixes and a person to ask. Care is '
        "optional and monthly. You can cancel it any time with 30 days' "
        'notice to the end of a month.',
    carePlans: [
      'Website care, from €49 a month',
      'App care, from €149 a month',
    ],
    carePlansNote:
        'Both are fixed monthly prices. Larger changes are quoted '
        'separately or billed at €95 an hour.',
    studioTitle: 'A small studio, deliberately',
    studioText:
        'Cube Algos was founded in 2023 by Kevin Scheeren, a trained '
        'software developer. He leads every project personally, from '
        'the first conversation to launch and beyond. There is no '
        'account manager and no hand-off to a junior team. Because '
        'capacity is limited, you get an honest start date before you '
        'sign.',
    faqTitle: 'Questions',
    faq: [
      (
        question: 'What does it cost, and is VAT included?',
        answer:
            'The prices on this page are net. VAT of 19% is added on top. '
            'The idea check, €490, gives you a fixed quote for the build, '
            "and it's credited against the build price if you go ahead.",
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
            'knows what you need. The idea check ends with a written scope, '
            'a fixed price and a date.',
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
            'Your project is live and stays yours. If you want Cube Algos '
            "to keep looking after it, there's website care from €49 a "
            "month and app care from €149 a month. If you don't, you can "
            'take it elsewhere.',
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
            "that's what the idea check is for.",
      ),
    ],
    ctaTitle: 'Start with a short email.',
    ctaText:
        'A few lines about what you need are enough. Kevin reads every '
        'enquiry himself and replies with a suggested next step.',
    ctaButton: 'Write to hello@cubealgos.de',
  ),
  Lang.de: (
    eyebrow: 'KI-natives Softwarestudio · Heinsberg',
    h1:
        'Websites und Apps für Unternehmen, die sich lieber auf ihr '
        'Geschäft konzentrieren.',
    h1Mark: 'auf ihr Geschäft konzentrieren.',
    subline:
        'Cube Algos konzipiert und entwickelt Websites, interne '
        'Werkzeuge und MVPs für inhabergeführte Unternehmen und '
        'Gründer:innen: KI-beschleunigt, Zeile für Zeile von einem '
        'ausgebildeten Entwickler geprüft, zum Festpreis, der vor '
        'Projektbeginn feststeht.',
    secondaryCta: 'Leistungen und Preise',
    lanesTitle: 'Wo stehen Sie?',
    lanes: [
      (
        title: 'Für Ihr Geschäft',
        text:
            'Sie führen ein Unternehmen mit einigen wenigen bis ein paar '
            'Dutzend Mitarbeitenden: Handwerk, Praxis, Studio, Restaurant, '
            'Laden. Sie brauchen eine Website, die funktioniert, eine '
            'Terminbuchung für Ihre Kund:innen, ein Kundenportal oder ein '
            'Werkzeug für Ihr Team. Cube Algos baut es passend zu Ihren '
            'Abläufen, und Sie führen weiter Ihr Geschäft.',
        offerIds: ['website', 'app'],
      ),
      (
        title: 'Für Ihre Idee',
        text:
            'Sie haben die Idee für eine App oder ein Produkt und '
            'entscheiden selbst, wie es weitergeht. Cube Algos hilft Ihnen '
            'herauszufinden, was zuerst gebaut werden sollte, und baut es '
            'dann. Sie beginnen mit einem Erstgespräch mit Konzept und '
            'wissen, was es kostet, bevor etwas gebaut wird.',
        offerIds: ['idea', 'mvp'],
      ),
    ],
    offersTitle: 'Was es kostet',
    offersIntro:
        'Feste Preise, vereinbart, bevor die Arbeit beginnt. Ist Ihr '
        'Projekt größer als ein „ab"-Preis, steht das im Angebot.',
    offers: [
      (
        id: 'idea',
        name: 'Erstgespräch mit Konzept',
        price: '490 €',
        text:
            'Ein Workshop mit Ihnen, ein schriftlicher Umfang und ein '
            'Festpreisangebot. Beauftragen Sie danach den Bau, wird der '
            'Betrag von 490 € auf den Preis angerechnet.',
      ),
      (
        id: 'website',
        name: 'Website',
        price: 'ab 2.490 €',
        text:
            'Eine Website für Ihr Geschäft: wer Sie sind, was Sie tun und '
            'wie man Sie erreicht oder bei Ihnen bucht.',
      ),
      (
        id: 'app',
        name: 'App oder Tool',
        price: 'ab 8.900 €',
        text:
            'Eine Buchungs-App, ein Kundenportal oder ein internes '
            'Werkzeug, gebaut danach, wie Ihr Betrieb tatsächlich arbeitet.',
      ),
      (
        id: 'mvp',
        name: 'MVP',
        price: 'ab 9.900 €',
        text:
            'Die erste lauffähige Version Ihres Produkts, klein genug, um '
            'sie echten Nutzer:innen zu zeigen und daraus zu lernen.',
      ),
      (
        id: 'extra',
        name: 'Zusatzarbeit',
        price: '95 € pro Stunde',
        text:
            'Für Änderungen über das Vereinbarte hinaus. Sie erfahren es '
            'vorher, und ohne Ihr Ja wird nichts berechnet.',
      ),
    ],
    vatNote: 'Alle Preise zzgl. 19 % USt.',
    accessibleNote: 'Jedes Projekt wird von Anfang an barrierearm gebaut.',
    workflowTitle: 'So läuft es ab',
    steps: [
      (
        title: 'Erstgespräch mit Konzept.',
        text:
            'Sie sprechen mit Kevin; am Ende steht schriftlich, was gebaut '
            'wird und was nicht.',
      ),
      (
        title: 'Festpreisangebot.',
        text: 'Sie bekommen den Preis schriftlich, bevor etwas gebaut wird.',
      ),
      (
        title: 'Bau.',
        text:
            'Kevin baut es. Sie sehen den Fortschritt unterwegs, nicht erst '
            'am Ende.',
      ),
      (
        title: 'Launch.',
        text:
            'Es geht online, und Cube Algos stellt sicher, dass es '
            'funktioniert.',
      ),
      (
        title: 'Betreuung.',
        text:
            'Cube Algos hält es am Laufen, damit Sie nicht daran denken '
            'müssen.',
      ),
    ],
    careTitle: 'Betreut nach dem Launch',
    careText:
        'Damit alles im Fluss bleibt, braucht Software Pflege: Updates, '
        'kleine Korrekturen und jemand, den Sie fragen können. Die '
        'Betreuung ist freiwillig und monatlich. Sie können sie '
        'jederzeit mit 30 Tagen Frist zum Monatsende kündigen.',
    carePlans: [
      'Website-Betreuung, ab 49 € im Monat',
      'App-Betreuung, ab 149 € im Monat',
    ],
    carePlansNote:
        'Beides sind feste Monatspreise. Größere Änderungen werden '
        'separat angeboten oder mit 95 € pro Stunde abgerechnet.',
    studioTitle: 'Ein kleines Studio, mit Absicht',
    studioText:
        'Cube Algos wurde 2023 von Kevin Scheeren gegründet, '
        'ausgebildeter Softwareentwickler. Er führt jedes Projekt '
        'persönlich, vom ersten Gespräch bis zum Launch und darüber '
        'hinaus. Es gibt keinen Account-Manager und keine Übergabe an '
        'ein Junior-Team. Weil die Kapazität begrenzt ist, erhalten Sie '
        'vor Vertragsabschluss einen ehrlichen Starttermin.',
    faqTitle: 'Fragen',
    faq: [
      (
        question: 'Was kostet es, und ist die Umsatzsteuer enthalten?',
        answer:
            'Die Preise auf dieser Seite sind Nettopreise. Die Umsatzsteuer '
            'von 19 % kommt hinzu. Das Erstgespräch mit Konzept für 490 € '
            'liefert Ihnen ein Festpreisangebot für den Bau und wird bei '
            'Beauftragung auf den Preis angerechnet.',
      ),
      (
        question:
            'Arbeitet Cube Algos mit KI, und was passiert mit Ihren Daten?',
        answer:
            'Ja. KI fließt in die gesamte Arbeitsweise ein: Planung, '
            'Schreiben und Prüfen von Code. Kevin ist ausgebildeter '
            'Entwickler und prüft jede Zeile, bevor sie live geht. '
            'Personenbezogene Daten Ihrer Kund:innen gelangen nie in '
            'KI-Werkzeuge, und die eingesetzten KI-Werkzeuge sind so '
            'eingestellt, dass sie nicht mit Ihrem Projekt trainiert '
            'werden.',
      ),
      (
        question: 'Wie lange dauert es?',
        answer:
            'Das hängt vom Umfang ab. Eine Zahl nennt Cube Algos erst, wenn '
            'klar ist, was Sie brauchen. Das Erstgespräch mit Konzept endet '
            'mit einem schriftlichen Umfang, einem Festpreis und einem '
            'Termin.',
      ),
      (
        question: 'Wem gehört der Code?',
        answer:
            'Ihnen. Sobald das Projekt vollständig bezahlt ist, gehören '
            'Ihnen Code und Inhalte. Die eigenen allgemeinen Bausteine von '
            'Cube Algos, etwa Vorlagen und Bibliotheken, die nicht speziell '
            'für Ihr Projekt entstehen, darf das Studio weiter verwenden.',
      ),
      (
        question: 'Was passiert nach dem Launch?',
        answer:
            'Ihr Projekt ist online und bleibt Ihres. Wenn Cube Algos sich '
            'weiter darum kümmern soll, gibt es die Website-Betreuung ab 49 '
            '€ im Monat und die App-Betreuung ab 149 € im Monat. Wenn '
            'nicht, können Sie damit auch woanders hingehen.',
      ),
      (
        question: 'Was ist, wenn Kevin ausgelastet oder nicht da ist?',
        answer:
            'Cube Algos wird von einer Person geführt und sagt das offen. '
            'Projekte werden im Voraus eingeplant: Sie erhalten vor '
            'Vertragsabschluss einen verbindlichen Starttermin, geplante '
            'Abwesenheiten werden frühzeitig angekündigt. Eine Vertretung '
            'gibt es nicht, ebenso wenig garantierte Reaktionszeiten. Wird '
            'Kevin krank, erfahren Sie es so schnell wie möglich.',
      ),
      (
        question: 'Ist es barrierearm?',
        answer:
            'Jedes Projekt ist von Anfang an auf Barrierefreiheit '
            'ausgelegt: bedienbar mit der Tastatur und mit Screenreadern, '
            'gut lesbare Texte, geprüfte Kontraste. Das gehört zur '
            'Arbeitsweise von Cube Algos und ist kein Extra. Eine '
            'rechtliche Konformität für Ihr Unternehmen wird nicht '
            'zugesagt, und auch Ihre eigenen Inhalte spielen eine Rolle.',
      ),
      (
        question: 'Müssen Sie schon genau wissen, was Sie wollen?',
        answer:
            'Nein. Ein paar Sätze reichen. Ist die Idee noch unscharf, ist '
            'genau dafür das Erstgespräch mit Konzept da.',
      ),
    ],
    ctaTitle: 'Am Anfang steht eine kurze E-Mail.',
    ctaText:
        'Ein paar Zeilen dazu, was Sie brauchen, genügen. Kevin liest '
        'jede Anfrage selbst und antwortet mit einem Vorschlag für den '
        'nächsten Schritt.',
    ctaButton: 'Schreiben an hello@cubealgos.de',
  ),
};
