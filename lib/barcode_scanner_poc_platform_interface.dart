import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'barcode_scanner_poc_method_channel.dart';

abstract class BarcodeScannerPocPlatform extends PlatformInterface {
  BarcodeScannerPocPlatform() : super(token: _token);

  static final Object _token = Object();
  static BarcodeScannerPocPlatform _instance = MethodChannelBarcodeScannerPoc();

  static BarcodeScannerPocPlatform get instance => _instance;

  static set instance(BarcodeScannerPocPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion();
  Future<String?> scanBarcode();
}
