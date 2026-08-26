import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/import_mode.dart';
import '../models/imported_file.dart';

class ImportFilesNotifier extends Notifier<List<ImportedFile>> {
  @override
  List<ImportedFile> build() => const [];

  void replaceAll(List<ImportedFile> files) {
    state = _withoutDuplicates(files);
  }

  void addAll(List<ImportedFile> files) {
    state = _withoutDuplicates([...state, ...files]);
  }

  void remove(String id) {
    state = state.where((file) => file.id != id).toList();
  }

  void clear() => state = const [];

  List<ImportedFile> _withoutDuplicates(List<ImportedFile> source) {
    final seenPaths = <String>{};
    final unique = <ImportedFile>[];
    for (final file in source) {
      if (seenPaths.add(file.path)) {
        unique.add(file);
      }
    }
    return unique;
  }
}

class PassportPhotoFilesNotifier extends ImportFilesNotifier {
  @override
  void replaceAll(List<ImportedFile> files) {
    state = _withoutDuplicates(files).take(1).toList();
  }

  @override
  void addAll(List<ImportedFile> files) {
    final unique = _withoutDuplicates(files);
    if (unique.isNotEmpty) {
      state = [unique.last];
    }
  }
}

final imageImportFilesProvider =
    NotifierProvider<ImportFilesNotifier, List<ImportedFile>>(
  ImportFilesNotifier.new,
);

final pdfImportFilesProvider =
    NotifierProvider<ImportFilesNotifier, List<ImportedFile>>(
  ImportFilesNotifier.new,
);

final passportPhotoImportFilesProvider =
    NotifierProvider<PassportPhotoFilesNotifier, List<ImportedFile>>(
  PassportPhotoFilesNotifier.new,
);

NotifierProvider<ImportFilesNotifier, List<ImportedFile>>
    importFilesProviderOf(ImportMode mode) => switch (mode) {
          ImportMode.imagePrint => imageImportFilesProvider,
          ImportMode.pdfPrint => pdfImportFilesProvider,
          ImportMode.passportPhoto => passportPhotoImportFilesProvider,
        };
