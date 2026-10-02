// SPDX-License-Identifier: Apache-2.0

/// The 404 page copy, EN and DE (microcopy "404 (confused fish)", character
/// for character; all rights reserved).
library;

import 'package:website/src/routes.dart';

/// All copy of the 404 page in one language.
typedef NotFoundCopy = ({
  String headline,
  String body,
  String homeAction,
  String mailAction,
});

/// The 404 copy per language.
const Map<Lang, NotFoundCopy> notFoundCopy = {
  Lang.en: (
    headline: 'This page swam off.',
    body:
        'The link may be old or mistyped. Back to the home page is one '
        'click away.',
    homeAction: 'Back to the home page',
    mailAction: 'Write to Kevin',
  ),
  Lang.de: (
    headline: 'Diese Seite ist davongeschwommen.',
    body:
        'Vielleicht ist der Link veraltet oder vertippt. Zur Startseite ist '
        'es nur ein Klick.',
    homeAction: 'Zur Startseite',
    mailAction: 'Kevin schreiben',
  ),
};
