// SPDX-License-Identifier: Apache-2.0

/// The dependency-licence policy, a mechanical copy of
/// `standards/legal/dependency-license-policy.md` in the cubealgos heimathafen
/// (the source of truth; update both together).
library;

/// SPDX identifiers accepted unconditionally.
const Set<String> allowedLicences = {
  'MIT',
  'Apache-2.0',
  'Apache-2.0 WITH LLVM-exception',
  'BSD-2-Clause',
  'BSD-3-Clause',
  'Unicode-3.0',
  'Unlicense',
  'CC0-1.0',
  'Zlib',
  'ISC',
  'PSF-2.0',
  'BlueOak-1.0.0',
  'MIT-0',
  '0BSD',
};

/// MPL-2.0 is denied unless recorded as a per-package exception.
const String mplLicence = 'MPL-2.0';

/// Whether [spdx] is a copyleft/source-available licence the policy denies
/// outright (no exception reaches these).
bool isDeniedFamily(String spdx) {
  final upper = spdx.toUpperCase();
  return upper.startsWith('GPL') ||
      upper.startsWith('AGPL') ||
      upper.startsWith('LGPL') ||
      upper.startsWith('SSPL') ||
      upper.startsWith('BUSL');
}

/// Maps a pub.dev `license:<tag>` suffix to its SPDX identifier.
const Map<String, String> pubDevTagToSpdx = {
  'mit': 'MIT',
  'apache-2.0': 'Apache-2.0',
  'apache-2.0-with-llvm-exception': 'Apache-2.0 WITH LLVM-exception',
  'bsd-2-clause': 'BSD-2-Clause',
  'bsd-3-clause': 'BSD-3-Clause',
  'unicode-3.0': 'Unicode-3.0',
  'unlicense': 'Unlicense',
  'cc0-1.0': 'CC0-1.0',
  'zlib': 'Zlib',
  'isc': 'ISC',
  'psf-2.0': 'PSF-2.0',
  'python-2.0': 'PSF-2.0',
  'blueoak-1.0.0': 'BlueOak-1.0.0',
  'mit-0': 'MIT-0',
  '0bsd': '0BSD',
  'mpl-2.0': mplLicence,
  'gpl-2.0-only': 'GPL-2.0-only',
  'gpl-2.0-or-later': 'GPL-2.0-or-later',
  'gpl-3.0-only': 'GPL-3.0-only',
  'gpl-3.0-or-later': 'GPL-3.0-or-later',
  'agpl-3.0-only': 'AGPL-3.0-only',
  'agpl-3.0-or-later': 'AGPL-3.0-or-later',
  'lgpl-2.1-only': 'LGPL-2.1-only',
  'lgpl-2.1-or-later': 'LGPL-2.1-or-later',
  'lgpl-3.0-only': 'LGPL-3.0-only',
  'lgpl-3.0-or-later': 'LGPL-3.0-or-later',
  'sspl-1.0': 'SSPL-1.0',
  'busl-1.1': 'BUSL-1.1',
};

/// pub.dev `license:` tags that are badges, not licences.
const Set<String> pubDevNonLicenceTags = {'fsf-libre', 'osi-approved'};
