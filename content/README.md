# Content

What the site shows that lives in data files, not in code. `lib/src/content/` reads it, the route
table, the sitemap and every check derive from it, and a file that would render something the page
cannot back fails the build instead of rendering. This directory is page copy: all rights reserved
(see `NOTICE`).

**Nothing renders without a file.** With no work in `works/` there is no works section on Home, no
"Arbeiten" / "Work" item in the header or the footer, no `/arbeiten/` or `/en/work/` page (the path
answers with the 404 page), no sitemap entry, and the hero button reads "Mehr erfahren" /
"Learn more". The same holds for `posts/` and the blog. The home page's claim that the studio's contracts are published with their source (the hero's second sentence and the studio item about readable code) renders only while at least one work has a `links.source` URL.

## A work: `works/<number>-<slug>.json`

One JSON file per work, validated by `lib/src/content/work.dart`. Fields (both languages are
`{"de": "...", "en": "..."}`):

| field | |
| --- | --- |
| `number` | Required. The catalogue number, in the order of publication; works are shown newest (highest) first. |
| `name`, `nameEn` | Required name; `nameEn` where the English name differs. `nameNote`: a note beside it ("working title"). |
| `slug` | Required. Lower-case words and `-`; the page is `/arbeiten/<slug>/` and `/en/work/<slug>/`. |
| `kind` | `contract` (default) or `app`. |
| `line` | Required one-liner, both languages; `` `code` `` spans are allowed. Also the page's meta description. |
| `about`, `notice` | Optional description and notice, both languages. |
| `status` | `in-development`, `public` (source published, nothing deployed) or `deployed`. |
| `chains` | The chains of a deployed contract work (required then). |
| `licence` | `apache-2.0` or `busl-1.1` (required for a contract work that is `public` or `deployed`). |
| `changeDate` | When a BUSL 1.1 work turns Apache-2.0 (required for a public BUSL work; both languages). |
| `charges`, `fee` | `charges: true` for a work that takes a fee. `fee` is the text after "Gebühr · " / "Fee · " and renders under the licence; a deployed work that charges needs a `fee` without `{placeholders}`. |
| `funder` | `{"programme": "...", "funder": "..."}` for a grant-funded work: renders "Gefördert von {funder} im Programm {programme}." |
| `licensorConfirmed` | `true` once the grant of rights to the company is signed: renders the licensor line. |
| `links` | `source`, `docs`, `security`, `audit`, `release`, `app`: `https` URLs, the work's own (`source` is its repository URL; required for a public contract work). They are plain links, listed in the build's outbound allow-list. |
| `images` | `{"src": "/img/...", "width", "height", "alt": {"de", "en"}}`, self-hosted under `web/img/`. The first is the work's plate; the rest follow as a gallery. Without an image the plate is a cover generated from the slug (decorative, no alt text). |

Rules the loader enforces: a BUSL work never says "open source" (source-available, open use); a fee
needs `charges` and a licence; every text in both languages; no unknown field. The copy of each
row (labels, status and licence texts) is in `lib/src/copy/works_copy.dart`.

## A post: `posts/<slug>.<lang>.md`

A front matter block, then the title as `# ` and the body:

````
---
id: shared-by-the-translations
slug: the-path-segment
lang: de
date: 2026-10-14
seoTitle: The title without " | Cube Algos"
description: The meta description, also shown in lists.
---

# The H1

The lede, a paragraph.

## A heading

Text with `code`, **bold** and [a link](https://example.org/).

- a list
- of items

```
a code block, scrolls inside itself
```
````

`id` ties the translations of one post together (a post may exist in one language only; the index
marks it). The body supports `##` headings (the contents list), paragraphs, `-` lists, fenced code
blocks and `code`, `**bold**`, `[label](url)`; anything else fails the build with the line number.
A link is a root-absolute path, a `mailto:` or an `https` URL. No images, embeds or HTML.
