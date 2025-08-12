import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'barcode_scanner_poc_method_channel.dart';

abstract class BarcodeScannerPocPlatform extends PlatformInterface {
  /// Constructs a BarcodeScannerPocPlatform.
  BarcodeScannerPocPlatform() : super(token: _token);

  static final Object _token = Object();

  static BarcodeScannerPocPlatform _instance = MethodChannelBarcodeScannerPoc();

  /// The default instance of [BarcodeScannerPocPlatform] to use.
  ///
  /// Defaults to [MethodChannelBarcodeScannerPoc].
  static BarcodeScannerPocPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BarcodeScannerPocPlatform] when
  /// they register themselves.
  static set instance(BarcodeScannerPocPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
