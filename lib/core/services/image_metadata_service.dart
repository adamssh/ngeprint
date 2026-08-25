import 'dart:ui' as ui;

class ImageDimensions {
  const ImageDimensions({required this.widthPx, required this.heightPx});

  final int widthPx;
  final int heightPx;

  double? get aspectRatio {
    if (widthPx <= 0 || heightPx <= 0) return null;
    return widthPx / heightPx;
  }
}

abstract final class ImageMetadataService {
  static Future<ImageDimensions?> readDimensions(String filePath) async {
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    try {
      buffer = await ui.ImmutableBuffer.fromFilePath(filePath);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      if (descriptor.width <= 0 || descriptor.height <= 0) return null;
      return ImageDimensions(
        widthPx: descriptor.width,
        heightPx: descriptor.height,
      );
    } catch (_) {
      return null;
    } finally {
      descriptor?.dispose();
      buffer?.dispose();
    }
  }
}
