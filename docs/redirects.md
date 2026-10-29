# Redirects

About folded into Home (brand decision 59): `/ueber/` and `/en/about/` lead to the home page of their language
(`/` and `/en/`). The site is static files, so the repository can build a redirect page; only the server can answer a
real `301`.

## What the repository does

`lib/src/redirects.dart` lists the retired pages, and `tool/build.dart` writes a page at each path
(`build/jaspr/ueber/index.html`, `build/jaspr/en/about/index.html`). Each page:

- redirects the browser at once: `<meta http-equiv="refresh" content="0; url=/">` (an instant refresh, which Google
  treats as a permanent redirect; it is allowed by the site's CSP, which has no `navigate-to`);
- names the home page as `rel="canonical"` and is `noindex`, so a search engine moves its index entry to Home;
- carries a link to Home for a browser that does not follow the refresh (the same label as the 404 page's button);
- loads only same-origin files, no script and no inline CSS.

They are no routes: no sitemap entry, no navigation item, and nothing on the site links to them. `html-check` holds
them to these rules and `browser_check` opens each and checks that it ends on the home page of its language
(`test/built_output_test.dart` and `test/tool/html_check_test.dart` pin the same).

## What the server must add for a true 301

`cubealgos_server` serves the site with Caddy (`services/website/Caddyfile`), behind Traefik. A refresh page answers
`200`. For a `301`, add the rules to the `:8080` block (cubealgos.de) only, not to the `(static_site)` snippet, which
kevinscheeren.de shares:

```caddyfile
:8080 {
	redir /ueber /       301
	redir /ueber/ /      301
	redir /en/about /en/ 301
	redir /en/about/ /en/ 301
	import static_site /srv/current
}
```

(`redir` runs before `file_server`, so the order inside the block does not matter.) Once the rules are live the
redirect pages are never served; they stay in the build as the fallback for a server without the rules. Check with
`curl -sI https://cubealgos.de/ueber/` (`HTTP/2 301`, `location: /`).

To retire another page, add a `Redirect` to `redirects` and a line to the server.
