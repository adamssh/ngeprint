import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/utils/file_utils.dart';
import '../../editor/logic/editor_session.dart';
import '../../editor/logic/image_print_document_builder.dart';
import '../../pdf/logic/pdf_print_document_builder.dart';
import '../logic/import_flow.dart';
import '../models/import_mode.dart';
import '../models/imported_file.dart';
import '../providers/import_providers.dart';

class ImportListScreen extends ConsumerWidget {
  const ImportListScreen({super.key, required this.mode});

  final ImportMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(importFilesProviderOf(mode));
    final provider = importFilesProviderOf(mode);

    return Scaffold(
      appBar: AppBar(
        title: Text(mode.listTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah berkas',
            onPressed: () =>
                startImportFlow(context, ref, mode, replaceExisting: false),
          ),
        ],
      ),
      body: files.isEmpty
          ? _ImportEmptyView(
              mode: mode,
              onSelectFiles: () => startImportFlow(context, ref, mode),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: files.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final file = files[index];
                return _ImportFileTile(
                  file: file,
                  index: index,
                  onRemove: () => ref.read(provider.notifier).remove(file.id),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed:
              files.isEmpty ? null : () => _handleContinue(context, ref, mode),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(mode.continueActionLabel),
        ),
      ),
    );
  }

  void _handleContinue(
    BuildContext context,
    WidgetRef ref,
    ImportMode mode,
  ) {
    if (mode == ImportMode.imagePrint) {
      unawaited(_openImageEditor(context, ref, mode));
      return;
    }
    if (mode == ImportMode.pdfPrint) {
      unawaited(_openPdfEditor(context, ref, mode));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${mode.continueActionLabel} akan tersedia pada tahap pengembangan '
          'berikutnya.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openImageEditor(
    BuildContext context,
    WidgetRef ref,
    ImportMode mode,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final files = ref.read(importFilesProviderOf(mode));
      final document = await ImagePrintDocumentBuilder.build(files);
      if (document == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Tidak ada gambar yang dapat disusun.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      ref.read(editorSessionProvider.notifier).start(document);
      await router.push(AppRoutes.imageEditor);
    } on Exception {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Gagal menyiapkan editor cetak gambar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openPdfEditor(
    BuildContext context,
    WidgetRef ref,
    ImportMode mode,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Expanded(child: Text('Menyiapkan dokumen PDF...')),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final files = ref.read(importFilesProviderOf(mode));
      final document = await PdfPrintDocumentBuilder.build(files);
      if (navigator.canPop()) navigator.pop();
      if (document == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Tidak ada halaman PDF yang dapat diproses.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      ref.read(editorSessionProvider.notifier).start(document);
      await router.push(AppRoutes.pdfEditor);
    } on Exception {
      if (navigator.canPop()) navigator.pop();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Gagal menyiapkan editor cetak PDF.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _ImportEmptyView extends StatelessWidget {
  const _ImportEmptyView({required this.mode, required this.onSelectFiles});

  final ImportMode mode;
  final VoidCallback onSelectFiles;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              mode.emptyTitle,
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              mode.emptyHint,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onSelectFiles,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Pilih Berkas'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportFileTile extends StatelessWidget {
  const _ImportFileTile({
    required this.file,
    required this.index,
    required this.onRemove,
  });

  final ImportedFile file;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: _ImportFileThumbnail(file: file, size: 48),
      title: Text(
        file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '#${index + 1} • ${file.isPdf ? 'PDF' : 'Gambar'} • '
        '${FileUtils.formatFileSize(file.sizeBytes)}',
      ),
      tileColor: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      trailing: IconButton(
        icon: const Icon(Icons.close_rounded),
        tooltip: 'Hapus dari daftar',
        onPressed: onRemove,
      ),
    );
  }
}

class _ImportFileThumbnail extends StatelessWidget {
  const _ImportFileThumbnail({required this.file, required this.size});

  final ImportedFile file;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget placeholder(Color background, Color foreground, IconData icon) {
      return ColoredBox(
        color: background,
        child: Icon(icon, color: foreground, size: size * 0.5),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: file.isPdf
            ? placeholder(
                colorScheme.errorContainer,
                colorScheme.onErrorContainer,
                Icons.picture_as_pdf_rounded,
              )
            : Image.file(
                File(file.path),
                fit: BoxFit.cover,
                cacheWidth: (size * 2).round(),
                errorBuilder: (_, _, _) => placeholder(
                  colorScheme.surfaceContainerHighest,
                  colorScheme.onSurfaceVariant,
                  Icons.broken_image_outlined,
                ),
              ),
      ),
    );
  }
}
