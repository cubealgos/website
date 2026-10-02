/* SPDX-License-Identifier: Apache-2.0 */
/* Reveals headings and content blocks (.reveal) once, as they scroll into view:
   a short rise and fade, staggered within a group. Loaded in <head> on the home,
   about and contact pages. Without JavaScript, without IntersectionObserver or
   with reduced motion nothing is hidden. Stores nothing. */
(function () {
  'use strict';
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  if (!('IntersectionObserver' in window)) return;

  var root = document.documentElement;
  root.classList.add('reveal-on');

  document.addEventListener('DOMContentLoaded', function () {
    var observer = new IntersectionObserver(
      function (entries) {
        // Entries that arrive together (in view on load, or one scroll step)
        // are one group: a stagger of 0, 1, 2, ... capped at 5.
        var step = 0;
        entries.forEach(function (entry) {
          if (!entry.isIntersecting) return;
          observer.unobserve(entry.target);
          entry.target.style.setProperty('--i', Math.min(step, 5));
          entry.target.classList.add('is-in');
          step += 1;
        });
      },
      { threshold: 0.15 }
    );
    document.querySelectorAll('.reveal').forEach(function (el) {
      observer.observe(el);
    });
  });
})();
