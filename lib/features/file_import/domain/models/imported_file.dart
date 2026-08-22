enum ImportedFileType { image, pdf, unknown }

class ImportedFile {
  final String id;
  final String path;
  final String name;
  final int sizeBytes;
  final ImportedFileType fileType;
  final DateTime importedAt;

  const ImportedFile({
    required this.id,
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.fileType,
    required this.importedAt,
  });

  bool get isPdf => fileType == ImportedFileType.pdf;
  bool get isImage => fileType == ImportedFileType.image;

  factory ImportedFile.fromPath({
    required String id,
    required String path,
    required String name,
    required int sizeBytes,
    DateTime? importedAt,
  }) {
    final lowerName = name.toLowerCase();
    final lowerPath = path.toLowerCase();
    
    ImportedFileType type = ImportedFileType.unknown;
    if (lowerName.endsWith('.pdf') || lowerPath.endsWith('.pdf')) {
      type = ImportedFileType.pdf;
    } else if (lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.webp') ||
        lowerName.endsWith('.bmp')) {
      type = ImportedFileType.image;
    }

    return ImportedFile(
      id: id,
      path: path,
      name: name,
      sizeBytes: sizeBytes,
      fileType: type,
      importedAt: importedAt ?? DateTime.now(),
    );
  }
}

