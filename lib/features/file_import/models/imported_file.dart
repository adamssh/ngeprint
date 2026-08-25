import 'dart:io';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/file_utils.dart';
import '../../../core/utils/id_generator.dart';

typedef ImportedFileSource = ({String path, String? mimeType});

class ImportedFile {
  const ImportedFile({
    required this.id,
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.mimeType,
  });

  final String id;
  final String path;
  final String name;
  final int sizeBytes;
  final String mimeType;

  bool get isPdf =>
      mimeType == FileUtils.pdfMimeType || FileUtils.isPdfPath(name);

  bool get isImage =>
      mimeType.startsWith('image/') ||
      (!isPdf && FileUtils.isImagePath(name));

  static Future<ImportedFile?> tryFromSource(ImportedFileSource source) async {
    try {
      final file = File(source.path);
      if (!await file.exists()) return null;
      final size = await file.length();
      final hint = source.mimeType;
      final mimeType = hint == null || hint == FileUtils.unknownMimeType
          ? FileUtils.mimeTypeForPath(source.path)
          : hint;
      return ImportedFile(
        id: IdGenerator.nextId(),
        path: source.path,
        name: FileUtils.fileNameOf(source.path),
        sizeBytes: size,
        mimeType: mimeType,
      );
    } on FileSystemException {
      return null;
    } on Exception {
      return null;
    }
  }

  static Future<ImportedFilesLoadResult> loadMany(
    Iterable<ImportedFileSource> sources,
  ) async {
    final files = <ImportedFile>[];
    var failedCount = 0;
    for (final source in sources) {
      final imported = await tryFromSource(source);
      if (imported == null) {
        failedCount += 1;
      } else {
        files.add(imported);
      }
    }
    return ImportedFilesLoadResult(files: files, failedCount: failedCount);
  }

  static Future<List<ImportedFile>> loadFromPaths(
    Iterable<String> paths,
  ) async {
    final result = await loadMany(paths.map((path) => (path: path, mimeType: null)));
    if (result.files.isEmpty && result.failedCount > 0) {
      throw AppException(
        '${result.failedCount} berkas tidak dapat dibaca. '
        'Periksa kembali berkas yang dipilih.',
      );
    }
    return result.files;
  }
}

class ImportedFilesLoadResult {
  const ImportedFilesLoadResult({
    required this.files,
    required this.failedCount,
  });

  final List<ImportedFile> files;
  final int failedCount;
}
