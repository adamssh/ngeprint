abstract final class FileUtils {
  static const String pdfMimeType = 'application/pdf';
  static const String unknownMimeType = 'application/octet-stream';

  static const Set<String> _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
    'bmp',
    'heic',
    'heif',
  };

  static String fileNameOf(String path) {
    final slashIndex = path.lastIndexOf('/');
    if (slashIndex < 0 || slashIndex == path.length - 1) return path;
    return path.substring(slashIndex + 1);
  }

  static String extensionOf(String path) {
    final name = fileNameOf(path);
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == name.length - 1) return '';
    return name.substring(dotIndex + 1).toLowerCase();
  }

  static bool isImagePath(String path) =>
      _imageExtensions.contains(extensionOf(path));

  static bool isPdfPath(String path) => extensionOf(path) == 'pdf';

  static String mimeTypeForPath(String path) => switch (extensionOf(path)) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        'bmp' => 'image/bmp',
        'heic' => 'image/heic',
        'heif' => 'image/heif',
        'pdf' => pdfMimeType,
        _ => unknownMimeType,
      };

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${_format(kb)} KB';
    }
    final mb = kb / 1024;
    if (mb < 1024) {
      return '${_format(mb)} MB';
    }
    return '${(mb / 1024).toStringAsFixed(2)} GB';
  }

  static String _format(double value) {
    if (value >= 100) return value.round().toString();
    return value.toStringAsFixed(1);
  }
}
