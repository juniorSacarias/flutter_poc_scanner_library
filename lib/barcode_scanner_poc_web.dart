import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'dart:html' as html;
import 'dart:js_interop';
import 'package:js/js_util.dart' as js_util;
import 'dart:ui_web' as ui_web;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'barcode_scanner_poc_platform_interface.dart';

class BarcodeScannerPocWeb {
  static void registerWith(Registrar registrar) {}
}

void _injectBarcodeScannerJs() {
  const html5QrcodeId = 'html5-qrcode-js';
  const scannerId = 'barcode-scanner-js';

  if (html.document.getElementById(scannerId) != null) return;

  if (html.document.getElementById(html5QrcodeId) != null) {
    final scannerScript = html.ScriptElement()
      ..id = scannerId
      ..type = 'application/javascript'
      ..src = 'packages/barcode_scanner_poc/web/barcode_scanner.js';
    html.document.body!.append(scannerScript);
    return;
  }

  final html5QrcodeScript = html.ScriptElement()
    ..id = html5QrcodeId
    ..type = 'application/javascript'
    ..defer = true
    ..src = 'https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js';
  html5QrcodeScript.onLoad.listen((_) {
    final scannerScript = html.ScriptElement()
      ..id = scannerId
      ..type = 'application/javascript'
      ..src = 'packages/barcode_scanner_poc/web/barcode_scanner.js';
    html.document.body!.append(scannerScript);
  });
  html.document.body!.append(html5QrcodeScript);
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
      ui_web.platformViewRegistry.registerViewFactory(
        _elementId,
        (int viewId) => html.DivElement()..id = _elementId,
      );
      _registered = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kIsWeb) {
        _injectBarcodeScannerJs();
        Future.delayed(const Duration(milliseconds: 200), () {
          final webConfig = widget.web?.toWebConfig();
          final jsConfig = webConfig != null
              ? js_util.jsify({'web': webConfig}) as JSAny?
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
