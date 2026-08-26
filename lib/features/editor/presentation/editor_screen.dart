import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/services/file_picker_service.dart';
import '../../../core/services/print_service.dart';
import '../../file_import/models/import_mode.dart';
import '../../pdf/logic/pdf_layout_generator.dart';
import '../logic/editor_session.dart';
import '../models/layout_document.dart';
import '../models/layout_element.dart';
import 'widgets/image_size_sheet.dart';
import 'widgets/page_canvas.dart';
import 'widgets/paper_size_sheet.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, required this.mode});

  final ImportMode mode;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final PageController _pageController = PageController();
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(editorSessionProvider) == null) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(editorSessionProvider);
    if (session == null || session.document.pageCount == 0) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final document = session.document;
    final currentPage =
        session.currentPageIndex.clamp(0, document.pageCount - 1);
    final page = document.pageAt(currentPage)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForMode(widget.mode)),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Ekspor PDF',
            icon: const Icon(Icons.save_alt_rounded),
            onPressed: () => _runBusy(
              context,
              _exportPdf,
              'Menyiapkan berkas PDF...',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${currentPage + 1}/${document.pageCount}',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: colorScheme.surfaceContainerHigh,
        padding: const EdgeInsets.all(16),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) =>
              ref.read(editorSessionProvider.notifier).setCurrentPage(index),
          children: [
            for (final layoutPage in document.pages)
              PageCanvas(
                key: ValueKey(layoutPage.index),
                paperSize: document.paperSize,
                elements: layoutPage.elements,
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: widget.mode == ImportMode.pdfPrint
            ? OutlinedButton.icon(
                onPressed: () => _editPaperSize(document),
                icon: const Icon(Icons.aspect_ratio_rounded),
                label: Text(
                  document.paperSize.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editPaperSize(document),
                      icon: const Icon(Icons.aspect_ratio_rounded),
                      label: Text(
                        document.paperSize.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: page.elements.isEmpty
                          ? null
                          : () => _editImageSize(page.elements.first, document),
                      icon: const Icon(Icons.photo_size_select_large_rounded),
                      label: const Text('Ukuran Gambar', maxLines: 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(52, 44),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: page.elements.isEmpty
                        ? null
                        : () => ref
                            .read(editorSessionProvider.notifier)
                            .rotateElementRight(page.elements.first.pageIndex),
                    child: const Icon(Icons.rotate_right_rounded),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _runBusy(
          context,
          _printDocument,
          'Menyiapkan dokumen cetak...',
        ),
        icon: const Icon(Icons.print_outlined),
        label: const Text('Print'),
      ),
    );
  }

  String _titleForMode(ImportMode mode) => switch (mode) {
        ImportMode.imagePrint => 'Cetak Gambar',
        ImportMode.pdfPrint => 'Cetak PDF',
        ImportMode.passportPhoto => 'Cetak Pas Foto',
      };

  Future<void> _runBusy(
    BuildContext context,
    Future<void> Function() task,
    String loadingLabel,
  ) async {
    if (_isBusy) return;
    _isBusy = true;
    final navigator = Navigator.of(context, rootNavigator: true);
    unawaited(_showLoadingDialog(navigator, loadingLabel));
    try {
      await task();
    } finally {
      if (navigator.canPop()) navigator.pop();
      _isBusy = false;
    }
  }

  Future<void> _showLoadingDialog(
    NavigatorState navigator,
    String label,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _printDocument() async {
    final session = ref.read(editorSessionProvider);
    if (session == null || !mounted) return;
    try {
      final result = await PdfLayoutGenerator.generate(session.document);
      if (!mounted) return;
      if (result.unavailableSourcePaths.isNotEmpty) {
        _showSnackBar(
          '${result.unavailableSourcePaths.length} gambar tidak dapat '
          'diproses dan dikosongkan di PDF.',
        );
      }
      final printed = await PrintService.printDocument(
        result.bytes,
        jobName:
            'ngeprint-${DateTime.now().millisecondsSinceEpoch}',
      );
      if (!mounted) return;
      _showSnackBar(
        printed == true
            ? 'Dokumen dikirim ke layanan cetak.'
            : 'Pencetakan dibatalkan.',
      );
    } on Exception {
      if (!mounted) return;
      _showSnackBar('Gagal menyiapkan dokumen cetak. Coba lagi.');
    }
  }

  Future<void> _exportPdf() async {
    final session = ref.read(editorSessionProvider);
    if (session == null || !mounted) return;
    try {
      final result = await PdfLayoutGenerator.generate(session.document);
      if (!mounted) return;
      final savedUri = await FilePickerService.exportPdf(
        bytes: result.bytes,
        fileName:
            'ngeprint-${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      if (!mounted) return;
      _showSnackBar(
        savedUri != null ? 'PDF berhasil disimpan.' : 'Ekspor dibatalkan.',
      );
    } on Exception catch (error) {
      if (!mounted) return;
      _showSnackBar(
        error is AppException
            ? error.userMessage
            : 'Gagal menyimpan PDF. Coba lagi.',
      );
    }
  }

  Future<void> _editPaperSize(LayoutDocument document) async {
    final result = await showPaperSizeSheet(
      context,
      current: document.paperSize,
    );
    if (result == null || !mounted) return;
    ref.read(editorSessionProvider.notifier).changePaperSize(result);
  }

  Future<void> _editImageSize(
    LayoutElement element,
    LayoutDocument document,
  ) async {
    final result = await showImageSizeSheet(
      context,
      element: element,
      paperSize: document.paperSize,
    );
    if (result == null || !mounted) return;
    final notifier = ref.read(editorSessionProvider.notifier);
    switch (result) {
      case FitToPageResult():
        notifier.setElementToFit(element.pageIndex);
      case ManualSizeResult(:final widthMm, :final heightMm):
        notifier.setElementManualSize(
          element.pageIndex,
          widthMm: widthMm,
          heightMm: heightMm,
        );
    }
  }
}
