import 'dart:typed_data';

import 'package:printing/printing.dart';

abstract final class PrintService {
  static Future<bool?> printDocument(
    Uint8List bytes, {
    String jobName = 'ngeprint',
  }) {
    return Printing.layoutPdf(onLayout: (_) async => bytes, name: jobName);
  }
}
