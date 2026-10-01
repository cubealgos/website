/* SPDX-License-Identifier: Apache-2.0 */
/* Plays the logo sting once per session on the home page hero. Loaded only on
   the home pages, in <head>. Without JavaScript, or with reduced motion, or on
   a return to home in the same session, the hero shows the still. */
(function () {
  'use strict';
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  var seen = false;
  try {
    seen = window.sessionStorage.getItem('sting-seen') === '1';
    window.sessionStorage.setItem('sting-seen', '1');
  } catch (e) {
    // Storage is blocked: play once per page load.
  }
  if (seen) return;

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
