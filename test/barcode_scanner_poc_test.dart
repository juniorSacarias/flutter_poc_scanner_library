import 'package:flutter_test/flutter_test.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc_platform_interface.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBarcodeScannerPocPlatform
    with MockPlatformInterfaceMixin
    implements BarcodeScannerPocPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BarcodeScannerPocPlatform initialPlatform =
      BarcodeScannerPocPlatform.instance;

  test('$MethodChannelBarcodeScannerPoc is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBarcodeScannerPoc>());
  });

  test('getPlatformVersion', () async {});
}
