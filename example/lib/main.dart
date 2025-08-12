import 'package:barcode_scanner_poc/barcode_scanner_poc_web.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:barcode_scanner_poc/barcode_scanner_poc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _barcodeValue = 'Unknown';

  Future<void> scanBarcode() async {
    String? barcodeValue;
    try {
      barcodeValue = await BarcodeScannerPoc.scanBarcode();
    } on PlatformException {
      barcodeValue = 'Failed to get barcode value.';
    }

    if (!mounted) return;

    setState(() {
      _barcodeValue = barcodeValue ?? 'Scan cancelled';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin de Escáner de Códigos')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Presiona el botón para escanear un código:'),
              Text('Valor escaneado: $_barcodeValue\n'),
              if (kIsWeb)
                // ✅ Corrección: Envuelve el widget en un SizedBox para darle un tamaño.
                SizedBox(
                  width: 300, // Puedes ajustar el tamaño
                  height: 300,
                  child: BarcodeScannerPocWebWidget(
                    onScan: (code) {
                      setState(() {
                        _barcodeValue = code;
                      });
                    },
                  ),
                )
              else
                ElevatedButton(
                  onPressed: scanBarcode,
                  child: const Text('Escanear Código de Barras'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
