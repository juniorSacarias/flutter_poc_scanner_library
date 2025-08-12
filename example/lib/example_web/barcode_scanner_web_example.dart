import 'package:flutter/material.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc_web_stub.dart'
    if (dart.library.html) 'package:barcode_scanner_poc/barcode_scanner_poc_web.dart';

class BarcodeScannerWebExample extends StatefulWidget {
  const BarcodeScannerWebExample({super.key});

  @override
  State<BarcodeScannerWebExample> createState() =>
      _BarcodeScannerWebExampleState();
}

class _BarcodeScannerWebExampleState extends State<BarcodeScannerWebExample> {
  String _barcodeValue = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Escanea un código usando la cámara web:'),
        Text('Valor escaneado: $_barcodeValue'),
        const SizedBox(height: 20),
        SizedBox(
          width: 300,
          height: 300,
          child: BarcodeScannerPocWebWidget(
            onScan: (code) {
              setState(() {
                _barcodeValue = code;
              });
            },
          ),
        ),
      ],
    );
  }
}
