import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../file_import/models/import_mode.dart';
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
        child: Row(
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onPrintPressed,
        icon: const Icon(Icons.print_outlined),
        label: const Text('Print'),
      ),
    );
  }

  String _titleForMode(ImportMode mode) =>
      mode == ImportMode.imagePrint ? 'Cetak Gambar' : mode.listTitle;

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

  void _onPrintPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fungsi cetak akan tersedia pada tahap berikutnya.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
