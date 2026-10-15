// SPDX-License-Identifier: Apache-2.0

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:website/src/content/markdown.dart';
import 'package:website/src/content/site_content.dart';
import 'package:website/src/content/work.dart';
import 'package:website/src/copy/home_copy.dart';
import 'package:website/src/copy/works_copy.dart';
import 'package:website/src/page_meta.dart';
import 'package:website/src/pages/work_widgets.dart';
import 'package:website/src/routes.dart';
import 'package:website/src/widgets.dart';

/// The index of the works: every work as a room, newest first. Built only
/// when there is a work.
class WorksIndexPage extends StatelessComponent {
  /// Creates the index in [lang] over [content].
  const new({required this.lang, required this.content, super.key});

  /// The page's language.
  final Lang lang;

  /// The works of the site.
  final SiteContent content;

  @override
  Component build(BuildContext context) {
    final meta = pageMeta[PageKey.works]![lang]!;
    return Component.fragment([
      el('section', classes: 'hero hero--page', [
        el('div', classes: 'wrap hero-grid gridlines', [
          el('div', classes: 'hero-text', [
            h1(classes: 'hero-h1 rise', [t(meta.h1)]),
            p(
              classes: 'hero-sub rise',
              attributes: const {'data-i': '1'},
              [t(homeCopy[lang]!.workIntro)],
            ),
          ]),
        ]),
      ]),
      div(classes: 'works works--c works--index', [
        for (final (i, work) in content.works.indexed)
          Room(work: work, lang: lang, odd: i.isEven, level: 2),
      ]),
    ]);
  }
}

/// The page of one work: its room (name, one-liner, plate), the description
/// and notices beside the facts card.
///
/// A row of the facts is rendered only under the condition the data file
/// states: the chains of a deployed contract, the licence when decided, the
/// fee when the work has one, the licensor line when the grant of rights is
/// signed, the funder line for a grant-funded work.
class WorkPage extends StatelessComponent {
  /// Creates the page of [work] in [lang].
  const new({required this.lang, required this.work, super.key});

  /// The page's language.
  final Lang lang;

  /// The work.
  final Work work;

  @override
  Component build(BuildContext context) {
    final c = worksCopy[lang]!;
    return Component.fragment([
      el('section', classes: 'work-room', [
        div(classes: 'wrap', [
          BackLink(label: c.back, href: pathFor(PageKey.works, lang)),
          div(classes: 'room-grid', [
            div(classes: 'work-head', [
              h1(classes: 'hero-h1 work-h1 rise', workName(work, lang)),
              p(
                classes: 'hero-sub work-lede rise',
                attributes: const {'data-i': '1'},
                inlineComponents(parseInline(work.line[lang]!)),
              ),
            ]),
            Plate(work: work, lang: lang),
          ]),
        ]),
      ]),
      el('section', classes: 'sec sec--first', [
        div(classes: 'wrap work-grid', [
          div(classes: 'work-main', [
            if (work.about?[lang] case final about?)
              el(
                'section',
                classes: 'work-about',
                attrs: const {'aria-labelledby': 'about-title'},
                [
                  h2(id: 'about-title', [t(c.aboutTitle)]),
                  p(inlineComponents(parseInline(about))),
                ],
              ),
            if (work.notice?[lang] case final notice?)
              p(classes: 'work-notice', inlineComponents(parseInline(notice))),
            if (work.funder case final funder?)
              p(classes: 'work-funder', [
                t(
                  c.funderLine
                      .replaceAll('{funder}', funder.funder)
                      .replaceAll('{programme}', funder.programme),
                ),
              ]),
            if (work.images.length > 1) _gallery(c),
            p(classes: 'work-closing', [t(c.closing)]),
            if (work.licensorConfirmed) p(classes: 'note', [t(c.licensorLine)]),
          ]),
          div(classes: 'work-side', [_facts(c)]),
        ]),
      ]),
    ]);
  }

  /// The images after the first (which is the plate).
  Component _gallery(WorksCopy c) => el(
    'section',
    attrs: const {'aria-labelledby': 'images-title'},
    [
      h2(id: 'images-title', classes: 'vh', [t(c.imagesTitle)]),
      ul(classes: 'work-images', [
        for (final image in work.images.skip(1))
          li([
            img(
              src: image.src,
              alt: image.alt[lang],
              width: image.width,
              height: image.height,
              attributes: const {'loading': 'lazy', 'decoding': 'async'},
            ),
          ]),
      ]),
    ],
  );

  Component _facts(WorksCopy c) {
    final status = statusText(work, lang);
    final licence = work.licence;
    return el(
      'section',
      classes: 'ledger facts-card',
      attrs: const {'aria-labelledby': 'facts-title'},
      [
        div(classes: 'ledger-head', [
          h2(id: 'facts-title', classes: 'ledger-label', [t(c.factsTitle)]),
          span(
            classes: 'placard-no',
            attributes: const {'aria-hidden': 'true'},
            [t(numberLabel(work))],
          ),
        ]),
        dl(classes: 'work-facts', [
          _row(c.statusLabel, [
            StatusBadge(work: work, lang: lang),
            if (status.explanation case final text?)
              span(classes: 'dd-note', [t(text)]),
          ]),
          if (work.chains.isNotEmpty)
            _row(c.chainsLabel, [
              ul(classes: 'chips', [
                for (final chain in work.chains) li([t(chain)]),
              ]),
            ]),
          if (licence != null)
            _row(c.licenceLabel, [
              span(classes: 'dd-strong', [t(c.licence[licence]!.long)]),
              if (licence == WorkLicence.busl)
                span(classes: 'dd-note', [t(c.busl)]),
              if (work.fee?[lang] case final fee?)
                span(classes: 'dd-strong dd-fee', [
                  t(c.feeRow.replaceAll('{fee}', fee)),
                ]),
            ]),
          if (work.changeDate?[lang] case final date?)
            _row(c.changeDateLabel, [
              span(classes: 'dd-strong', [t(date)]),
            ]),
          if (work.links.isNotEmpty)
            _row(c.linksLabel, [
              ul(classes: 'work-links', [
                for (final kind in WorkLink.values)
                  if (work.links[kind] case final url?)
                    li([
                      a(
                        [t(c.links[kind]!)],
                        href: url,
                        attributes: const {'rel': 'noreferrer'},
                      ),
                    ]),
              ]),
            ]),
        ]),
      ],
    );
  }

  Component _row(String label, List<Component> value) => div([
    dt([t(label)]),
    dd(value),
  ]);
}
