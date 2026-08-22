import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/file_import_service.dart';
import '../../domain/models/imported_file.dart';

class FileImportState {
  final List<ImportedFile> files;
  final bool isLoading;
  final String? errorMessage;

  const FileImportState({
    this.files = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FileImportState copyWith({
    List<ImportedFile>? files,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FileImportState(
      files: files ?? this.files,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class FileImportNotifier extends StateNotifier<FileImportState> {
  final FileImportService _service;
  StreamSubscription? _intentSubscription;

  FileImportNotifier(this._service) : super(const FileImportState()) {
    _initShareIntentListener();
  }

  void _initShareIntentListener() {
    // 1. Listen for stream while app is open/paused
    _intentSubscription = _service.getMediaStream().listen(
      (sharedFiles) async {
        if (sharedFiles.isNotEmpty) {
          await _processSharedFiles(sharedFiles);
        }
      },
      onError: (err) {
        state = state.copyWith(errorMessage: 'Gagal menerima intent: $err');
      },
    );

    // 2. Process initial intent when app is launched from closed state
    _service.getInitialMedia().then((sharedFiles) async {
      if (sharedFiles.isNotEmpty) {
        await _processSharedFiles(sharedFiles);
        _service.resetIntent();
      }
    }).catchError((err) {
      state = state.copyWith(errorMessage: 'Gagal mengambil initial share intent: $err');
    });
  }

  Future<void> _processSharedFiles(List sharedFiles) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final List<ImportedFile> newlyImported = [];

    for (final sf in sharedFiles) {
      final imported = await _service.mapSharedMediaFile(sf);
      if (imported != null) {
        newlyImported.add(imported);
      }
    }

    if (newlyImported.isNotEmpty) {
      state = state.copyWith(
        files: [...state.files, ...newlyImported],
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> pickFilesFromStorage() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final picked = await _service.pickFiles();
      if (picked.isNotEmpty) {
        state = state.copyWith(
          files: [...state.files, ...picked],
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memilih file: $e',
      );
    }
  }

  void removeFile(String id) {
    state = state.copyWith(
      files: state.files.where((f) => f.id != id).toList(),
    );
  }

  void clearFiles() {
    state = state.copyWith(files: []);
  }

  @override
  void dispose() {
    _intentSubscription?.cancel();
    super.dispose();
  }
}

final fileImportServiceProvider = Provider<FileImportService>((ref) {
  return FileImportService();
});

final fileImportProvider =
    StateNotifierProvider<FileImportNotifier, FileImportState>((ref) {
  final service = ref.watch(fileImportServiceProvider);
  return FileImportNotifier(service);
});

