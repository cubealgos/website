// SPDX-License-Identifier: Apache-2.0

/// The home page copy, EN and DE side by side (copy v3 of the studio, brand
/// decisions 56 and 57; all rights reserved). Components render it, tests
/// compare the built pages against it. The copy says what the studio is and
/// makes, offers no client work, names no price and promises nothing about
/// money.
library;

import 'package:website/src/outbound.dart';
import 'package:website/src/routes.dart';

/// One row of the hero's stack card: a `label` and its `value`.
typedef StackRow = ({String label, String value});

/// One item of the studio section: a bold `lead` and its `text`, which may
/// carry `[label](url)` links to the URLs of `outbound.dart`. An item with a
/// `postId` ends with a link to that blog post (left out while the post does
/// not exist). An item that `needsSource` is shown only while a work links its
/// source code (it says the source is linked).
typedef StudioItem = ({
  String lead,
  String text,
  String? postId,
  bool needsSource,
});

/// All copy of the home page in one language.
typedef HomeCopy = ({
  String eyebrow,
  String h1,

  /// The part of `h1` that carries the drawn underline.
  String h1Mark,
  String subline,

  /// The sentence after `subline` that says the contracts are published with
  /// their source: shown only while a work links its source code.
  String sublineSource,

  /// The shorter subline shown on phones (below 30rem) instead of `subline`.
  String sublineShort,

  /// The hero's primary button while the site shows at least one work.
  String buttonWork,

  /// The hero's primary button while it shows none.
  String buttonStudio,
  String secondaryCta,
  String stackTitle,
  List<StackRow> stack,

  /// The `id` of the works section (the target of `buttonWork`).
  String workAnchor,
  String workTitle,
  String workIntro,

  /// The label of the link to all works; `{n}` is their number.
  String allWorks,

  /// The `id` of the studio section (the target of `buttonStudio`).
  String studioAnchor,
  String studioTitle,
  List<StudioItem> studio,
  String blogTitle,
  String allPosts,
  String ctaTitle,
  String ctaText,
  String ctaButton,
});

/// The id of the blog post on how AI agents work in the repositories, which
/// the studio section and About link to.
const aiPostId = 'ai-agents';

/// The home copy per language.
const Map<Lang, HomeCopy> homeCopy = {
  Lang.en: (
    eyebrow: 'Decentralised finance · Heinsberg',
    h1: 'We build software that lets wallets do more on their own.',
    h1Mark: 'more on their own',
    subline:
        'Reading prices, paying for gas in another token, converting the '
        'tokens that come in: we are building the smart contracts and apps '
        'for it.',
    sublineSource:
        'We publish our contracts with their source code and their licence.',
    sublineShort:
        'Reading prices, paying gas in another token, converting tokens.',
    buttonWork: 'See the work',
    buttonStudio: 'Learn more',
    secondaryCta: 'Write to us',
    stackTitle: 'What we build with',
    stack: [
      (
        label: 'Contracts',
        value:
            'Solidity and Foundry, tested against the deployed protocols they '
            'call',
      ),
      (label: 'Apps', value: 'Dart and Flutter, on our own app template'),
      (label: 'Web', value: 'Dart with Jaspr, this website included'),
      (label: 'Checks', value: 'tests, fork tests, licence and wording checks'),
      (
        label: 'Hosting',
        value: 'Linux and Docker on a server we run ourselves in Germany',
      ),
      (label: 'Licences', value: 'Apache-2.0; BUSL 1.1 for some works'),
    ],
    workAnchor: 'work',
    workTitle: 'Work',
    workIntro:
        'What we have built, each with its status, licence and source '
        'code: to check, and to build on.',
    allWorks: 'All works ({n})',
    studioAnchor: 'studio',
    studioTitle: 'The studio',
    studio: [
      (
        lead: 'Our own work.',
        text: 'We build the software we want to use ourselves.',
        postId: null,
        needsSource: false,
      ),
      (
        lead: 'Fixed once deployed.',
        text:
            'Our contracts have no admin, pause or upgrade key. The code at an '
            'address stays as you check it; a fix is a new version at a new '
            'address.',
        postId: null,
        needsSource: false,
      ),
      (
        lead: 'Your keys stay with you.',
        text:
            'We build our contracts and apps for your own wallet, which acts '
            'on rules you sign yourself.',
        postId: null,
        needsSource: false,
      ),
      (
        lead: 'Code you can read.',
        text:
            'Each of our contracts shown here links to its source code. The '
            'code of this website and our brand are public on '
            '[GitHub]($githubOrgUrl), too.',
        postId: null,
        needsSource: true,
      ),
      (
        lead: 'New tools.',
        text: 'We love working with modern technology, AI included.',
        postId: aiPostId,
        needsSource: false,
      ),
    ],
    blogTitle: 'From the blog',
    allPosts: 'All posts',
    ctaTitle: 'Write to us.',
    ctaText:
        'Building something related, running a grant programme or writing '
        'about decentralised finance? A short email is enough.',
    ctaButton: 'Write to hello@cubealgos.de',
  ),
  Lang.de: (
    eyebrow: 'Dezentrale Finanzen · Heinsberg',
    h1: 'Wir bauen Software, mit der Wallets mehr selbst erledigen.',
    h1Mark: 'mehr selbst',
    subline:
        'Preise lesen, Gas in einem anderen Token bezahlen, eingehende Token '
        'umwandeln: Dafür bauen wir gerade Smart Contracts und Apps.',
    sublineSource:
        'Unsere Smart Contracts veröffentlichen wir mit Quelltext und Lizenz.',
    sublineShort:
        'Preise lesen, Gas in einem anderen Token bezahlen, Token umwandeln.',
    buttonWork: 'Arbeiten ansehen',
    buttonStudio: 'Mehr erfahren',
    secondaryCta: 'Schreiben Sie uns',
    stackTitle: 'Womit wir bauen',
    stack: [
      (
        label: 'Smart Contracts',
        value:
            'Solidity und Foundry, getestet gegen die Protokolle, die sie '
            'aufrufen',
      ),
      (
        label: 'Apps',
        value: 'Dart und Flutter, auf unserer eigenen App-Vorlage',
      ),
      (label: 'Web', value: 'Dart mit Jaspr, auch diese Website'),
      (
        label: 'Prüfungen',
        value: 'Tests, Fork-Tests, Lizenz- und Textprüfungen',
      ),
      (
        label: 'Betrieb',
        value:
            'Linux und Docker auf einem selbst betriebenen Server in '
            'Deutschland',
      ),
      (label: 'Lizenzen', value: 'Apache-2.0, für einzelne Arbeiten BUSL 1.1'),
    ],
    workAnchor: 'arbeiten',
    workTitle: 'Arbeiten',
    workIntro:
        'Was wir gebaut haben, jeweils mit Status, Lizenz und Quelltext: '
        'zum Prüfen und Einbinden.',
    allWorks: 'Alle Arbeiten ({n})',
    studioAnchor: 'studio',
    studioTitle: 'Das Studio',
    studio: [
      (
        lead: 'Eigene Arbeiten.',
        text: 'Wir bauen die Software, die wir selbst benutzen wollen.',
        postId: null,
        needsSource: false,
      ),
      (
        lead: 'Nach der Bereitstellung unveränderlich.',
        text:
            'Unsere Smart Contracts haben keinen Admin-, Pausen- oder '
            'Upgrade-Schlüssel. Der Code unter einer Adresse bleibt, wie Sie '
            'ihn prüfen; eine Korrektur ist eine neue Version unter einer '
            'neuen Adresse.',
        postId: null,
        needsSource: false,
      ),
      (
        lead: 'Ihre Schlüssel bleiben bei Ihnen.',
        text:
            'Wir bauen unsere Smart Contracts und Apps für Ihre eigene '
            'Wallet. Die Wallet handelt nach Regeln, die Sie selbst '
            'signieren.',
        postId: null,
        needsSource: false,
      ),
      (
        lead: 'Quelltext zum Nachlesen.',
        text:
            'Zu jedem unserer Smart Contracts hier verlinken wir den '
            'Quelltext. Auch der Code dieser Website und unsere Marke liegen '
            'öffentlich auf [GitHub]($githubOrgUrl).',
        postId: null,
        needsSource: true,
      ),
      (
        lead: 'Neue Werkzeuge.',
        text: 'Wir arbeiten gern mit moderner Technik, auch mit KI.',
        postId: aiPostId,
        needsSource: false,
      ),
    ],
    blogTitle: 'Aus dem Blog',
    allPosts: 'Alle Beiträge',
    ctaTitle: 'Schreiben Sie uns.',
    ctaText:
        'Sie bauen an etwas Verwandtem, betreuen ein Förderprogramm oder '
        'schreiben über dezentrale Finanzen? Eine kurze E-Mail genügt.',
    ctaButton: 'E-Mail an hello@cubealgos.de',
  ),
};
