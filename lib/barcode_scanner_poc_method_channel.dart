import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'barcode_scanner_poc_platform_interface.dart';

/// An implementation of [BarcodeScannerPocPlatform] that uses method channels.
class MethodChannelBarcodeScannerPoc extends BarcodeScannerPocPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('barcode_scanner_poc');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
