import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/services/file_picker_service.dart';
import '../models/import_mode.dart';
import '../models/imported_file.dart';
import '../providers/import_providers.dart';

Future<void> startImportFlow(
  BuildContext context,
  WidgetRef ref,
  ImportMode mode, {
  bool replaceExisting = true,
}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);

  try {
    final paths = await pickFilePaths(mode);
    if (paths.isEmpty) return;

    final loaded =
        await ImportedFile.loadMany(paths.map((path) => (path: path, mimeType: null)));
    if (loaded.files.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Tidak ada berkas yang dapat dibaca.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final filesToImport = mode == ImportMode.passportPhoto
        ? loaded.files.take(1).toList()
        : loaded.files;

    final notifier = ref.read(importFilesProviderOf(mode).notifier);
    if (replaceExisting || mode == ImportMode.passportPhoto) {
      notifier.replaceAll(filesToImport);
    } else {
      notifier.addAll(filesToImport);
    }

    router.push(importRouteOf(mode));

    if (loaded.failedCount > 0) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            '${loaded.failedCount} berkas dilewati karena tidak dapat dibaca.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } on AppException catch (error) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(error.userMessage),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (_) {
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Terjadi kesalahan tak terduga saat memilih berkas.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

Future<List<String>> pickFilePaths(ImportMode mode) => switch (mode) {
      ImportMode.imagePrint =>
        FilePickerService.pickImages(allowMultiple: true),
      ImportMode.passportPhoto =>
        FilePickerService.pickImages(allowMultiple: false),
      ImportMode.pdfPrint => FilePickerService.pickPdfDocuments(),
    };
