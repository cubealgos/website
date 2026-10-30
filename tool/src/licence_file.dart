// SPDX-License-Identifier: Apache-2.0

/// Classifies a pub package's LICENSE file from the pub cache, for the
/// packages pub.dev reports no licence tag for (its tag analysis is
/// intermittent). `dart pub get` verifies the downloaded archive against the
/// sha256 in `pubspec.lock`, so the file in the cache is authoritative for the
/// locked version.
///
/// The classifier only ever says "yes, this is a standard permissive text": a
/// file it does not recognise, or cannot find, yields nothing and the
/// dependency stays denied.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'licence_texts.dart';

/// Lower-cases [text] and collapses every run of non-alphanumeric characters
/// to one space, so line breaks, wrapping, quotes and punctuation do not
/// matter when comparing licence texts.
String normaliseLicenceText(String text) =>
    text.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), ' ').trim();

/// Builds a pattern from normalised [fragments]; a `*` stands for a short
/// free text (a holder's name), so "Neither the name of Google LLC" matches.
RegExp _pattern(List<String> fragments, {String trailing = r'$'}) {
  final body = fragments
      .join(' ')
      .split('*')
      .map(RegExp.escape)
      .join('[a-z0-9 ]{1,120}?');
  return RegExp('$body$trailing');
}

const _mitFragments = [
  'permission is hereby granted free of charge to any person obtaining a copy',
  'of this software and associated documentation files the software to deal',
  'in the software without restriction including without limitation the rights',
  'to use copy modify merge publish distribute sublicense and or sell copies',
  'of the software and to permit persons to whom the software is furnished to',
  'do so subject to the following conditions the above copyright notice and',
  'this permission notice shall be included in all copies or substantial',
  'portions of the software the software is provided as is without warranty',
  'of any kind express or implied including but not limited to the warranties',
  'of merchantability fitness for a particular purpose and noninfringement in',
  'no event shall * be liable for any claim damages or other liability whether',
  'in an action of contract tort or otherwise arising from out of or in',
  'connection with the software or the use or other dealings in the software',
];

const _bsdHead = [
  'redistribution and use in source and binary forms with or without',
  'modification are permitted provided that the following conditions are met',
  'redistributions of source code must retain the above copyright notice this',
  'list of conditions and the following disclaimer redistributions in binary',
  'form must reproduce the above copyright notice this list of conditions and',
  'the following disclaimer in the documentation and or other materials',
  'provided with the distribution',
];

const _bsdNoEndorsement = [
  'neither the name of * nor the names of its contributors may be used to',
  'endorse or promote products derived from this software without specific',
  'prior written permission',
];

const _bsdDisclaimer = [
  'this software is provided by * as is and any express or implied warranties',
  'including but not limited to the implied warranties of merchantability and',
  'fitness for a particular purpose are disclaimed in no event shall * be',
  'liable for any direct indirect incidental special exemplary or',
  'consequential damages including but not limited to procurement of',
  'substitute goods or services loss of use data or profits or business',
  'interruption however caused and on any theory of liability whether in',
  'contract strict liability or tort including negligence or otherwise',
  'arising in any way out of the use of this software even if advised of the',
  'possibility of such damage',
];

final RegExp _mit = _pattern(_mitFragments);
final RegExp _bsd3 = _pattern([
  ..._bsdHead,
  ..._bsdNoEndorsement,
  ..._bsdDisclaimer,
]);
final RegExp _bsd2 = _pattern([..._bsdHead, ..._bsdDisclaimer]);

final String _apache2 = normaliseLicenceText(apache2Text);

/// What may follow the Apache text: nothing, or its boilerplate appendix.
const _apacheAppendix = 'appendix how to apply the apache license';

/// Words that make what precedes the licence body more than a copyright line
/// or a contributor list: the file adds terms of its own, or carries another
/// licence before the standard one.
final _termsInPrefix = RegExp(
  'permission|redistribut|condition|restrict|prohibit|commercial|dual',
);

/// A text that names one of these is a dual or composite licence, which a
/// human has to read.
final _copyleft = RegExp(
  'gnu general public|gnu affero|gnu lesser|gnu library general|'
  'server side public|business source license|commons clause|'
  'creative commons',
);

/// The SPDX identifier of [text] when it is one of the standard permissive
/// texts (`MIT`, `BSD-3-Clause`, `BSD-2-Clause`, `Apache-2.0`), else null.
///
/// A copyright line or a contributor list may precede the licence body; terms
/// of the file's own before it, and anything but the Apache appendix after it,
/// mean the file is not the standard text and is not recognised.
String? classifyLicenceText(String text) {
  final normalised = normaliseLicenceText(text);
  if (_copyleft.hasMatch(normalised)) return null;
  bool plainPrefix(int end) =>
      !_termsInPrefix.hasMatch(normalised.substring(0, end));
  for (final (spdx, pattern) in [
    ('BSD-3-Clause', _bsd3),
    ('BSD-2-Clause', _bsd2),
    ('MIT', _mit),
  ]) {
    final match = pattern.firstMatch(normalised);
    if (match != null) return plainPrefix(match.start) ? spdx : null;
  }
  final at = normalised.indexOf(_apache2);
  if (at >= 0 && plainPrefix(at)) {
    final rest = normalised.substring(at + _apache2.length).trimLeft();
    if (rest.isEmpty || rest.startsWith(_apacheAppendix)) return 'Apache-2.0';
  }
  return null;
}

const _licenceFileNames = [
  'license',
  'license.md',
  'license.txt',
  'licence',
  'licence.md',
  'licence.txt',
  'copying',
];

/// The directory of [package] at [version] in the pub cache, as `dart pub get`
/// recorded it in `.dart_tool/package_config.json` (an absolute `file:` URI,
/// or one relative to that file); null when it cannot be resolved or is not
/// the locked version (a stale resolution).
Directory? cachedPackageDirectory(String root, String package, String version) {
  final config = File(p.join(root, '.dart_tool', 'package_config.json'));
  if (!config.existsSync()) return null;
  final Object? doc;
  try {
    doc = jsonDecode(config.readAsStringSync());
  } on FormatException {
    return null;
  }
  final packages = doc is Map<String, dynamic> ? doc['packages'] : null;
  if (packages is! List) return null;
  for (final entry in packages) {
    if (entry is! Map<String, dynamic> || entry['name'] != package) continue;
    final rootUri = entry['rootUri'];
    if (rootUri is! String) return null;
    final dir = Directory(config.uri.resolve(rootUri).toFilePath());
    if (p.basename(dir.path) != '$package-$version') return null;
    return dir.existsSync() ? dir : null;
  }
  return null;
}

/// The licence file in [dir], by the usual names (any case), or null.
File? findLicenceFile(Directory dir) {
  final files = {
    for (final e in dir.listSync().whereType<File>())
      p.basename(e.path).toLowerCase(): e,
  };
  for (final name in _licenceFileNames) {
    final file = files[name];
    if (file != null) return file;
  }
  return null;
}

/// Classifies the LICENSE file of [package] at [version] from the pub cache of
/// the repo at [root]. Logs through [log] why it found nothing; returns the
/// SPDX identifier, or null.
String? licenceFromCache(
  String root,
  String package,
  String version, {
  required void Function(String) log,
}) {
  final label = 'licence_check: $package $version';
  final dir = cachedPackageDirectory(root, package, version);
  if (dir == null) {
    log(
      '$label: not in the pub cache at that version '
      '(run `dart pub get` first); no LICENSE file to read.',
    );
    return null;
  }
  final file = findLicenceFile(dir);
  if (file == null) {
    log('$label: the package has no LICENSE file.');
    return null;
  }
  final licence = classifyLicenceText(
    utf8.decode(file.readAsBytesSync(), allowMalformed: true),
  );
  if (licence == null) {
    log(
      '$label: ${p.basename(file.path)} is not a standard MIT, BSD or '
      'Apache-2.0 text.',
    );
    return null;
  }
  log(
    '$label: no licence tag on pub.dev; '
    '${p.basename(file.path)} in the pub cache is $licence.',
  );
  return licence;
}
