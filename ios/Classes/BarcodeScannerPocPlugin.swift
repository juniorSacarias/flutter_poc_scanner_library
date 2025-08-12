import Flutter
import UIKit

public class BarcodeScannerPocPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "barcode_scanner_poc", binaryMessenger: registrar.messenger)
        let instance = BarcodeScannerPocPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            result(FlutterError(code: "UNAVAILABLE", message: "Root view controller not found.", details: nil))
            return
        }
        
        if call.method == "scanBarcode" {
            let scannerViewController = BarcodeScannerViewController()
            
            // Definir un closure para manejar el resultado del escaneo
            scannerViewController.onBarcodeScanned = { barcodeValue in
                result(barcodeValue)
            }
            
            // Presentar la vista del escáner
            rootViewController.present(scannerViewController, animated: true)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
