import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngeprint/core/constants/paper_sizes.dart';
import 'package:ngeprint/features/editor/logic/editor_session.dart';
import 'package:ngeprint/features/editor/logic/layout_geometry.dart';
import 'package:ngeprint/features/editor/models/layout_document.dart';
import 'package:ngeprint/features/editor/models/layout_element.dart';
import 'package:ngeprint/features/editor/models/layout_page.dart';

void main() {
  group('LayoutGeometry.fitContainCentered', () {
    const pageWidth = 210.0;
    const pageHeight = 297.0;

    test('tanpa aspect ratio memenuhi seluruh halaman', () {
      final rect = LayoutGeometry.fitContainCentered(
        pageWidthMm: pageWidth,
        pageHeightMm: pageHeight,
        sourceAspectRatio: null,
      );
      expect(rect.x, 0);
      expect(rect.y, 0);
      expect(rect.width, pageWidth);
      expect(rect.height, pageHeight);
    });

    test('gambar lebar (landscape) pas lebar halaman dan di tengah vertikal',
        () {
      final rect = LayoutGeometry.fitContainCentered(
        pageWidthMm: pageWidth,
        pageHeightMm: pageHeight,
        sourceAspectRatio: 2,
      );
      expect(rect.width, pageWidth);
      expect(rect.height, pageWidth / 2);
      expect(rect.x, 0);
      expect(rect.y, (pageHeight - pageWidth / 2) / 2);
    });

    test('gambar tinggi (portrait) pas tinggi halaman dan di tengah horizontal',
        () {
      final rect = LayoutGeometry.fitContainCentered(
        pageWidthMm: pageWidth,
        pageHeightMm: pageHeight,
        sourceAspectRatio: 0.5,
      );
      expect(rect.height, pageHeight);
      expect(rect.width, pageHeight * 0.5);
      expect(rect.y, 0);
      expect(rect.x, (pageWidth - pageHeight * 0.5) / 2);
    });

    test('rasio sama dengan halaman mengisi penuh', () {
      final rect = LayoutGeometry.fitContainCentered(
        pageWidthMm: pageWidth,
        pageHeightMm: pageHeight,
        sourceAspectRatio: pageWidth / pageHeight,
      );
      expect(rect.width, pageWidth);
      expect(rect.height, pageHeight);
      expect(rect.x, 0);
      expect(rect.y, 0);
    });
  });

  group('EditorSessionNotifier', () {
    test('ganti ukuran kertas diterapkan ke semua halaman', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(editorSessionProvider.notifier);

      notifier.start(_buildDocument());
      notifier.changePaperSize(PaperSize.f4);

      final session = container.read(editorSessionProvider)!;
      expect(session.document.paperSize, PaperSize.f4);
      expect(session.document.pageCount, 2);
      for (final page in session.document.pages) {
        final element = page.elements.first;
        expect(element.widthMm, PaperSize.f4.widthMm);
        expect(element.heightMm, PaperSize.f4.widthMm / 2);
        expect(element.xMm, 0);
        expect(element.yMm, (PaperSize.f4.heightMm - element.heightMm) / 2);
      }
    });

    test('ukuran manual hanya berlaku pada satu halaman', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(editorSessionProvider.notifier);

      notifier.start(_buildDocument());
      notifier.setElementManualSize(0, widthMm: 100, heightMm: 50);

      final session = container.read(editorSessionProvider)!;
      final first = session.document.pages[0].elements.first;
      final second = session.document.pages[1].elements.first;

      expect(first.sizeMode, ElementSizeMode.manual);
      expect(first.widthMm, 100);
      expect(first.heightMm, 50);
      expect(first.xMm, (PaperSize.a4.widthMm - 100) / 2);
      expect(second.sizeMode, ElementSizeMode.fitToPage);
    });

    test('ukuran manual melebihi halaman diskalakan agar muat', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(editorSessionProvider.notifier);

      notifier.start(_buildDocument());
      notifier.setElementManualSize(0, widthMm: 420, heightMm: 210);

      final element =
          container.read(editorSessionProvider)!.document.pages[0].elements.first;
      expect(element.widthMm, PaperSize.a4.widthMm);
      expect(element.heightMm, PaperSize.a4.widthMm / 2);
      expect(element.xMm, 0);
    });

    test('setElementToFit mengembalikan mode fit', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(editorSessionProvider.notifier);

      notifier.start(_buildDocument());
      notifier.setElementManualSize(1, widthMm: 80, heightMm: 40);
      notifier.setElementToFit(1);

      final element =
          container.read(editorSessionProvider)!.document.pages[1].elements.first;
      expect(element.sizeMode, ElementSizeMode.fitToPage);
      expect(element.widthMm, PaperSize.a4.widthMm);
      expect(element.heightMm, PaperSize.a4.widthMm / 2);
    });

    test('setCurrentPage dibatasi ke rentang halaman valid', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(editorSessionProvider.notifier);

      notifier.start(_buildDocument());
      notifier.setCurrentPage(99);
      expect(container.read(editorSessionProvider)!.currentPageIndex, 1);
      notifier.setCurrentPage(-5);
      expect(container.read(editorSessionProvider)!.currentPageIndex, 0);
    });
  });
}

LayoutDocument _buildDocument() {
  LayoutElement imageElement(int pageIndex) => LayoutElement(
        id: 'el-$pageIndex',
        type: LayoutElementType.image,
        sourcePath: '/dummy/image_$pageIndex.jpg',
        pageIndex: pageIndex,
        xMm: 0,
        yMm: 0,
        widthMm: 100,
        heightMm: 50,
        sizeMode: ElementSizeMode.fitToPage,
        sourcePixelWidth: 2000,
        sourcePixelHeight: 1000,
      );

  return LayoutDocument(
    paperSize: PaperSize.a4,
    pages: [
      LayoutPage(index: 0, elements: [imageElement(0)]),
      LayoutPage(index: 1, elements: [imageElement(1)]),
    ],
  );
}
