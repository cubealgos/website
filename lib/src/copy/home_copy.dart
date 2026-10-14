// SPDX-License-Identifier: Apache-2.0

/// The home page copy, EN and DE side by side (copy v2 of the studio, final;
/// all rights reserved). Components render it, tests compare the built pages
/// against it. The page offers no client work, names no price and promises
/// nothing about money.
library;

import 'package:website/src/outbound.dart';
import 'package:website/src/routes.dart';

/// One row of the hero's stack card: a `label` and its `value`.
typedef StackRow = ({String label, String value});

/// One item of the studio section: a bold `lead` and its `text`, which may
/// carry `[label](url)` links to the URLs of `outbound.dart`. An item with a
/// `postId` ends with a link to that blog post (left out while the post does
/// not exist).
typedef StudioItem = ({String lead, String text, String? postId});

/// All copy of the home page in one language.
typedef HomeCopy = ({
  String eyebrow,
  String h1,

  /// The part of `h1` that carries the drawn underline.
  String h1Mark,
  String subline,

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
    eyebrow: 'Software studio · Heinsberg',
    h1: 'We build our own applications for decentralised finance.',
    h1Mark: 'our own',
    subline:
        'Smart contracts in Solidity, apps in Dart and Flutter, from a '
        'small studio in Heinsberg. We publish our contracts with their '
        'source code and their licence.',
    sublineShort:
        'Smart contracts in Solidity, apps in Flutter. From Heinsberg.',
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
        'What we have built and published, each with its status, its '
        'licence and its source code.',
    allWorks: 'All works ({n})',
    studioAnchor: 'studio',
    studioTitle: 'The studio',
    studio: [
      (
        lead: 'Our own work.',
        text:
            'We build what we publish ourselves, and we take no client '
            'projects.',
        postId: null,
      ),
      (
        lead: 'Fixed once deployed.',
        text:
            'Our contracts have no admin, pause or upgrade key. A fix is a '
            'new version at a new address.',
        postId: null,
      ),
      (
        lead: 'We hold nothing for others.',
        text:
            'We keep no money or tokens for others, and no key that could '
            "reach anyone else's wallet.",
        postId: null,
      ),
      (
        lead: 'Code you can read.',
        text:
            'Each of our contracts shown here links to its source code. The '
            'code of this website and our brand are public on '
            '[GitHub]($githubOrgUrl), too.',
        postId: null,
      ),
      (
        lead: 'No cookies, no tracking.',
        text:
            'This website runs on a server we operate ourselves and stores '
            'nothing on your device.',
        postId: null,
      ),
      (
        lead: 'New tools.',
        text: 'We love working with modern technology, AI included.',
        postId: aiPostId,
      ),
    ],
    blogTitle: 'From the blog',
    allPosts: 'All posts',
    ctaTitle: 'Write to us.',
    ctaText:
        'For collaborations, integrations, grants or press, a short email '
        'is enough.',
    ctaButton: 'Write to hello@cubealgos.de',
  ),
  Lang.de: (
    eyebrow: 'Softwarestudio · Heinsberg',
    h1: 'Wir bauen eigene Anwendungen für dezentrale Finanzen.',
    h1Mark: 'eigene',
    subline:
        'Smart Contracts in Solidity, Apps in Dart und Flutter, aus einem '
        'kleinen Studio in Heinsberg. Unsere Smart Contracts '
        'veröffentlichen wir mit Quelltext und Lizenz.',
    sublineShort:
        'Smart Contracts in Solidity, Apps in Flutter. Aus Heinsberg.',
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
        'Was wir gebaut und veröffentlicht haben, jeweils mit Status, '
        'Lizenz und Quelltext.',
    allWorks: 'Alle Arbeiten ({n})',
    studioAnchor: 'studio',
    studioTitle: 'Das Studio',
    studio: [
      (
        lead: 'Eigene Arbeiten.',
        text:
            'Wir bauen, was wir selbst veröffentlichen, und nehmen keine '
            'Kundenprojekte an.',
        postId: null,
      ),
      (
        lead: 'Nach der Bereitstellung unveränderlich.',
        text:
            'Unsere Smart Contracts haben keinen Admin-, Pausen- oder '
            'Upgrade-Schlüssel. Eine Korrektur ist eine neue Version unter '
            'einer neuen Adresse.',
        postId: null,
      ),
      (
        lead: 'Wir verwahren nichts für andere.',
        text:
            'Wir halten weder Geld noch Token für andere und keinen '
            'Schlüssel, mit dem wir auf fremde Wallets zugreifen könnten.',
        postId: null,
      ),
      (
        lead: 'Quelltext zum Nachlesen.',
        text:
            'Zu jedem unserer Smart Contracts hier verlinken wir den '
            'Quelltext. Auch der Code dieser Website und unsere Marke liegen '
            'öffentlich auf [GitHub]($githubOrgUrl).',
        postId: null,
      ),
      (
        lead: 'Ohne Cookies, ohne Tracking.',
        text:
            'Diese Website läuft auf einem Server, den wir selbst '
            'betreiben, und legt nichts auf Ihrem Gerät ab.',
        postId: null,
      ),
      (
        lead: 'Neue Werkzeuge.',
        text: 'Wir arbeiten gern mit moderner Technik, auch mit KI.',
        postId: aiPostId,
      ),
    ],
    blogTitle: 'Aus dem Blog',
    allPosts: 'Alle Beiträge',
    ctaTitle: 'Schreiben Sie uns.',
    ctaText:
        'Für Zusammenarbeit, Integrationen, Förderprogramme und Presse '
        'genügt eine kurze E-Mail.',
    ctaButton: 'E-Mail an hello@cubealgos.de',
  ),
};
