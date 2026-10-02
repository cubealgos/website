// SPDX-License-Identifier: Apache-2.0

/// Copy shared by several pages (final EN/DE brand copy; all rights reserved).
library;

import 'package:website/src/routes.dart';

/// The label of the hero's "start a project" button (a `mailto:` link).
const Map<Lang, String> startProject = {
  Lang.en: 'Start a project',
  Lang.de: 'Projekt anfragen',
};

/// The label of the "write to Kevin" button on the about page.
const Map<Lang, String> writeToKevin = {
  Lang.en: 'Write to Kevin',
  Lang.de: 'Schreiben Sie Kevin',
};
