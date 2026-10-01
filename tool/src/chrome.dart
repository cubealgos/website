// SPDX-License-Identifier: Apache-2.0

/// A minimal Chrome DevTools Protocol client over `dart:io`: launches the
/// system Chrome headless and drives one page. No dependencies.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// The Chrome binary: `$CHROME`, else `google-chrome` on PATH (the
/// ubuntu-24.04 runner), else the macOS app.
String chromeBinary() {
  final env = Platform.environment['CHROME'];
  if (env != null && env.isNotEmpty) return env;
  const mac = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
  if (File(mac).existsSync()) return mac;
  return 'google-chrome';
}

/// A running headless Chrome.
class Chrome {
  new _(this._process, this._socket, this._profile) {
    _socket.listen((raw) {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final id = msg['id'];
      if (id is int) {
        final c = _pending.remove(id);
        if (msg['error'] != null) {
          c?.completeError(StateError('CDP ${msg['error']}'));
        } else {
          c?.complete((msg['result'] as Map<String, dynamic>?) ?? {});
        }
      } else {
        _events.add(msg);
      }
    });
  }

  final Process _process;
  final WebSocket _socket;
  final Directory _profile;
  final _pending = <int, Completer<Map<String, dynamic>>>{};
  final _events = StreamController<Map<String, dynamic>>.broadcast();
  var _nextId = 0;

  /// Launches Chrome headless with [args] (e.g.
  /// `--force-prefers-reduced-motion`).
  static Future<Chrome> launch({List<String> args = const []}) async {
    final profile = Directory.systemTemp.createTempSync('chrome_profile_');
    final process = await Process.start(chromeBinary(), [
      '--headless=new',
      '--disable-gpu',
      '--no-sandbox',
      '--hide-scrollbars',
      '--no-first-run',
      '--no-default-browser-check',
      '--remote-debugging-port=0',
      '--user-data-dir=${profile.path}',
      ...args,
      'about:blank',
    ]);
    final ws = Completer<String>();
    process.stderr.transform(utf8.decoder).listen((chunk) {
      final m = RegExp(r'DevTools listening on (ws://\S+)').firstMatch(chunk);
      if (m != null && !ws.isCompleted) ws.complete(m[1]);
    });
    unawaited(process.stdout.drain<void>());
    final url = await ws.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw StateError('Chrome did not start'),
    );
    return Chrome._(process, await WebSocket.connect(url), profile);
  }

  /// Sends a CDP [method].
  Future<Map<String, dynamic>> send(
    String method, [
    Map<String, Object?> params = const {},
    String? sessionId,
  ]) {
    final id = ++_nextId;
    final c = _pending[id] = Completer();
    _socket.add(
      jsonEncode({
        'id': id,
        'method': method,
        'params': params,
        'sessionId': ?sessionId,
      }),
    );
    return c.future.timeout(const Duration(seconds: 30));
  }

  /// Opens a fresh page (tab).
  Future<ChromePage> newPage() async {
    final target = await send('Target.createTarget', {'url': 'about:blank'});
    final attached = await send('Target.attachToTarget', {
      'targetId': target['targetId'],
      'flatten': true,
    });
    final session = attached['sessionId']! as String;
    final page = ChromePage._(this, session);
    await page.send('Page.enable');
    await page.send('Runtime.enable');
    await page.send('Emulation.setFocusEmulationEnabled', {'enabled': true});
    return page;
  }

  /// Shuts Chrome down and removes its profile.
  Future<void> close() async {
    await _socket.close();
    _process.kill();
    await _process.exitCode;
    try {
      _profile.deleteSync(recursive: true);
    } on FileSystemException {
      // The profile is a temp dir; a leftover is harmless.
    }
  }
}

/// One Chrome tab.
class ChromePage {
  new _(this._chrome, this._session);

  final Chrome _chrome;
  final String _session;

  /// Sends a CDP [method] to this page.
  Future<Map<String, dynamic>> send(
    String method, [
    Map<String, Object?> params = const {},
  ]) => _chrome.send(method, params, _session);

  /// Sets the viewport to [width] x [height] CSS pixels.
  Future<void> setViewport(int width, int height) => send(
    'Emulation.setDeviceMetricsOverride',
    {'width': width, 'height': height, 'deviceScaleFactor': 1, 'mobile': false},
  );

  /// Emulates `prefers-color-scheme` and `prefers-reduced-motion`.
  Future<void> setMedia({bool dark = false, bool reducedMotion = false}) =>
      send('Emulation.setEmulatedMedia', {
        'features': [
          {'name': 'prefers-color-scheme', 'value': dark ? 'dark' : 'light'},
          {
            'name': 'prefers-reduced-motion',
            'value': reducedMotion ? 'reduce' : 'no-preference',
          },
        ],
      });

  /// Navigates to [url] and waits for the load event.
  Future<void> goto(String url) async {
    final loaded = _chrome._events.stream
        .firstWhere(
          (e) =>
              e['sessionId'] == _session &&
              e['method'] == 'Page.loadEventFired',
        )
        .timeout(const Duration(seconds: 30));
    await send('Page.navigate', {'url': url});
    await loaded;
  }

  /// Waits for the next load event (after a click that navigates).
  Future<void> waitForLoad() => _chrome._events.stream
      .firstWhere(
        (e) =>
            e['sessionId'] == _session && e['method'] == 'Page.loadEventFired',
      )
      .timeout(const Duration(seconds: 30));

  /// Evaluates [expression] (awaiting promises) and returns its JSON value.
  Future<Object?> eval(String expression) async {
    final r = await send('Runtime.evaluate', {
      'expression': expression,
      'returnByValue': true,
      'awaitPromise': true,
    });
    if (r['exceptionDetails'] != null) {
      throw StateError('eval failed: ${r['exceptionDetails']}');
    }
    return (r['result']! as Map<String, dynamic>)['value'];
  }

  /// Like [eval], for an expression that returns an object.
  Future<Map<String, dynamic>> evalMap(String expression) async =>
      (await eval(expression))! as Map<String, dynamic>;

  /// Presses and releases [key] (`Tab`, `Enter`, ...).
  Future<void> press(String key, {bool shift = false}) async {
    const codes = {'Tab': 9, 'Enter': 13};
    for (final type in ['keyDown', 'keyUp']) {
      await send('Input.dispatchKeyEvent', {
        'type': type,
        'key': key,
        'code': key,
        'windowsVirtualKeyCode': codes[key],
        'modifiers': shift ? 8 : 0,
        if (key == 'Enter' && type == 'keyDown') 'text': '\r',
      });
    }
  }

  /// Saves a full-page PNG screenshot to [path].
  Future<void> screenshot(String path) async {
    final m = await send('Page.getLayoutMetrics');
    final size = m['cssContentSize']! as Map<String, dynamic>;
    final shot = await send('Page.captureScreenshot', {
      'format': 'png',
      'captureBeyondViewport': true,
      'clip': {
        'x': 0,
        'y': 0,
        'width': size['width'],
        'height': size['height'],
        'scale': 1,
      },
    });
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(base64Decode(shot['data']! as String));
  }
}
