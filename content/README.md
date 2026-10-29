# Content

What the site shows that lives in data files, not in code. `lib/src/content/` reads it, the route
table, the sitemap and every check derive from it, and a file that would render something the page
cannot back fails the build instead of rendering. This directory is page copy: all rights reserved
(see `NOTICE`).

**Nothing renders without a file.** With no post in `posts/` there is no "Blog" item in the header, no
`/blog/` or `/en/blog/` page (the path answers with the 404 page), no sitemap entry and no "Blog" row in
the fact sheet on Home. The works are gone (brand decision 59): the catalogue lives at wearenotabank, and
Home is the business card.

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
