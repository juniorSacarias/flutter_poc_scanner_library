// ignore: avoid_web_libraries_in_flutter
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;
import 'dart:js_interop';

@JS('startHtml5Qrcode')
external void startHtml5Qrcode(
  JSString elementId,
  JSFunction onScan,
  JSFunction onError,
);

class BarcodeScannerPocWebWidget extends StatefulWidget {
  final void Function(String code) onScan;
  const BarcodeScannerPocWebWidget({required this.onScan, super.key});

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
        final div = html.DivElement()..id = _elementId;
        return div;
      });
      _registered = true;
    }

    // ✅ La corrección se aplica aquí: añade un pequeño retardo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kIsWeb) {
        Future.delayed(const Duration(milliseconds: 100), () {
          startHtml5Qrcode(
            _elementId.toJS,
            (JSString code) {
              widget.onScan(code.toDart);
            }.toJS,
            (JSString error) {
              // Manejo de errores opcional
            }.toJS,
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
