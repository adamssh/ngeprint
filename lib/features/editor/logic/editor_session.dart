import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/paper_sizes.dart';
import '../models/layout_document.dart';
import '../models/layout_element.dart';
import 'layout_geometry.dart';

class EditorSession {
  const EditorSession({
    required this.document,
    required this.currentPageIndex,
  });

  final LayoutDocument document;
  final int currentPageIndex;
}

class EditorSessionNotifier extends Notifier<EditorSession?> {
  @override
  EditorSession? build() => null;

  void start(LayoutDocument document) {
    state = EditorSession(document: document, currentPageIndex: 0);
  }

  void setCurrentPage(int index) {
    final session = state;
    if (session == null || session.document.pageCount == 0) return;
    final clamped = index.clamp(0, session.document.pageCount - 1);
    if (clamped == session.currentPageIndex) return;
    state = EditorSession(
      document: session.document,
      currentPageIndex: clamped,
    );
  }

  void changePaperSize(PaperSize paperSize) {
    final session = state;
    if (session == null) return;
    final document = session.document;
    final relaidPages = document.pages
        .map(
          (page) => page.copyWith(
            elements:
                page.elements.map((e) => _relayout(e, paperSize)).toList(),
          ),
        )
        .toList();
    state = EditorSession(
      document: document.copyWith(paperSize: paperSize, pages: relaidPages),
      currentPageIndex: session.currentPageIndex,
    );
  }

  void setElementToFit(int pageIndex) {
    _updateElementsOfPage(pageIndex, (element, paperSize) {
      final rect = LayoutGeometry.fitContainCentered(
        pageWidthMm: paperSize.widthMm,
        pageHeightMm: paperSize.heightMm,
        sourceAspectRatio: element.sourceAspectRatio,
      );
      return element.copyWith(
        xMm: rect.x,
        yMm: rect.y,
        widthMm: rect.width,
        heightMm: rect.height,
        sizeMode: ElementSizeMode.fitToPage,
      );
    });
  }

  void setElementManualSize(
    int pageIndex, {
    required double widthMm,
    required double heightMm,
  }) {
    if (widthMm <= 0 || heightMm <= 0) return;
    _updateElementsOfPage(pageIndex, (element, paperSize) {
      final rect = LayoutGeometry.manualCentered(
        pageWidthMm: paperSize.widthMm,
        pageHeightMm: paperSize.heightMm,
        widthMm: widthMm,
        heightMm: heightMm,
      );
      return element.copyWith(
        xMm: rect.x,
        yMm: rect.y,
        widthMm: rect.width,
        heightMm: rect.height,
        sizeMode: ElementSizeMode.manual,
      );
    });
  }

  void _updateElementsOfPage(
    int pageIndex,
    LayoutElement Function(LayoutElement element, PaperSize paperSize)
        transform,
  ) {
    final session = state;
    if (session == null) return;
    final document = session.document;
    final pages = document.pages.map((page) {
      if (page.index != pageIndex) return page;
      return page.copyWith(
        elements: page.elements.map((e) => transform(e, document.paperSize)).toList(),
      );
    }).toList();
    state = EditorSession(
      document: document.copyWith(pages: pages),
      currentPageIndex: session.currentPageIndex,
    );
  }

  LayoutElement _relayout(LayoutElement element, PaperSize paperSize) {
    if (element.sizeMode == ElementSizeMode.manual) {
      final rect = LayoutGeometry.manualCentered(
        pageWidthMm: paperSize.widthMm,
        pageHeightMm: paperSize.heightMm,
        widthMm: element.widthMm,
        heightMm: element.heightMm,
      );
      return element.copyWith(
        xMm: rect.x,
        yMm: rect.y,
        widthMm: rect.width,
        heightMm: rect.height,
      );
    }
    final rect = LayoutGeometry.fitContainCentered(
      pageWidthMm: paperSize.widthMm,
      pageHeightMm: paperSize.heightMm,
      sourceAspectRatio: element.sourceAspectRatio,
    );
    return element.copyWith(
      xMm: rect.x,
      yMm: rect.y,
      widthMm: rect.width,
      heightMm: rect.height,
    );
  }
}

final editorSessionProvider =
    NotifierProvider<EditorSessionNotifier, EditorSession?>(
  EditorSessionNotifier.new,
);
