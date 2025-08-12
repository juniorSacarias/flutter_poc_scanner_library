import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
// ✅ Importación correcta del plugin usando el nombre 'barcode_scanner_poc'
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

  // Lógica para escanear el código de barras
  Future<void> scanBarcode() async {
    String? barcodeValue;
    try {
      // ✅ Llamada correcta al método del plugin, que usa la clase BarcodeScannerPoc
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
