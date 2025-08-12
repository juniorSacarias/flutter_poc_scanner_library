import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'barcode_scanner_poc_platform_interface.dart';

class MethodChannelBarcodeScannerPoc extends BarcodeScannerPocPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('barcode_scanner_poc');

  @override
  Future<String?> getPlatformVersion() =>
      methodChannel.invokeMethod<String>('getPlatformVersion');

  @override
  Future<String?> scanBarcode() =>
      methodChannel.invokeMethod<String>('scanBarcode');
}
