// SPDX-License-Identifier: Apache-2.0

/// The home page copy, EN and DE side by side: the business card, layout B
/// "Steckbrief" (brand decisions 56, 58 and 59; copy direction C of the
/// reframe of 2026-10-29 with the regulatory edits E-C-2 and E-C-3; all rights
/// reserved). Components render it, tests compare the built pages against it.
/// The copy says what the studio is and makes, offers no client work, names
/// no price and describes no software beyond wearenotabank.
///
/// The page exists in two states ([namesProduct]): named, with the H1 "Cube
/// Algos is the studio behind wearenotabank." and the button to its GitHub
/// organisation, and unnamed, with `h1Unnamed` (copy section 3.5) and the
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

  /// The H1 of the named state ([namesProduct]); the mark is the whole word
  /// `wearenotabank`.
  Headline h1,

  /// The H1 of the unnamed state (copy section 3.5).
  Headline h1Unnamed,

  /// The paragraph under the H1, directly, at every width: it names the
  /// object (developer tools: smart contracts, SDKs, libraries) so that the
  /// name never meets a reader alone (regulatory edits E-C-2 and E-C-3).
  String lede,

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
      pre: 'Cube Algos is the studio behind ',
      mark: 'wearenotabank',
      post: '.',
    ),
    h1Unnamed: (
      pre: 'We build ',
      mark: 'our own',
      post: ' software for EVM chains.',
    ),
    lede:
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
      pre: 'Cube Algos ist das Studio hinter ',
      mark: 'wearenotabank',
      post: '.',
    ),
    h1Unnamed: (
      pre: 'Wir bauen ',
      mark: 'eigene',
      post: ' Software für EVM-Chains.',
    ),
    lede:
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
