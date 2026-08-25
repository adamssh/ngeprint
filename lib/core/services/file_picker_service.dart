import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import '../error/app_exception.dart';

abstract final class FilePickerService {
  static Future<List<String>> pickImages() => _pick(
        type: FileType.image,
        errorPrefix: 'Gagal memilih gambar',
      );

  static Future<List<String>> pickPdfDocuments() => _pick(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        errorPrefix: 'Gagal memilih PDF',
      );

  static Future<List<String>> _pick({
    required FileType type,
    List<String>? allowedExtensions,
    required String errorPrefix,
  }) async {
    try {
      final files = await FilePicker.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );
      return files.map((file) => file.path).whereType<String>().toList();
    } on PlatformException catch (error) {
      throw AppException('$errorPrefix: ${error.message ?? error.code}');
    }
  }
}
