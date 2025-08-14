import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'package:js/js_util.dart' as js_util;
import 'dart:ui_web' as ui_web;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class BarcodeScannerPocWeb {
  static void registerWith(Registrar registrar) {}
}

void _injectBarcodeScannerJs() {
  const html5QrcodeId = 'html5-qrcode-js';
  const scannerId = 'barcode-scanner-js';

  final doc = web.window.document;
  if (doc.getElementById(scannerId) != null) return;

  if (doc.getElementById(html5QrcodeId) != null) {
    final scannerScript = doc.createElement('script') as web.HTMLScriptElement;
    scannerScript.id = scannerId;
    scannerScript.type = 'application/javascript';
    scannerScript.src =
        'assets/packages/barcode_scanner_poc/lib/web/barcode_scanner.js';
    doc.body!.appendChild(scannerScript);
    return;
  }

  final html5QrcodeScript =
      doc.createElement('script') as web.HTMLScriptElement;
  html5QrcodeScript.id = html5QrcodeId;
  html5QrcodeScript.type = 'application/javascript';
  html5QrcodeScript.defer = true;
  html5QrcodeScript.src =
      'https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js';
  html5QrcodeScript.onLoad.listen((event) {
    final scannerScript = doc.createElement('script') as web.HTMLScriptElement;
    scannerScript.id = scannerId;
    scannerScript.type = 'application/javascript';
    scannerScript.src =
        'assets/packages/barcode_scanner_poc/lib/web/barcode_scanner.js';
    doc.body!.appendChild(scannerScript);
  });
  doc.body!.appendChild(html5QrcodeScript);
}

@JS('startHtml5Qrcode')
external void startHtml5Qrcode(
  JSString elementId,
  JSFunction onScan,
  JSFunction onError, [
  JSAny? config,
]);

class BarcodeScannerPocWebOptions {
  final int? width;
  final int? height;
  final int fps;
  final int qrbox;
  final String? focusMode;
  final Map<String, dynamic>? extraOptions;

  const BarcodeScannerPocWebOptions({
    this.width,
    this.height,
    this.fps = 10,
    this.qrbox = 250,
    this.focusMode,
    this.extraOptions,
  });

  Map<String, dynamic> toWebConfig() {
    final videoConstraints = <String, dynamic>{};
    if (width != null) videoConstraints['width'] = {'ideal': width};
    if (height != null) videoConstraints['height'] = {'ideal': height};
    if (focusMode != null) videoConstraints['focusMode'] = focusMode;

    final options = {
      'fps': fps,
      'qrbox': qrbox,
      'videoConstraints': videoConstraints,
      ...?extraOptions,
    };
    return {
      'cameraConfig': {'facingMode': 'environment'},
      'options': options,
    };
  }
}

class BarcodeScannerPocWebWidget extends StatefulWidget {
  final void Function(String code) onScan;
  final BarcodeScannerPocWebOptions? web;
  const BarcodeScannerPocWebWidget({required this.onScan, this.web, super.key});

  @override
  State<BarcodeScannerPocWebWidget> createState() =>
      _BarcodeScannerPocWebWidgetState();
}

class _BarcodeScannerPocWebWidgetState
    extends State<BarcodeScannerPocWebWidget> {
  final String _elementId = 'html5-qrcode-element';
  static bool _registered = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && !_registered) {
      ui_web.platformViewRegistry.registerViewFactory(_elementId, (int viewId) {
        final div =
            web.window.document.createElement('div') as web.HTMLDivElement;
        div.id = _elementId;
        return div;
      });
      _registered = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kIsWeb) {
        _injectBarcodeScannerJs();
        // Espera más tiempo y verifica que la función esté disponible
        Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 200));
          final hasFunction =
              (js_util.getProperty(js_util.globalThis, 'startHtml5Qrcode') !=
              null);
          return !hasFunction;
        }).then((_) {
          final webConfig = widget.web?.toWebConfig();
          final jsConfig = webConfig != null
              ? {'web': webConfig}.jsify()
              : null;
          startHtml5Qrcode(
            _elementId.toJS,
            ((JSString code) {
              widget.onScan(code.toDart);
            }).toJS,
            ((JSString error) {}).toJS,
            jsConfig,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _elementId);
  }
}
