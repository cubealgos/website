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
  String faqTitle,
  List<Faq> faq,
  String ctaTitle,
  String ctaText,
  String ctaButton,
});

/// The home copy per language.
const Map<Lang, HomeCopy> homeCopy = {
  Lang.en: (
    eyebrow: 'AI-native software studio',
    h1: "Websites and apps for people who'd rather run their business.",
    h1Mark: 'run their business.',
    subline:
        'Built at AI speed, signed off by a trained developer, at a price you '
        'know before it starts.',
    secondaryCta: 'See what it costs',
    lanesTitle: 'Where do you start?',
    lanes: [
      (
        title: 'For your business',
        text:
            'You run a business with a few people to a few dozen: a trade, a '
            'practice, a studio, a restaurant, a shop. You need a website '
            'that works, a way for customers to book, a customer portal or a '
            'tool for your team. I build it around how your work already '
            'flows, and you keep running the business.',
        offerIds: ['website', 'app'],
      ),
      (
        title: 'For your idea',
        text:
            "You have an idea for an app or a product, and you're deciding on "
            'your own what happens next. I help you find out what to build '
            'first, then I build it. You start with an idea check, and you '
            'know what it costs before anything is built.',
        offerIds: ['idea', 'mvp'],
      ),
    ],
    offersTitle: 'What it costs',
    offersIntro:
        'Fixed prices, agreed before I start. If your project is bigger than '
        'a "from" price, the quote says so.',
    offers: [
      (
        id: 'idea',
        name: 'Idea check',
        price: '€490',
        text:
            'A workshop with you, a written scope and a fixed quote. If you '
            'then hire me to build it, the €490 is credited against the '
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
            'For changes beyond what we agreed. I tell you before I start, '
            'and nothing is billed without your yes.',
      ),
    ],
    vatNote: 'All prices plus 19% VAT.',
    accessibleNote: 'Every build is accessible from the start.',
    workflowTitle: 'The workflow',
    steps: [
      (
        title: 'Idea check.',
        text: 'We talk, I write down what to build and what to leave out.',
      ),
      (
        title: 'Fixed quote.',
        text: 'You get a price in writing before anything is built.',
      ),
      (
        title: 'Build.',
        text:
            'I build it. You see progress along the way, not only at the end.',
      ),
      (title: 'Launch.', text: 'It goes live, and I make sure it works.'),
      (
        title: 'Care.',
        text: "I keep it running, so you don't have to think about it.",
      ),
    ],
    careTitle: 'Cared for after launch',
    careText:
        'Software drifts out of date when nobody looks after it. Care means '
        'updates, small fixes and a person to ask. Care is optional and '
        "monthly. You can cancel it any time with 30 days' notice to the end "
        'of a month.',
    carePlans: [
      'Website care, from €49 a month',
      'App care, from €149 a month',
    ],
    carePlansNote:
        'Both are fixed monthly prices. Larger changes are quoted separately '
        'or billed at €95 an hour.',
    faqTitle: 'Questions',
    faq: [
      (
        question: 'What does it cost, and is VAT included?',
        answer:
            'The prices on this page are net. VAT of 19% is added on top. The '
            'idea check, €490, gives you a fixed quote for the build, and '
            "it's credited against the build price if you go ahead.",
      ),
      (
        question: 'Do you use AI, and what happens to my data?',
        answer:
            'Yes. AI is part of my whole workflow: planning, writing and '
            "checking code. I'm a trained developer, and I review every line "
            'before it ships. Personal data from your customers never goes '
            'into AI tools, and my AI tools are set not to train on your '
            'project.',
      ),
      (
        question: 'How long does it take?',
        answer:
            "It depends on the scope. I won't give you a number before I know "
            'what you need. The idea check ends with a written scope, a fixed '
            'price and a date.',
      ),
      (
        question: 'Who owns the code?',
        answer:
            'You do. Once the project is paid in full, the code and content '
            'are yours. I keep the right to reuse my own general building '
            "blocks, like templates and libraries, that aren't specific to "
            'your project.',
      ),
      (
        question: 'What happens after launch?',
        answer:
            'Your project is live and stays yours. If you want me to keep '
            "looking after it, there's website care from €49 a month and app "
            "care from €149 a month. If you don't, you can take it "
            'elsewhere.',
      ),
      (
        question: "What if you're busy or away?",
        answer:
            "I'm one person, and I'd rather say so than pretend to be an "
            "agency. That's why I plan my calendar ahead. Before you sign, I "
            'tell you when I can start, and I let you know about planned '
            "time away in advance. There's no stand-in developer, and I "
            "don't promise response times. If I'm ill, I tell you as soon as "
            'I can.',
      ),
      (
        question: 'Is it accessible?',
        answer:
            'Every build is accessible from the start: it works with a '
            'keyboard and screen readers, text is readable and contrast is '
            "checked. It's part of how I build, not an extra. I don't make "
            'legal compliance promises for your business, and your own '
            'content matters too.',
      ),
      (
        question: 'Do I need to know what I want before I write?',
        answer:
            'No. A few sentences are enough. If the idea is still vague, '
            "that's what the idea check is for.",
      ),
    ],
    ctaTitle: 'Tell me what you need.',
    ctaText: 'One email is enough. I read it myself and write back.',
    ctaButton: 'Write to hello@cubealgos.de',
  ),
  Lang.de: (
    eyebrow: 'KI-natives Softwarestudio',
    h1: 'Websites und Apps für alle, die lieber ihr Geschäft führen.',
    h1Mark: 'ihr Geschäft führen.',
    subline:
        'Gebaut im KI-Tempo, abgenommen von einem ausgebildeten Entwickler, '
        'zu einem Preis, den Sie vorher kennen.',
    secondaryCta: 'Preise ansehen',
    lanesTitle: 'Wo stehen Sie?',
    lanes: [
      (
        title: 'Für Ihr Geschäft',
        text:
            'Sie führen ein Unternehmen mit einigen wenigen bis ein paar '
            'Dutzend Mitarbeitenden: Handwerk, Praxis, Studio, Restaurant, '
            'Laden. Sie brauchen eine Website, die funktioniert, eine '
            'Terminbuchung für Ihre Kund:innen, ein Kundenportal oder ein '
            'Werkzeug für Ihr Team. Ich baue es passend zu Ihren Abläufen, '
            'und Sie führen weiter Ihr Geschäft.',
        offerIds: ['website', 'app'],
      ),
      (
        title: 'Für Ihre Idee',
        text:
            'Sie haben die Idee für eine App oder ein Produkt und '
            'entscheiden selbst, wie es weitergeht. Ich helfe Ihnen '
            'herauszufinden, was zuerst gebaut werden sollte, und baue es '
            'dann. Sie beginnen mit einem Erstgespräch mit Konzept und '
            'wissen, was es kostet, bevor etwas gebaut wird.',
        offerIds: ['idea', 'mvp'],
      ),
    ],
    offersTitle: 'Was es kostet',
    offersIntro:
        'Feste Preise, vereinbart, bevor ich anfange. Ist Ihr Projekt '
        'größer als ein „ab"-Preis, steht das im Angebot.',
    offers: [
      (
        id: 'idea',
        name: 'Erstgespräch mit Konzept',
        price: '490 €',
        text:
            'Ein Workshop mit Ihnen, ein schriftlicher Umfang und ein '
            'Festpreisangebot. Beauftragen Sie mich danach mit dem Bau, '
            'rechne ich die 490 € auf den Preis an.',
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
            'Für Änderungen über das Vereinbarte hinaus. Ich sage es Ihnen '
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
            'Wir sprechen miteinander, ich schreibe auf, was gebaut wird und '
            'was nicht.',
      ),
      (
        title: 'Festpreisangebot.',
        text: 'Sie bekommen den Preis schriftlich, bevor etwas gebaut wird.',
      ),
      (
        title: 'Bau.',
        text:
            'Ich baue es. Sie sehen den Fortschritt unterwegs, nicht erst am '
            'Ende.',
      ),
      (
        title: 'Launch.',
        text: 'Es geht online, und ich stelle sicher, dass es funktioniert.',
      ),
      (
        title: 'Betreuung.',
        text: 'Ich halte es am Laufen, damit Sie nicht daran denken müssen.',
      ),
    ],
    careTitle: 'Betreut nach dem Launch',
    careText:
        'Damit alles im Fluss bleibt, braucht Software Pflege: Updates, '
        'kleine Korrekturen und jemand, den Sie fragen können. Die '
        'Betreuung ist freiwillig und monatlich. Sie können sie jederzeit '
        'mit 30 Tagen Frist zum Monatsende kündigen.',
    carePlans: [
      'Website-Betreuung, ab 49 € im Monat',
      'App-Betreuung, ab 149 € im Monat',
    ],
    carePlansNote:
        'Beides sind feste Monatspreise. Größere Änderungen biete ich '
        'separat an oder rechne sie mit 95 € pro Stunde ab.',
    faqTitle: 'Fragen',
    faq: [
      (
        question: 'Was kostet es, und ist die Umsatzsteuer enthalten?',
        answer:
            'Die Preise auf dieser Seite sind Nettopreise. Die '
            'Umsatzsteuer von 19 % kommt hinzu. Das Erstgespräch mit '
            'Konzept für 490 € liefert Ihnen ein Festpreisangebot für den '
            'Bau und wird bei Beauftragung auf den Preis angerechnet.',
      ),
      (
        question: 'Arbeiten Sie mit KI, und was passiert mit meinen Daten?',
        answer:
            'Ja. KI fließt in meine gesamte Arbeitsweise ein: Planung, '
            'Schreiben und Prüfen von Code. Ich bin ausgebildeter '
            'Entwickler und prüfe jede Zeile, bevor sie live geht. '
            'Personenbezogene Daten Ihrer Kund:innen gebe ich nie in '
            'KI-Werkzeuge, und meine KI-Werkzeuge sind so eingestellt, dass '
            'sie nicht mit Ihrem Projekt trainiert werden.',
      ),
      (
        question: 'Wie lange dauert es?',
        answer:
            'Das hängt vom Umfang ab. Eine Zahl nenne ich erst, wenn ich '
            'weiß, was Sie brauchen. Das Erstgespräch mit Konzept endet mit '
            'einem schriftlichen Umfang, einem Festpreis und einem Termin.',
      ),
      (
        question: 'Wem gehört der Code?',
        answer:
            'Ihnen. Sobald das Projekt vollständig bezahlt ist, gehören '
            'Ihnen Code und Inhalte. Meine eigenen allgemeinen Bausteine, '
            'etwa Vorlagen und Bibliotheken, die nicht speziell für Ihr '
            'Projekt entstehen, darf ich weiter verwenden.',
      ),
      (
        question: 'Was passiert nach dem Launch?',
        answer:
            'Ihr Projekt ist online und bleibt Ihres. Wenn ich mich weiter '
            'darum kümmern soll, gibt es die Website-Betreuung ab 49 € im '
            'Monat und die App-Betreuung ab 149 € im Monat. Wenn nicht, '
            'können Sie damit auch woanders hingehen.',
      ),
      (
        question: 'Was ist, wenn Sie ausgelastet oder nicht da sind?',
        answer:
            'Ich bin eine Person und sage das lieber, als eine Agentur '
            'vorzutäuschen. Deshalb plane ich meinen Kalender im Voraus. '
            'Vor Vertragsabschluss nenne ich Ihnen, wann ich anfangen kann, '
            'und geplante Abwesenheiten kündige ich rechtzeitig an. Eine '
            'Vertretung gibt es nicht, und Reaktionszeiten sage ich nicht '
            'zu. Bin ich krank, gebe ich Ihnen so schnell wie möglich '
            'Bescheid.',
      ),
      (
        question: 'Ist es barrierearm?',
        answer:
            'Jedes Projekt ist von Anfang an auf Barrierefreiheit '
            'ausgelegt: bedienbar mit der Tastatur und mit Screenreadern, '
            'gut lesbare Texte, geprüfte Kontraste. Das gehört zu meiner '
            'Arbeitsweise und ist kein Extra. Eine rechtliche Konformität '
            'für Ihr Unternehmen sage ich nicht zu, und auch Ihre eigenen '
            'Inhalte spielen eine Rolle.',
      ),
      (
        question: 'Muss ich schon genau wissen, was ich will?',
        answer:
            'Nein. Ein paar Sätze reichen. Ist die Idee noch unscharf, ist '
            'genau dafür das Erstgespräch mit Konzept da.',
      ),
    ],
    ctaTitle: 'Erzählen Sie mir, was Sie brauchen.',
    ctaText:
        'Eine E-Mail genügt. Ich lese sie selbst und schreibe Ihnen zurück.',
    ctaButton: 'Schreiben an hello@cubealgos.de',
  ),
};
