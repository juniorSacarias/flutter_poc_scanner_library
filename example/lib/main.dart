import 'package:barcode_scanner_poc_example/example_mobile/barcode_scanner_mobile_example.dart';
import 'package:barcode_scanner_poc_example/example_web/barcode_scanner_web_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';

void main() {
  debugPrint('La plataforma es: ${kIsWeb ? "Web" : "Mobile"}');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin de Escáner de Códigos')),
        body: Center(
          child: kIsWeb
              ? const BarcodeScannerWebExample()
              : const BarcodeScannerMobileExample(),
        ),
      ),
    );
  }
}
