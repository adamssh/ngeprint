import '../utils/unit_converter.dart';

class PaperSize {
  const PaperSize({
    required this.id,
    required this.label,
    required this.widthMm,
    required this.heightMm,
    this.isCustom = false,
  });

  final String id;
  final String label;
  final double widthMm;
  final double heightMm;
  final bool isCustom;

  static const PaperSize a4 = PaperSize(
    id: 'a4',
    label: 'A4',
    widthMm: 210,
    heightMm: 297,
  );

  static const PaperSize a5 = PaperSize(
    id: 'a5',
    label: 'A5',
    widthMm: 148,
    heightMm: 210,
  );

  static const PaperSize letter = PaperSize(
    id: 'letter',
    label: 'Letter',
    widthMm: 215.9,
    heightMm: 279.4,
  );

  static const PaperSize legal = PaperSize(
    id: 'legal',
    label: 'Legal',
    widthMm: 215.9,
    heightMm: 355.6,
  );

  static const PaperSize f4 = PaperSize(
    id: 'f4',
    label: 'F4',
    widthMm: 210,
    heightMm: 330,
  );

  static const PaperSize custom = PaperSize(
    id: 'custom',
    label: 'Custom',
    widthMm: 100,
    heightMm: 150,
    isCustom: true,
  );

  static const List<PaperSize> presets = [a4, a5, letter, legal, f4];

  static const List<PaperSize> selectableSizes = [...presets, custom];

  double get widthPoints => UnitConverter.mmToPoints(widthMm);

  double get heightPoints => UnitConverter.mmToPoints(heightMm);

  String get dimensionLabel =>
      '${_formatNumber(widthMm)} × ${_formatNumber(heightMm)} mm';

  PaperSize copyWith({
    String? id,
    String? label,
    double? widthMm,
    double? heightMm,
    bool? isCustom,
  }) {
    return PaperSize(
      id: id ?? this.id,
      label: label ?? this.label,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaperSize &&
        other.id == id &&
        other.label == label &&
        other.widthMm == widthMm &&
        other.heightMm == heightMm &&
        other.isCustom == isCustom;
  }

  @override
  int get hashCode =>
      Object.hash(id, label, widthMm, heightMm, isCustom);

  @override
  String toString() => 'PaperSize($id: $dimensionLabel)';
}
