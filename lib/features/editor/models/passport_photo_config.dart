import '../../../core/constants/paper_sizes.dart';
import '../../../core/constants/photo_size_presets.dart';

class PassportPhotoConfig {
  const PassportPhotoConfig({
    required this.sourcePath,
    this.paperSize = PaperSize.a4,
    this.preset = PhotoSizePreset.threeByFour,
    this.quantity = 4,
    this.sourcePixelWidth,
    this.sourcePixelHeight,
  });

  final String sourcePath;
  final PaperSize paperSize;
  final PhotoSizePreset preset;
  final int quantity;
  final int? sourcePixelWidth;
  final int? sourcePixelHeight;

  PassportPhotoConfig copyWith({
    String? sourcePath,
    PaperSize? paperSize,
    PhotoSizePreset? preset,
    int? quantity,
    int? sourcePixelWidth,
    int? sourcePixelHeight,
  }) {
    return PassportPhotoConfig(
      sourcePath: sourcePath ?? this.sourcePath,
      paperSize: paperSize ?? this.paperSize,
      preset: preset ?? this.preset,
      quantity: quantity ?? this.quantity,
      sourcePixelWidth: sourcePixelWidth ?? this.sourcePixelWidth,
      sourcePixelHeight: sourcePixelHeight ?? this.sourcePixelHeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PassportPhotoConfig &&
        other.sourcePath == sourcePath &&
        other.paperSize == paperSize &&
        other.preset == preset &&
        other.quantity == quantity &&
        other.sourcePixelWidth == sourcePixelWidth &&
        other.sourcePixelHeight == sourcePixelHeight;
  }

  @override
  int get hashCode => Object.hash(
        sourcePath,
        paperSize,
        preset,
        quantity,
        sourcePixelWidth,
        sourcePixelHeight,
      );
}

