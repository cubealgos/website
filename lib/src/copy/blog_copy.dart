// SPDX-License-Identifier: Apache-2.0

/// The copy of the blog pages (the index and the frame of a post), EN and DE
/// (copy v3, section 6; all rights reserved). The words of a post are in its
/// file under `content/posts/`.
library;

import 'package:website/src/routes.dart';

/// All copy of the blog pages in one language.
typedef BlogCopy = ({
  String lede,

  /// The line under a post in the index; `{date}` and `{n}`.
  String meta,

  /// The accessible name of a post's link in the index; `{title}`.
  String readLink,

  /// Marks a post that exists in the other language only.
  String otherLanguageOnly,

  /// The label of the link back to the index (an arrow is drawn before it).
  String back,
  String contentsTitle,

  /// The line on a post's page; `{date}`.
  String published,
  String readingTime,

  /// The link to the same post in the other language.
  String otherLanguage,
  String end,
  String codeLabel,
});

/// The blog copy per language.
const Map<Lang, BlogCopy> blogCopy = {
  Lang.en: (
    lede: 'Notes from the studio: how we work and what we learn along the way.',
    meta: '{date} · {n} min read',
    readLink: 'Read {title}',
    otherLanguageOnly: 'In German',
    back: 'All posts',
    contentsTitle: 'Contents',
    published: 'Published {date}',
    readingTime: '{n} min read',
    otherLanguage: 'This post is also available in German.',
    end: 'Back to the blog',
    codeLabel: 'Code example',
  ),
  Lang.de: (
    lede: 'Notizen aus dem Studio: wie wir arbeiten und was wir dabei lernen.',
    meta: '{date} · {n} Min. Lesezeit',
    readLink: '{title} lesen',
    otherLanguageOnly: 'Auf Englisch',
    back: 'Alle Beiträge',
    contentsTitle: 'Inhalt',
    published: 'Veröffentlicht am {date}',
    readingTime: '{n} Min. Lesezeit',
    otherLanguage: 'Diesen Beitrag gibt es auch auf Englisch.',
    end: 'Zurück zum Blog',
    codeLabel: 'Codebeispiel',
  ),
};

const _monthsDe = [
  'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August',
  'September', 'Oktober', 'November', 'Dezember', //
];
const _monthsEn = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December', //
];

/// [date] as the copy writes it: „14. Oktober 2026", "14 October 2026".
String formatDate(DateTime date, Lang lang) => switch (lang) {
  Lang.de => '${date.day}. ${_monthsDe[date.month - 1]} ${date.year}',
  Lang.en => '${date.day} ${_monthsEn[date.month - 1]} ${date.year}',
};
