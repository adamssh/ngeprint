class PhotoSizePreset {
  const PhotoSizePreset({
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

  static const PhotoSizePreset twoByThree = PhotoSizePreset(
    id: '2x3',
    label: '2×3 cm',
    widthMm: 20,
    heightMm: 30,
  );

  static const PhotoSizePreset threeByFour = PhotoSizePreset(
    id: '3x4',
    label: '3×4 cm',
    widthMm: 30,
    heightMm: 40,
  );

  static const PhotoSizePreset fourBySix = PhotoSizePreset(
    id: '4x6',
    label: '4×6 cm',
    widthMm: 40,
    heightMm: 60,
  );

  static const PhotoSizePreset custom = PhotoSizePreset(
    id: 'custom',
    label: 'Custom',
    widthMm: 25,
    heightMm: 35,
    isCustom: true,
  );

  static const List<PhotoSizePreset> presets = [
    twoByThree,
    threeByFour,
    fourBySix,
  ];

  static const List<PhotoSizePreset> selectablePresets = [
    ...presets,
    custom,
  ];

  PhotoSizePreset copyWith({
    String? id,
    String? label,
    double? widthMm,
    double? heightMm,
    bool? isCustom,
  }) {
    return PhotoSizePreset(
      id: id ?? this.id,
      label: label ?? this.label,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotoSizePreset &&
        other.id == id &&
        other.label == label &&
        other.widthMm == widthMm &&
        other.heightMm == heightMm &&
        other.isCustom == isCustom;
  }

  @override
  int get hashCode => Object.hash(id, label, widthMm, heightMm, isCustom);

  @override
  String toString() =>
      'PhotoSizePreset($id: $widthMm×$heightMm mm)';
}
