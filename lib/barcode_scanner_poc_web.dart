import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'dart:html' as html;
import 'dart:js_interop';
import 'package:js/js.dart' hide JS;
import 'package:js/js_util.dart' as js_util;
import 'dart:ui_web' as ui_web;

@JS('startHtml5Qrcode')
external void startHtml5Qrcode(
  JSString elementId,
  JSFunction onScan,
  JSFunction onError, [
  JSAny? config,
]);

/// Opciones específicas para la plataforma web (html5-qrcode)
class BarcodeScannerPocWebOptions {
  /// Ancho ideal del video (en píxeles)
  final int? width;

  /// Alto ideal del video (en píxeles)
  final int? height;

  /// FPS de la cámara (mínimo recomendado: 10)
  final int fps;

  /// Tamaño del cuadro de escaneo (en píxeles)
  final int qrbox;

  /// Modo de enfoque (por ejemplo, 'continuous')
  final String? focusMode;

  /// Otros parámetros avanzados
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
        Future.delayed(const Duration(milliseconds: 100), () {
          final webConfig = widget.web?.toWebConfig();
          final jsConfig = webConfig != null
              ? js_util.jsify({'web': webConfig}) as JSAny?
              : null;
          startHtml5Qrcode(
            _elementId.toJS,
            ((JSString code) {
              widget.onScan(code.toDart);
            }).toJS,
            ((JSString error) {
              // Manejo opcional de error
            }).toJS,
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
