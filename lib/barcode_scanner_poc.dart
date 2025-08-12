import 'package:barcode_scanner_poc/barcode_scanner_poc_platform_interface.dart';
import 'package:flutter/material.dart';

class BarcodeScannerPoc {
  static Future<String?> scanBarcode() async {
    try {
      return await BarcodeScannerPocPlatform.instance.scanBarcode();
    } catch (e) {
      debugPrint("Error to process the barcode: '$e'");
      return null;
    }
  }

  static Future<String?> get platformVersion =>
      BarcodeScannerPocPlatform.instance.getPlatformVersion();
}
