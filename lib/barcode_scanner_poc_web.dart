import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

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
      ui_web.platformViewRegistry.registerViewFactory(
        _elementId,
        (int viewId) => html.DivElement()..id = _elementId,
      );
      _registered = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kIsWeb) {
        Future.delayed(const Duration(milliseconds: 100), () {
          startHtml5Qrcode(
            _elementId.toJS,
            ((JSString code) {
              widget.onScan(code.toDart);
            }).toJS,
            ((JSString error) {
              // Manejo opcional de error
            }).toJS,
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
