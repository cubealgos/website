/* SPDX-License-Identifier: Apache-2.0 */
/* Plays the logo sting on the home page hero when a visitor arrives: a direct
   load, an external link or an empty referrer. Loaded only on the home pages,
   in <head>. Without JavaScript, with reduced motion, or when the referrer is
   a page of this site, the hero shows the still. Stores nothing. */
(function () {
  'use strict';
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  // Arriving from another page of this site: the still, no replay.
  if (document.referrer) {
    try {
      if (new URL(document.referrer).origin === window.location.origin) return;
    } catch (e) {
      // An unparseable referrer counts as none: play.
    }
  }

  var root = document.documentElement;
  root.classList.add('sting-play');

  document.addEventListener('DOMContentLoaded', function () {
    var box = document.querySelector('[data-sting]');
    if (!box) return;
    var theme = root.getAttribute('data-theme');
    var dark = theme
      ? theme === 'dark'
      : window.matchMedia('(prefers-color-scheme: dark)').matches;
    var img = document.createElement('img');
    img.className = 'sting-anim';
    img.alt = '';
    img.width = 325;
    img.height = 120;
    // Paper background in light, ink in dark.
    img.src = '/brand/sting/sting-' + (dark ? 'ink' : 'paper') + '.svg';
    box.appendChild(img);
  });
})();
