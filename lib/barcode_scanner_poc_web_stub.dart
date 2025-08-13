import 'package:flutter/widgets.dart';

class BarcodeScannerPocWebWidget extends StatelessWidget {
  const BarcodeScannerPocWebWidget({
    super.key,
    required void Function(String) onScan,
    required config,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('El escáner web solo está disponible en la web.');
  }
}
