import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class BarcodeScannerPoc {
  static const MethodChannel _channel = MethodChannel('barcode_scanner_poc');

  static Future<String?> scanBarcode() async {
    try {
      final String? barcodeValue = await _channel.invokeMethod('scanBarcode');
      return barcodeValue;
    } on PlatformException catch (e) {
      debugPrint("Error to process the barcode: '${e.message}'");
      return null;
    }
  }

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
