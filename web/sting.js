/* SPDX-License-Identifier: Apache-2.0 */
/* Home page: plays the mark sting inside the offer card when a visitor arrives
   from outside the site (a direct load, an external link or an empty
   referrer) or reloads the page, once the card is in view and has faded in.
   Loaded in <head> on the home pages. Without JavaScript, with reduced motion,
   or when the visitor came from a page of this site, the card shows the still
   mark. Stores nothing. */
(function () {
  'use strict';
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  // A reload keeps the original referrer but is an arrival, not navigation.
  var reloaded = false;
  try {
    var nav = performance.getEntriesByType('navigation')[0];
    reloaded = !!nav && nav.type === 'reload';
  } catch (e) {
    // No navigation timing: judge by the referrer alone.
  }

  // Arriving from another page of this site: the still, no replay.
  if (document.referrer && !reloaded) {
    try {
      if (new URL(document.referrer).origin === window.location.origin) return;
    } catch (e) {
      // An unparseable referrer counts as none: play.
    }
  }

  // Armed: the mark waits undrawn for its start (see .ledger-mark in site.css).
  document.documentElement.classList.add('sting-play');

  document.addEventListener('DOMContentLoaded', function () {
    var mark = document.querySelector('.ledger-mark .cas-mark');
    if (!mark) return;
    function play() {
      mark.classList.add('is-playing');
    }
    if (!('IntersectionObserver' in window)) return play();

    var observer = new IntersectionObserver(
      function (entries) {
        if (!entries.some(function (e) { return e.isIntersecting; })) return;
        observer.disconnect();
        // Start after the card's fade-in, whenever that finished.
        var card = mark.closest('.ledger');
        var rises = card && card.getAnimations ? card.getAnimations() : [];
        Promise.all(rises.map(function (a) { return a.finished; })).then(
          play,
          play
        );
      },
      { threshold: 0.6 }
    );
    observer.observe(mark);
  });
})();
