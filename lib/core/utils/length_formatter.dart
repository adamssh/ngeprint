import 'unit_converter.dart';

abstract final class LengthFormatter {
  static String format(double millimeters, PhysicalUnit unit) {
    var value = UnitConverter.fromMillimeters(millimeters, unit);
    var text = value.toStringAsFixed(2);
    if (text.contains('.')) {
      text = text.replaceAll(RegExp(r'0+$'), '');
      text = text.replaceAll(RegExp(r'\.$'), '');
    }
    return text;
  }

  static double? parse(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null || value <= 0) return null;
    return value;
  }
}
