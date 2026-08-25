import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/services/share_intent_service.dart';
import '../models/imported_file.dart';
import '../providers/import_providers.dart';

Future<void> handleIncomingSharedMedia(
  WidgetRef ref,
  List<SharedMedia> media, {
  required void Function(String message) notify,
}) async {
  if (media.isEmpty) return;

  final loaded = await ImportedFile.loadMany(
    media.map((item) => (path: item.path, mimeType: item.mimeType)),
  );

  if (loaded.files.isEmpty) {
    notify('Berkas yang dibagikan tidak dapat dibaca.');
    return;
  }

  final images =
      loaded.files.where((file) => !file.isPdf).toList(growable: false);
  final pdfs =
      loaded.files.where((file) => file.isPdf).toList(growable: false);

  if (pdfs.isNotEmpty) {
    ref.read(pdfImportFilesProvider.notifier).replaceAll(pdfs);
  }
  if (images.isNotEmpty) {
    ref.read(imageImportFilesProvider.notifier).replaceAll(images);
  }

  final targetRoute =
      images.isEmpty ? AppRoutes.pdfImport : AppRoutes.imageImport;
  appRouter.push(targetRoute);

  var message = '${loaded.files.length} berkas ditambahkan.';
  if (loaded.failedCount > 0) {
    message += ' ${loaded.failedCount} berkas dilewati.';
  }
  notify(message);
}
