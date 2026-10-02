// SPDX-License-Identifier: Apache-2.0

/// The home page copy, EN and DE side by side (final studio copy, character
/// for character; all rights reserved). Components render it, tests compare
/// the built pages against it. The page names no price and no product; the
/// free first call is the only thing it says about money.
library;

import 'package:website/src/outbound.dart';
import 'package:website/src/routes.dart';

/// One row of the hero's stack card: a `label` and its `value`.
typedef StackRow = ({String label, String value});

/// One of the three client lanes: a heading, a text and its examples (each
/// shown as one list item after the "for example" label).
typedef Lane = ({String title, String text, List<String> examples});

/// One workflow step: a bold `title` followed by `text`.
typedef Step = ({String title, String text});

/// One item of the studio section: a bold `lead`, its `text` and, for the
/// pointer to Kevin's site, an `aside`. `text` and `aside` may carry
/// `[label](url)` links, only to the URLs of `outbound.dart`.
typedef StudioItem = ({String lead, String text, String? aside});

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
  String stackTitle,
  List<StackRow> stack,
  String stackNote,

  /// The `id` of the own-software section, the target of `secondaryCta`.
  String ownAnchor,
  String ownTitle,
  String ownText,

  /// The `id` of the client projects section.
  String projectsAnchor,
  String projectsTitle,
  String projectsIntro,
  String examplesLabel,
  List<Lane> lanes,
  String routeTitle,
  List<Step> steps,
  String routeNote,
  String studioTitle,
  List<StudioItem> studio,
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
        'Cube Algos is a small studio that builds software of its own, and '
        'yours.',
    h1Mark: 'and yours',
    subline:
        'Its own products are built here the same way as apps, internal '
        'tools and automations for businesses and founders. The work is done '
        'with AI, and a trained developer reviews every line before it '
        'ships.',
    sublineShort:
        'Its own products, and software for businesses and founders: built '
        'with AI, checked by a developer.',
    secondaryCta: 'Learn more',
    stackTitle: "What it's built with",
    stack: [
      (label: 'Language', value: 'Dart, from the apps to this website'),
      (label: 'Apps', value: 'Flutter, on its own template with MVC'),
      (label: 'Backend', value: 'Appwrite'),
      (label: 'Operations', value: 'Linux, Docker, own server in Germany'),
      (label: 'Automation', value: 'own tools, automated checks'),
      (label: 'First call', value: 'free'),
    ],
    stackNote: 'Client projects usually use the same stack; some differ.',
    ownAnchor: 'own-software',
    ownTitle: 'Software of its own',
    ownText:
        'Cube Algos builds software of its own and runs it itself. It is '
        "built on the studio's own app template and by the same rules as "
        'every client project: with AI, checked line by line, accessible '
        'from the start. The first product of its own is in development.',
    projectsAnchor: 'projects',
    projectsTitle: 'Projects for businesses and founders',
    projectsIntro:
        'For businesses and founders, Cube Algos builds apps, internal tools '
        'and automations. The scope runs from a form with an overview to the '
        'first version of a product, and what your project includes is '
        'worked out with Kevin in a call. A written offer follows.',
    examplesLabel: 'For example:',
    lanes: [
      (
        title: 'For your business',
        text:
            'You run a business with a few people to a few dozen. Cube '
            'Algos builds you a booking tool, a customer portal or an '
            'internal dashboard that fits how your work already flows.',
        examples: [
          'online booking for your customers',
          'a customer portal your customers sign in to',
          'an internal tool with logins and roles for your team',
          'a form with an overview of every entry',
        ],
      ),
      (
        title: 'For your idea',
        text:
            'You have an idea for an app or a product. Cube Algos helps you '
            'cut the first version down to what matters, then builds it.',
        examples: [
          'the first version of your app, cut down to one core feature',
          'with sign-in, a database and an admin view, ready for real use',
        ],
      ),
      (
        title: 'For your processes',
        text:
            'Your team loses time copying between spreadsheets and tools. '
            'Cube Algos automates that work and, if you like, runs it on '
            'servers in the EU.',
        examples: [
          'bring data from several spreadsheets together automatically',
          'connect the services you already use, so nothing is typed in twice',
          'run your internal systems on servers in the EU',
        ],
      ),
    ],
    routeTitle: 'How a project works',
    steps: [
      (title: 'Free call.', text: '30 to 45 minutes, by video or phone.'),
      (
        title: 'Written offer.',
        text: 'The scope and a start date in about 3 working days.',
      ),
      (title: 'Build.', text: 'Kevin builds; you see progress along the way.'),
      (title: 'Launch.', text: 'It goes live and is yours.'),
      (title: 'After launch.', text: 'Changes and updates on request.'),
    ],
    routeNote: 'Nothing is built until you say yes.',
    studioTitle: 'A small studio, deliberately',
    studio: [
      (
        lead: 'One person, start to finish.',
        text:
            'Kevin Scheeren founded Cube Algos in 2023 and builds everything '
            "himself, the studio's own products as well as client projects. "
            'The person you talk to is the person who writes the code.',
        aside: "[Kevin's background: kevinscheeren.de]($personalSiteUrlEn)",
      ),
      (
        lead: 'Built with AI, checked by a developer.',
        text:
            'AI helps with planning, writing and testing code. Kevin is a '
            'trained software developer (MATSE) and reviews every line '
            'before it ships.',
        aside: null,
      ),
      (
        lead: 'Accessible from the start.',
        text:
            'Every build works with a keyboard and screen readers, and '
            'contrast is checked.',
        aside: null,
      ),
      (
        lead: 'No cookies, no tracking.',
        text:
            'This website runs on a server that Cube Algos operates itself '
            'and stores nothing on your device.',
        aside: null,
      ),
      (
        lead: 'Code you can read.',
        text:
            'The code of this website and the Cube Algos brand are public on '
            '[GitHub]($githubOrgUrl).',
        aside: null,
      ),
    ],
    faqTitle: 'Questions',
    faq: [
      (
        question: 'What does a project cost?',
        answer:
            'It depends on the scope. After the first call, you get a '
            'written offer.',
      ),
      (
        question: 'Is a small project worth an email?',
        answer:
            'Yes. A small tool, like a form with an overview, is a project '
            'too. A few lines by email are enough to start.',
      ),
      (
        question: 'What if Kevin is busy or away?',
        answer:
            'Cube Algos is run by one person and says so. Its own products '
            "and client projects share Kevin's time, so projects are "
            'scheduled in advance: you get a confirmed start date before '
            'signing, and planned absences are announced early. There is no '
            'stand-in developer and no guaranteed response time. If Kevin '
            'falls ill, you hear about it as soon as possible.',
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
            'offer with the scope and a start date within about 3 working '
            'days.',
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
            'updates later, Kevin does them on request, with an offer before '
            'work starts. There are no care subscriptions, and nobody '
            'monitors your app unless you ask for it. You can also take it '
            'elsewhere.',
      ),
      (
        question: 'Is it accessible?',
        answer:
            'Every build is accessible from the start: it works with a '
            'keyboard and screen readers, text is readable and contrast is '
            "checked. It's part of how Cube Algos builds. Cube Algos makes "
            'no legal compliance promises for your business, and your own '
            'content matters too.',
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
        'A few lines are enough. Kevin reads every email himself and '
        'replies with a suggested next step, for a project usually a free '
        'call.',
    ctaButton: 'Write to hello@cubealgos.de',
  ),
  Lang.de: (
    eyebrow: 'KI-gestütztes Softwarestudio · Heinsberg',
    h1:
        'Cube Algos ist ein kleines Studio, das eigene Software baut, und '
        'Ihre.',
    h1Mark: 'und Ihre',
    subline:
        'Eigene Produkte entstehen hier genauso wie Apps, interne Tools und '
        'Automatisierungen für Betriebe und Gründungsteams. Gebaut wird mit '
        'KI, und jede Zeile prüft ein ausgebildeter Entwickler, bevor sie '
        'live geht.',
    sublineShort:
        'Eigene Produkte und Software für Betriebe und Gründungsteams, mit '
        'KI gebaut, von einem Entwickler geprüft.',
    secondaryCta: 'Mehr erfahren',
    stackTitle: 'Womit hier gebaut wird',
    stack: [
      (label: 'Sprache', value: 'Dart, von der App bis zu dieser Website'),
      (label: 'Apps', value: 'Flutter, auf eigener Vorlage mit MVC'),
      (label: 'Backend', value: 'Appwrite'),
      (label: 'Betrieb', value: 'Linux, Docker, eigener Server in Deutschland'),
      (
        label: 'Automatisierung',
        value: 'eigene Werkzeuge, automatische Prüfungen',
      ),
      (label: 'Erstgespräch', value: 'kostenlos'),
    ],
    stackNote: 'Kundenprojekte meist genauso, je nach Projekt auch anders.',
    ownAnchor: 'eigene-software',
    ownTitle: 'Eigene Software',
    ownText:
        'Cube Algos entwickelt eigene Software und betreibt sie selbst. Sie '
        'entsteht auf einer eigenen App-Vorlage und nach denselben Regeln '
        'wie jedes Kundenprojekt: mit KI gebaut, Zeile für Zeile geprüft, '
        'von Anfang an barrierearm. Das erste eigene Produkt ist in '
        'Entwicklung.',
    projectsAnchor: 'projekte',
    projectsTitle: 'Projekte für Betriebe und Gründungsteams',
    projectsIntro:
        'Für Betriebe und Gründungsteams baut Cube Algos Apps, interne Tools '
        'und Automatisierungen. Der Umfang reicht vom Formular mit Übersicht '
        'bis zur ersten Version eines Produkts. Was Ihr Projekt umfasst, '
        'klären Sie mit Kevin im Gespräch; danach erhalten Sie ein '
        'schriftliches Angebot.',
    examplesLabel: 'Zum Beispiel:',
    lanes: [
      (
        title: 'Für Ihren Betrieb',
        text:
            'Sie führen einen Betrieb mit wenigen bis ein paar Dutzend '
            'Beschäftigten. Cube Algos baut Ihnen eine Online-Terminbuchung, '
            'ein Kundenportal oder ein internes Dashboard, passend zu Ihren '
            'Abläufen.',
        examples: [
          'Online-Terminbuchung für Ihre Kundschaft',
          'Kundenportal, in dem sich Ihre Kundschaft anmeldet',
          'internes Tool mit Logins und Rollen für Ihr Team',
          'Formular mit einer Übersicht aller Einträge',
        ],
      ),
      (
        title: 'Für Ihre Idee',
        text:
            'Sie haben eine Idee für eine App oder ein Produkt. Cube Algos '
            'hilft Ihnen, die erste Version auf das Wesentliche zu '
            'beschränken, und baut sie.',
        examples: [
          'die erste Version Ihrer App, beschränkt auf eine Kernfunktion',
          'mit Anmeldung, Datenbank und Verwaltung, bereit für echte Nutzung',
        ],
      ),
      (
        title: 'Für Ihre Prozesse',
        text:
            'Ihr Team verliert Zeit mit Tabellen, Kopieren und Abgleichen. '
            'Cube Algos automatisiert solche Arbeit und betreibt sie auf '
            'Wunsch auf Servern in der EU.',
        examples: [
          'Daten aus mehreren Tabellen automatisch zusammenführen',
          'Dienste verbinden, damit nichts doppelt eingetippt wird',
          'interne Systeme auf Servern in der EU betreiben',
        ],
      ),
    ],
    routeTitle: 'So läuft ein Projekt ab',
    steps: [
      (
        title: 'Kostenloses Gespräch.',
        text: '30 bis 45 Minuten, per Video oder Telefon.',
      ),
      (
        title: 'Schriftliches Angebot.',
        text: 'Umfang und Starttermin in etwa drei Werktagen.',
      ),
      (
        title: 'Umsetzung.',
        text: 'Kevin baut, Sie sehen den Fortschritt laufend.',
      ),
      (title: 'Übergabe.', text: 'Ihre App geht online und gehört Ihnen.'),
      (title: 'Danach.', text: 'Änderungen und Updates auf Anfrage.'),
    ],
    routeNote: 'Gebaut wird erst nach Ihrer Zusage.',
    studioTitle: 'Klein, und das mit Absicht',
    studio: [
      (
        lead: 'Eine Person, von Anfang bis Ende.',
        text:
            'Kevin Scheeren hat Cube Algos 2023 gegründet und baut alles '
            'selbst, die eigenen Produkte ebenso wie die Projekte für seine '
            'Kundschaft. Wer mit Ihnen spricht, schreibt auch den Code.',
        aside: '[Kevins Werdegang: kevinscheeren.de]($personalSiteUrl)',
      ),
      (
        lead: 'Mit KI gebaut, von einem Entwickler geprüft.',
        text:
            'KI hilft bei Planung, Programmierung und Tests. Kevin ist '
            'ausgebildeter Softwareentwickler (MATSE) und prüft jede Zeile, '
            'bevor sie live geht.',
        aside: null,
      ),
      (
        lead: 'Barrierearm von Anfang an.',
        text:
            'Jedes Projekt ist auf Barrierefreiheit ausgelegt: per Tastatur '
            'und Screenreader bedienbar, mit geprüften Kontrasten.',
        aside: null,
      ),
      (
        lead: 'Ohne Cookies, ohne Tracking.',
        text:
            'Diese Website läuft auf einem Server, den Cube Algos selbst '
            'betreibt, und legt nichts auf Ihrem Gerät ab.',
        aside: null,
      ),
      (
        lead: 'Code zum Nachlesen.',
        text:
            'Der Code dieser Website und die Marke von Cube Algos liegen '
            'öffentlich auf [GitHub]($githubOrgUrl).',
        aside: null,
      ),
    ],
    faqTitle: 'Fragen',
    faq: [
      (
        question: 'Was kostet ein Projekt?',
        answer:
            'Das hängt vom Umfang ab. Nach dem ersten Gespräch erhalten Sie '
            'ein schriftliches Angebot.',
      ),
      (
        question: 'Lohnt sich eine Anfrage auch für ein kleines Projekt?',
        answer:
            'Ja. Auch ein kleines Tool, etwa ein Formular mit Übersicht, ist '
            'ein Projekt für Cube Algos. Ein paar Zeilen per E-Mail genügen '
            'für den Anfang.',
      ),
      (
        question: 'Was ist, wenn Kevin ausgelastet oder nicht erreichbar ist?',
        answer:
            'Cube Algos ist ein Ein-Personen-Studio und sagt das offen. '
            'Eigene Produkte und Kundenprojekte teilen sich Kevins Zeit. '
            'Deshalb werden Projekte im Voraus eingeplant: Sie erhalten vor '
            'Vertragsabschluss einen verbindlichen Starttermin, und geplante '
            'Abwesenheiten werden früh angekündigt. Eine Vertretung gibt es '
            'nicht, feste Reaktionszeiten auch nicht. Fällt Kevin '
            'krankheitsbedingt aus, erfahren Sie das so schnell wie möglich.',
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
            'innerhalb von etwa drei Werktagen ein schriftliches Angebot mit '
            'Umfang und Starttermin.',
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
            'übernimmt Kevin auf Anfrage, mit einem Angebot vorab. Es gibt '
            'keine Wartungsverträge, und niemand überwacht Ihre App, wenn '
            'Sie das nicht beauftragen. Sie können damit jederzeit auch zu '
            'jemand anderem gehen.',
      ),
      (
        question: 'Ist die App barrierearm?',
        answer:
            'Ja. Jedes Projekt ist von Anfang an auf Barrierefreiheit '
            'ausgelegt: per Tastatur und Screenreader bedienbar, mit gut '
            'lesbaren Texten und geprüften Kontrasten. Das gehört zur '
            'Arbeitsweise. Eine rechtliche Konformität für Ihr Unternehmen '
            'wird nicht zugesagt, auch weil Ihre eigenen Inhalte eine Rolle '
            'spielen.',
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
        'Ein paar Zeilen genügen. Kevin liest jede E-Mail selbst und '
        'antwortet mit einem Vorschlag für den nächsten Schritt, bei einem '
        'Projekt meist einem kostenlosen Gespräch.',
    ctaButton: 'E-Mail an hello@cubealgos.de',
  ),
};
