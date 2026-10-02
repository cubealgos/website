# Accessibility

The site is built to be accessible from the start (decision 21, Kevin, 2026-10-01). BFSG was
checked and ruled out for this B2B site, so **nothing on the site or in this document claims
legal conformance**; the copy says "from the start" (EN) and "barrierearm" (DE), and
`tool/a11y_check.dart` fails the build on a conformance claim in the page text (WCAG, BFSG,
"fully accessible", ...).

## Automated, every build (`a11y` workflow)

| check | what it covers | result, 2026-10-02 (Claude) |
| --- | --- | --- |
| Lighthouse accessibility audits (`tool/a11y/lighthouse_a11y.mjs`) | every built page (12), phone and desktop emulation, any failed audit fails | 24 runs, score 100 everywhere, no failed audit |
| `tool/a11y_check.dart` structure | one banner, main and contentinfo landmark, named navigation landmarks, nothing outside a landmark but the skip link, skip link first and leading to `<main>`, exactly one H1 inside `<main>`, no skipped heading level, `<html lang>` as the route table says, accessible name on every link, button and FAQ summary, no generic link text, alt text, inline SVG hidden or named, unique ids, no positive `tabindex`, no conformance claim in the text | 12 pages ok |
| `tool/a11y_check.dart` focus | Tab through every interactive element (skip link, navigation, language switches, buttons, FAQ summaries, footer links): document order, a solid 2px ring in the focus token, in view, not covered; light and dark | 464 stops ok |
| `tool/a11y_check.dart` contrast | rendered text against its effective background in the light and the dark theme, reduced motion on so reveals are at rest (4.5:1, 3:1 for large text); text over an image or gradient is counted, not judged | 1020 texts ok, 4 not judged |
| `tool/browser_check.dart` | no horizontal scroll or off-screen element at 320 / 375 / 768 / 1280 px (320 px is 400% zoom of a 1280 px window, 640 px is 200%), keyboard walkthrough of header and footer, language switch, reduced motion (sting still, UI motion off, reveals visible), content visible with JavaScript off | ok |
| Tokens contrast test (`test/tokens_contrast_test.dart`) | text and UI-boundary contrast of the brand tokens | ok |

Lighthouse (and its bundled `axe-core`, the org's recorded dev-scope MPL-2.0 exception) only
sees the light theme; the dark theme is covered by `a11y_check`'s contrast scan.

## Manual test matrix

A person does these; the browser, the assistive technology and the voices cannot be driven from
a script. Fill each cell with `pass` or `fail <issue link>`, and record date and tester in the
log below. **Every cell marked "pending: Kevin" is open on purpose and the matching acceptance
criterion in #17 stays unticked.** The "Auto" column is the result of the automated checks above
for that page, nothing else.

How to test:

- **Keyboard**: no mouse. Tab and Shift+Tab from the skip link to the footer: order follows the
  reading order, the focus ring is visible on every stop, no keyboard trap, the skip link moves
  focus into `<main>`, the language switch and the `mailto:` links are reachable and Enter opens
  them, FAQ items (Home) open and close with Enter and Space.
- **VoiceOver** (macOS, Safari, Control+Option): the landmarks (banner, navigations by name,
  main, contentinfo) are listed in the rotor; the headings rotor shows one H1 and an orderly
  outline; links read with a meaningful name; FAQ items are announced as disclosures with their
  expanded state; the idle fish is hidden or announced sensibly; the page language is announced
  and German pages are read with a German voice (`lang="de"`), English pages with an English
  one, the language switch links with their own language.
- **Zoom 200% and 400%** (browser zoom on a 1280 px wide window, Chrome and Safari): no loss of
  content or function, no horizontal scroll, text not clipped or overlapping.
- **Reduced motion** (System Settings, Accessibility, Display, Reduce motion): the home sting
  shows the still mark, no rise-in or press animation, all content visible without scrolling.
- **Forced colours** (Windows High Contrast, or Chrome DevTools, Rendering, Emulate
  `forced-colors: active`): text, focus ring, buttons, the FAQ markers and the logo stay
  visible; nothing relies on a background colour alone.

| Page | Lang | Path | Auto | Keyboard | VoiceOver | Zoom 200% | Zoom 400% | Reduced motion | Forced colours |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Home | DE | `/` | pass | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin |
| Home | EN | `/en/` | pass | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin |
| About | DE | `/ueber/` | pass | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin |
| About | EN | `/en/about/` | pass | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin |
| Contact | DE | `/kontakt/` | pass | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin |
| Contact | EN | `/en/contact/` | pass | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin |
| Impressum | DE | `/impressum/` | pass | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin |
| Impressum | EN | `/en/impressum/` | pass | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin |
| Datenschutz | DE | `/datenschutz/` | pass | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin |
| Datenschutz | EN | `/en/datenschutz/` | pass | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin |
| 404 | DE | `/404.html` | pass | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin |
| 404 | EN | `/en/404.html` | pass | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin | pending: Kevin |

### Log

| date | page / lang | check | result | tester |
| --- | --- | --- | --- | --- |
| 2026-10-02 | all 12 | Auto column (Lighthouse, `a11y_check`, `browser_check`) | pass | Claude (automated, no assistive technology used) |
| pending: Kevin | | | | |

## Manual criteria carried over from other issues

- [ ] pending: Kevin. (moved from #8) Keyboard-only walkthrough of header and footer on one EN
  and one DE page, in light and dark. `browser_check` and `a11y_check` automate the tab order
  and the ring.
- [ ] pending: Kevin. (moved from #9) Watch the home sting once in a real browser: it plays on
  the first home view, not again after About and back, plays again in a new session, and there
  is no motion with reduced motion on (automated in `browser_check`).
- [ ] pending: Kevin. Keyboard-only and VoiceOver run of Home (EN) and Home (DE) from the skip
  link to the footer, opening and closing every FAQ item, without a dead end.

## Findings

| finding | found by | resolution |
| --- | --- | --- |
| The header and the footer both carried a navigation landmark named "Sprache" / "Language", so a screen reader's landmark list showed two identical entries. | `a11y_check` structure | Fixed in #17: the footer's switch is named "Sprache wechseln" / "Switch language". |

No other automated finding is open. Findings from the manual runs go into this table; each is
fixed in the PR that finds it or filed as an issue and linked here.
