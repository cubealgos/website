// SPDX-License-Identifier: Apache-2.0

/// The home page copy, EN and DE side by side: the business card, layout B
/// "Steckbrief" (brand decisions 56, 58 and 59; copy direction C of the
/// reframe of 2026-10-29 with the regulatory edits E-C-2 and E-C-3, and the
/// H1 and paragraph of copy direction 2 "Dart trifft EVM" of 2026-10-30; all
/// rights reserved). Components render it, tests compare the built pages
/// against it. The copy says what the studio is and makes, offers no client
/// work, names no price and describes no software beyond wearenotabank.
///
/// The page exists in two states ([namesProduct]): named, with the H1 "We
/// build tools that connect Dart apps to EVM chains.", a paragraph that names
/// wearenotabank and viem_dart, and the button to its GitHub organisation;
/// and unnamed, with `h1Unnamed` (copy section 3.5), `ledeUnnamed` and the
/// button to the contact page. Everything that differs is a field here.
library;

import 'package:website/src/outbound.dart';
import 'package:website/src/routes.dart';

/// A headline in three parts; `mark` carries the drawn underline and is
/// always a whole word or phrase, never a part of one.
typedef Headline = ({String pre, String mark, String post});

/// The headline as one string.
String headlineText(Headline h) => '${h.pre}${h.mark}${h.post}';

/// All copy of the home page in one language.
typedef HomeCopy = ({
  String eyebrow,

  /// The H1 of the named state ([namesProduct]); the mark is the whole
  /// phrase for the reader's side, the Dart apps.
  Headline h1,

  /// The H1 of the unnamed state (copy section 3.5).
  Headline h1Unnamed,

  /// The paragraph under the H1 in the named state, directly, at every
  /// width: it names wearenotabank next to its object (SDKs, libraries,
  /// smart contracts), so that the name never meets a reader alone
  /// (wearenotabank `DEC-082` D3, regulatory edit E-C-3), never makes the
  /// name the actor (D10), and calls viem_dart an independent port, never an
  /// official viem release (regulatory edit E-C-6).
  String lede,

  /// The paragraph of the unnamed state: the object line of regulatory edit
  /// E-C-2, without the product's name.
  String ledeUnnamed,

  /// The product's name as the Produkt row shows it: always the whole word,
  /// in lower case (wearenotabank `DEC-082` D2).
  String product,

  /// The primary button of the named state; it leads to the organisation.
  String productButton,

  /// The text link to the contact page in the named state, and the label of
  /// the primary button in the unnamed state.
  String contactLink,

  /// The title of the fact sheet.
  String sheetTitle,
  String providerLabel,
  String registerLabel,
  String productLabel,
  String contactLabel,
  String blogLabel,
});

/// The home copy per language.
const Map<Lang, HomeCopy> homeCopy = {
  Lang.en: (
    eyebrow: 'Software studio · Heinsberg',
    h1: (
      pre: 'We build tools that connect ',
      mark: 'Dart apps',
      post: ' to EVM chains.',
    ),
    h1Unnamed: (
      pre: 'We build ',
      mark: 'our own',
      post: ' software for EVM chains.',
    ),
    lede:
        'Under the name wearenotabank we make SDKs, libraries and smart '
        'contracts, among them viem_dart, an independent port of viem to pure '
        'Dart. Kevin Scheeren founded the studio in Heinsberg in 2023 and runs '
        'it as managing director.',
    ledeUnnamed:
        'We make developer tools: smart contracts, SDKs and libraries for EVM '
        'chains, with a focus on Dart. Kevin Scheeren founded the studio in '
        'Heinsberg in 2023 and runs it as managing director.',
    product: 'wearenotabank',
    productButton: 'wearenotabank on GitHub',
    contactLink: 'Write to us',
    sheetTitle: 'At a glance',
    providerLabel: 'Provider',
    registerLabel: 'Commercial register entry',
    productLabel: 'Product',
    contactLabel: 'Contact',
    blogLabel: 'Blog',
  ),
  Lang.de: (
    eyebrow: 'Softwarestudio · Heinsberg',
    h1: (
      pre: 'Wir bauen Werkzeuge, die ',
      mark: 'Dart-Apps',
      post: ' mit EVM-Chains verbinden.',
    ),
    h1Unnamed: (
      pre: 'Wir bauen ',
      mark: 'eigene',
      post: ' Software für EVM-Chains.',
    ),
    lede:
        'Unter dem Namen wearenotabank entstehen SDKs, Bibliotheken und Smart '
        'Contracts, darunter viem_dart, eine unabhängige Portierung von viem '
        'in reines Dart. Gegründet hat das Studio Kevin Scheeren 2023 in '
        'Heinsberg; er führt es als Geschäftsführer.',
    ledeUnnamed:
        'Wir bauen Werkzeuge für die Softwareentwicklung: Smart Contracts, '
        'SDKs und Bibliotheken für EVM-Chains, mit Schwerpunkt auf Dart. '
        'Gegründet hat das Studio Kevin Scheeren 2023 in Heinsberg; er führt '
        'es als Geschäftsführer.',
    product: 'wearenotabank',
    productButton: 'wearenotabank auf GitHub',
    contactLink: 'Schreiben Sie uns',
    sheetTitle: 'Steckbrief',
    providerLabel: 'Anbieter',
    registerLabel: 'Registereintrag',
    productLabel: 'Produkt',
    contactLabel: 'Kontakt',
    blogLabel: 'Blog',
  ),
};

/// The headline of [lang] in the state in which the site [named] the product.
Headline homeHeadline(Lang lang, {bool named = namesProduct}) =>
    named ? homeCopy[lang]!.h1 : homeCopy[lang]!.h1Unnamed;

/// The paragraph of [lang] in the state in which the site [named] the product.
String homeLede(Lang lang, {bool named = namesProduct}) =>
    named ? homeCopy[lang]!.lede : homeCopy[lang]!.ledeUnnamed;
