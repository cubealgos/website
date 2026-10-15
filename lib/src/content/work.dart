// SPDX-License-Identifier: Apache-2.0

/// A published work: the model behind one data file of `content/works/`.
///
/// The data file is the compliance unit of a work (regulatory check of
/// 2026-10-14, section 8): [Work.fromJson] refuses a data file that would
/// render a claim the page cannot back, instead of letting the template
/// render it.
library;

import 'package:website/src/routes.dart';

/// A text in both languages.
typedef Localized = Map<Lang, String>;

/// How far a work is.
enum WorkStatus {
  /// The source code is not public yet.
  inDevelopment('in-development'),

  /// The source code is published, nothing is deployed.
  public('public'),

  /// Deployed (a contract on chains, an app available).
  deployed('deployed');

  new(this.id);

  /// The value in the data file.
  final String id;
}

/// The licence of a work.
enum WorkLicence {
  /// Apache-2.0.
  apache('apache-2.0'),

  /// Business Source License 1.1: source-available, open use.
  busl('busl-1.1');

  new(this.id);

  /// The value in the data file.
  final String id;
}

/// What a work is. A contract work links its source code once public.
enum WorkKind {
  /// Smart contracts (or the SDK around deployed ones).
  contract,

  /// An app.
  app,
}

/// The links a work can carry, in the order the facts list shows them.
enum WorkLink {
  /// The work's repository.
  source,

  /// Documentation.
  docs,

  /// The repository's `SECURITY.md`.
  security,

  /// An audit report.
  audit,

  /// Release notes.
  release,

  /// Where to open an app.
  app,
}

/// An image of a work, self-hosted under `/img/`.
typedef WorkImage = ({String src, int width, int height, Localized alt});

/// The funder of a grant-funded work.
typedef Funder = ({String programme, String funder});

final _slug = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');

/// One work.
class Work {
  /// Creates a work from already-validated parts; data files go through
  /// [Work.fromJson].
  const new({
    required this.number,
    required this.name,
    required this.slug,
    required this.kind,
    required this.line,
    required this.status,
    this.nameEn,
    this.nameNote,
    this.about,
    this.notice,
    this.chains = const [],
    this.licence,
    this.changeDate,
    this.charges = false,
    this.fee,
    this.funder,
    this.links = const {},
    this.licensorConfirmed = false,
    this.images = const [],
  });

  /// Parses and validates the data file [file] (its decoded JSON). Throws a
  /// [FormatException] naming the file and the field.
  factory fromJson(Map<String, Object?> json, {required String file}) =>
      _parseWork(json, file);

  /// The catalogue number, in the order of publication; the newest work has
  /// the highest.
  final int number;

  /// The name, in German and (unless [nameEn] says otherwise) in English.
  final String name;

  /// The English name where it differs.
  final String? nameEn;

  /// A note beside the name ("working title").
  final Localized? nameNote;

  /// The path segment of the work's page.
  final String slug;

  /// Contract or app.
  final WorkKind kind;

  /// The one-liner. May carry `code` spans.
  final Localized line;

  /// The longer description.
  final Localized? about;

  /// A notice shown under the description.
  final Localized? notice;

  /// How far the work is.
  final WorkStatus status;

  /// The chains a deployed work runs on.
  final List<String> chains;

  /// The licence, if decided.
  final WorkLicence? licence;

  /// When a BUSL work turns Apache-2.0.
  final Localized? changeDate;

  /// Whether the work charges a fee; a deployed work that does carries [fee].
  final bool charges;

  /// The fee, as a row under the licence.
  final Localized? fee;

  /// Who funds the work, if a grant does.
  final Funder? funder;

  /// The links, by kind; each an `https` URL of the work's own.
  final Map<WorkLink, String> links;

  /// Whether the grant of rights to the company is signed (shows the licensor
  /// line).
  final bool licensorConfirmed;

  /// The images.
  final List<WorkImage> images;

  /// The name in [lang].
  String nameIn(Lang lang) => lang == Lang.en ? nameEn ?? name : name;
}

/// Parses and validates the data file [file] (see [Work.fromJson]).
Work _parseWork(Map<String, Object?> json, String file) {
  Never fail(String field, String why) =>
      throw FormatException('$file: $field $why');

  const known = {
    'number', 'name', 'nameEn', 'nameNote', 'slug', 'kind', 'line', 'about',
    'notice', 'status', 'chains', 'licence', 'changeDate', 'charges', 'fee',
    'funder', 'links', 'licensorConfirmed', 'images', //
  };
  for (final key in json.keys) {
    if (!known.contains(key)) fail(key, 'is not a field of a work');
  }

  String text(String field, {bool required = true}) {
    final v = json[field];
    if (v == null && !required) return '';
    if (v is! String || v.trim().isEmpty) fail(field, 'must be a text');
    return v;
  }

  Localized? localized(String field, {bool required = false}) {
    final v = json[field];
    if (v == null) {
      if (required) fail(field, 'is required');
      return null;
    }
    if (v is! Map) fail(field, 'must hold "de" and "en"');
    final out = <Lang, String>{};
    for (final lang in Lang.values) {
      final t = v[lang.code];
      if (t is! String || t.trim().isEmpty) {
        fail('$field.${lang.code}', 'must be a text');
      }
      out[lang] = t;
    }
    if (v.length != Lang.values.length) {
      fail(field, 'holds more than "de" and "en"');
    }
    return out;
  }

  final number = json['number'];
  if (number is! int || number < 1) fail('number', 'must be a number >= 1');
  final name = text('name');
  final slug = text('slug');
  if (!_slug.hasMatch(slug)) fail('slug', 'must be lower-case words and "-"');
  final kind = switch (json['kind']) {
    null || 'contract' => WorkKind.contract,
    'app' => WorkKind.app,
    _ => fail('kind', 'must be "contract" or "app"'),
  };
  final statusValue = json['status'];
  final status = WorkStatus.values
      .where((s) => s.id == statusValue)
      .firstOrNull;
  if (status == null) {
    fail(
      'status',
      'must be one of ${[for (final s in WorkStatus.values) s.id]}',
    );
  }
  final licenceValue = json['licence'];
  final licence = licenceValue == null
      ? null
      : WorkLicence.values.where((l) => l.id == licenceValue).firstOrNull ??
            fail(
              'licence',
              'must be one of ${[for (final l in WorkLicence.values) l.id]}',
            );

  final chainsValue = json['chains'];
  final chains = <String>[];
  if (chainsValue != null) {
    if (chainsValue is! List) fail('chains', 'must be a list');
    for (final c in chainsValue) {
      if (c is! String || c.trim().isEmpty) fail('chains', 'holds a non-text');
      chains.add(c);
    }
  }

  final linksValue = json['links'];
  final links = <WorkLink, String>{};
  if (linksValue != null) {
    if (linksValue is! Map) fail('links', 'must be an object');
    for (final e in linksValue.entries) {
      final kindOfLink = WorkLink.values
          .where((l) => l.name == e.key)
          .firstOrNull;
      if (kindOfLink == null) {
        fail('links.${e.key}', 'is not a link of a work');
      }
      final url = e.value;
      final uri = url is String ? Uri.tryParse(url) : null;
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty ||
          (url! as String).contains(' ')) {
        fail('links.${e.key}', 'must be an https URL');
      }
      links[kindOfLink] = url! as String;
    }
  }

  final imagesValue = json['images'];
  final images = <WorkImage>[];
  if (imagesValue != null) {
    if (imagesValue is! List) fail('images', 'must be a list');
    for (final (i, image) in imagesValue.indexed) {
      if (image is! Map) fail('images[$i]', 'must be an object');
      final src = image['src'];
      if (src is! String || !src.startsWith('/img/') || src.contains('..')) {
        fail('images[$i].src', 'must be a path under /img/ (self-hosted)');
      }
      final width = image['width'];
      final height = image['height'];
      if (width is! int || height is! int || width < 1 || height < 1) {
        fail('images[$i]', 'needs integer width and height');
      }
      final alt = <Lang, String>{};
      final altValue = image['alt'];
      for (final lang in Lang.values) {
        final t = altValue is Map ? altValue[lang.code] : null;
        if (t is! String || t.trim().isEmpty) {
          fail('images[$i].alt.${lang.code}', 'must be a text');
        }
        alt[lang] = t;
      }
      images.add((src: src, width: width, height: height, alt: alt));
    }
  }

  Funder? funder;
  final funderValue = json['funder'];
  if (funderValue != null) {
    final p = funderValue is Map ? funderValue['programme'] : null;
    final f = funderValue is Map ? funderValue['funder'] : null;
    if (p is! String || p.isEmpty || f is! String || f.isEmpty) {
      fail('funder', 'needs "programme" and "funder"');
    }
    funder = (programme: p, funder: f);
  }

  final charges = json['charges'] ?? false;
  if (charges is! bool) fail('charges', 'must be true or false');
  final confirmed = json['licensorConfirmed'] ?? false;
  if (confirmed is! bool) fail('licensorConfirmed', 'must be true or false');

  final line = localized('line', required: true)!;
  final about = localized('about');
  final notice = localized('notice');
  final changeDate = localized('changeDate');
  final fee = localized('fee');
  final nameNote = localized('nameNote');
  final nameEnValue = json['nameEn'];
  if (nameEnValue != null && (nameEnValue is! String || nameEnValue.isEmpty)) {
    fail('nameEn', 'must be a text');
  }

  // The rules of the compliance unit.
  final shown = status != WorkStatus.inDevelopment;
  if (kind == WorkKind.contract && shown && links[WorkLink.source] == null) {
    fail('links.source', 'is required for a contract work that is public');
  }
  if (kind == WorkKind.contract && shown && licence == null) {
    fail('licence', 'is required for a contract work that is public');
  }
  if (status == WorkStatus.deployed) {
    if (kind == WorkKind.contract && chains.isEmpty) {
      fail('chains', 'must name the chains of a deployed contract work');
    }
    if (kind == WorkKind.app && links[WorkLink.app] == null) {
      fail('links.app', 'is required for a deployed app');
    }
    if (charges && (fee == null || fee.values.any(_hasPlaceholder))) {
      fail(
        'fee',
        'must be set, without placeholders, for a deployed work '
            'that charges',
      );
    }
  }
  if (fee != null && !charges) {
    fail('fee', 'is set but "charges" is not true');
  }
  if (fee != null && licence == null) {
    fail('fee', 'sits under the licence row: set the licence');
  }
  if (changeDate != null && licence != WorkLicence.busl) {
    fail('changeDate', 'belongs to a BUSL 1.1 work only');
  }
  if (licence == WorkLicence.busl && shown && changeDate == null) {
    fail('changeDate', 'is required for a BUSL 1.1 work that is public');
  }
  if (licence == WorkLicence.busl) {
    // Decision 54 / DEC-079: BUSL is source-available, never "open source".
    final all = <String>[
      ...line.values,
      ...?about?.values,
      ...?notice?.values,
      ...?fee?.values,
    ];
    if (all.any(_openSource.hasMatch)) {
      fail('licence', 'is BUSL 1.1: the texts must not say "open source"');
    }
  }

  // MF-8 / C-13: a notice that disclaims the price providers keeps the whole
  // notice, so the studio's "fixed once deployed" lines stay true of the
  // oracle: the oracle is immutable, the feeds it reads are not, the consumer
  // bears the price risk.
  final disclaimer = notice;
  if (disclaimer != null) {
    for (final MapEntry(:key, :value) in disclaimer.entries) {
      final markers = _mf8[key]!;
      if (_providers.hasMatch(value) && !markers.every(value.contains)) {
        fail(
          'notice',
          'names Chainlink or RedStone: it must keep all three sentences of '
              'the notice (${key.code} needs ${markers.join(', ')})',
        );
      }
    }
  }

  return Work(
    number: number,
    name: name,
    nameEn: nameEnValue as String?,
    nameNote: nameNote,
    slug: slug,
    kind: kind,
    line: line,
    about: about,
    notice: notice,
    status: status,
    chains: chains,
    licence: licence,
    changeDate: changeDate,
    charges: charges,
    fee: fee,
    funder: funder,
    links: links,
    licensorConfirmed: confirmed,
    images: images,
  );
}

final _providers = RegExp('Chainlink|RedStone');

/// What the whole notice of a work that disclaims the price providers says,
/// per language (the three sentences of MF-8 and MF-16).
const Map<Lang, List<String>> _mf8 = {
  Lang.de: ['ist unveränderlich', 'updatedAt', 'Preisrisiko'],
  Lang.en: ['is immutable', 'updatedAt', 'price risk'],
};

bool _hasPlaceholder(String s) => s.contains('{') || s.contains('}');

final _openSource = RegExp('open[ -]source|quelloffen', caseSensitive: false);
