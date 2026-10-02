// SPDX-License-Identifier: Apache-2.0

/// A tiny static file server over a built site, for the headless-browser
/// checks. Directory URLs serve `index.html`; unknown paths serve `404.html`
/// (`de/404.html` below `/de/`).
library;

import 'dart:io';

import 'package:path/path.dart' as p;

const _types = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.json': 'application/json',
  '.xml': 'application/xml',
  '.woff2': 'font/woff2',
  '.txt': 'text/plain; charset=utf-8',
};

/// Serves [root] on an ephemeral localhost port; close it with
/// `HttpServer.close(force: true)`.
Future<HttpServer> serveDirectory(String root) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    var path = Uri.decodeComponent(request.uri.path);
    if (path.endsWith('/')) path += 'index.html';
    var file = File(p.join(root, path.substring(1)));
    var status = HttpStatus.ok;
    if (!file.existsSync() || !p.isWithin(root, file.path)) {
      // German paths get the German 404 page, like the production server.
      file = File(
        p.join(
          root,
          path == '/de' || path.startsWith('/de/') ? 'de/404.html' : '404.html',
        ),
      );
      status = HttpStatus.notFound;
    }
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.parse(
        _types[p.extension(file.path)] ?? 'application/octet-stream',
      )
      ..add(await file.readAsBytes());
    await request.response.close();
  });
  return server;
}
