import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/imported_file.dart';

class FileImportService {
  final Uuid _uuid = const Uuid();

  /// Pick multiple images or PDF files using standard file picker.
  Future<List<ImportedFile>> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'pdf'],
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      final List<ImportedFile> imported = [];
      for (final file in result.files) {
        if (file.path != null) {
          final fileObj = File(file.path!);
          final size = file.size > 0 ? file.size : await fileObj.length();
          imported.add(
            ImportedFile.fromPath(
              id: _uuid.v4(),
              path: file.path!,
              name: file.name,
              sizeBytes: size,
            ),
          );
        }
      }
      return imported;
    } catch (e) {
      rethrow;
    }
  }

  /// Converts a SharedMediaFile from receive_sharing_intent to an ImportedFile model.
  Future<ImportedFile?> mapSharedMediaFile(SharedMediaFile mediaFile) async {
    final path = mediaFile.path;
    if (path.isEmpty) return null;

    final fileObj = File(path);
    if (!await fileObj.exists()) return null;

    final name = path.split(Platform.pathSeparator).last;
    final size = await fileObj.length();

    return ImportedFile.fromPath(
      id: _uuid.v4(),
      path: path,
      name: name,
      sizeBytes: size,
    );
  }

  /// Listens to Android Share Intent media stream (when app is in background or active).
  Stream<List<SharedMediaFile>> getMediaStream() {
    return ReceiveSharingIntent.instance.getMediaStream();
  }

  /// Gets initial shared media files (when app is opened via Share Intent).
  Future<List<SharedMediaFile>> getInitialMedia() {
    return ReceiveSharingIntent.instance.getInitialMedia();
  }

  /// Resets intent after handling to prevent duplicate imports on reload.
  void resetIntent() {
    ReceiveSharingIntent.instance.reset();
  }
}

