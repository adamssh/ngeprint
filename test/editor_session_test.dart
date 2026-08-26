import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngeprint/core/constants/paper_sizes.dart';
import 'package:ngeprint/features/editor/logic/editor_session.dart';
import 'package:ngeprint/features/editor/logic/layout_geometry.dart';
import 'package:ngeprint/features/editor/models/layout_document.dart';
import 'package:ngeprint/features/editor/models/layout_element.dart';
import 'package:ngeprint/features/editor/models/layout_page.dart';

void main() {
  group('LayoutGeometry.fitContainTopLeft', () {
    const pageWidth = 210.0;
    const pageHeight = 297.0;

    test('tanpa aspect ratio memenuhi seluruh halaman', () {
      final rect = LayoutGeometry.fitContainTopLeft(
        pageWidthMm: pageWidth,
        pageHeightMm: pageHeight,
        sourceAspectRatio: null,
      );
      expect(rect.x, 0);
      expect(rect.y, 0);
      expect(rect.width, pageWidth);
      expect(rect.height, pageHeight);
    });

    test('gambar lebar pas lebar halaman di pojok kiri atas', () {
      final rect = LayoutGeometry.fitContainTopLeft(
        pageWidthMm: pageWidth,
        pageHeightMm: pageHeight,
        sourceAspectRatio: 2,
      );
      expect(rect.x, 0);
      expect(rect.y, 0);
      expect(rect.width, pageWidth);
      expect(rect.height, pageWidth / 2);
    });

    test('gambar tinggi pas tinggi halaman di pojok kiri atas', () {
      final rect = LayoutGeometry.fitContainTopLeft(
        pageWidthMm: pageWidth,
        pageHeightMm: pageHeight,
        sourceAspectRatio: 0.5,
      );
      expect(rect.x, 0);
      expect(rect.y, 0);
      expect(rect.height, pageHeight);
      expect(rect.width, pageHeight * 0.5);
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
        expect(element.xMm, 0);
        expect(element.yMm, 0);
        expect(element.widthMm, PaperSize.f4.widthMm);
        expect(element.heightMm, PaperSize.f4.widthMm / 2);
      }
    });

    test('ukuran manual hanya berlaku pada satu halaman dan menempel pojok',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(editorSessionProvider.notifier);

      notifier.start(_buildDocument());
      notifier.setElementManualSize(0, widthMm: 100, heightMm: 50);

      final session = container.read(editorSessionProvider)!;
      final first = session.document.pages[0].elements.first;
      final second = session.document.pages[1].elements.first;

      expect(first.sizeMode, ElementSizeMode.manual);
      expect(first.xMm, 0);
      expect(first.yMm, 0);
      expect(first.widthMm, 100);
      expect(first.heightMm, 50);
      expect(second.sizeMode, ElementSizeMode.fitToPage);
    });

    test('ukuran manual melebihi halaman diskalakan agar muat', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(editorSessionProvider.notifier);

      notifier.start(_buildDocument());
      notifier.setElementManualSize(0, widthMm: 420, heightMm: 210);

      final element = container
          .read(editorSessionProvider)!
          .document
          .pages[0]
          .elements
          .first;
      expect(element.widthMm, PaperSize.a4.widthMm);
      expect(element.heightMm, PaperSize.a4.widthMm / 2);
      expect(element.xMm, 0);
      expect(element.yMm, 0);
    });

    test('rotasi ke kanan menukar dimensi fit dan mencatat 90 derajat', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(editorSessionProvider.notifier);

      notifier.start(_buildDocument());
      notifier.rotateElementRight(0);

      final element = container
          .read(editorSessionProvider)!
          .document
          .pages[0]
          .elements
          .first;
      expect(element.rotationDeg, 90);
      expect(element.isRotatedQuarterTurn, isTrue);
      expect(element.yMm, 0);
      expect(element.xMm, 0);
      expect(element.heightMm, PaperSize.a4.heightMm);
      expect(element.widthMm, PaperSize.a4.heightMm / 2);
    });

    test(
        'rotasi berulang kembali ke orientasi awal pada 360 derajat '
        'dan tetap muat di kertas', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(editorSessionProvider.notifier);

      notifier.start(_buildDocument());
      for (var i = 0; i < 4; i++) {
        notifier.rotateElementRight(1);
      }

      final element = container
          .read(editorSessionProvider)!
          .document
          .pages[1]
          .elements
          .first;
      expect(element.rotationDeg, 0);
      expect(element.widthMm, PaperSize.a4.widthMm);
      expect(element.heightMm, PaperSize.a4.widthMm / 2);
    });

    test(
        'rotasi elemen manual yang meluap saat ditukar otomatis '
        'mengikuti kertas', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(editorSessionProvider.notifier);

      notifier.start(_buildDocument());
      notifier.setElementManualSize(0, widthMm: 200, heightMm: 250);
      notifier.rotateElementRight(0);

      final element = container
          .read(editorSessionProvider)!
          .document
          .pages[0]
          .elements
          .first;
      expect(element.rotationDeg, 90);
      expect(element.sizeMode, ElementSizeMode.manual);
      expect(element.xMm, 0);
      expect(element.yMm, 0);
      expect(element.widthMm, PaperSize.a4.widthMm);
      expect(element.heightMm, closeTo(168, 0.01));
    });

    test('setElementToFit mengembalikan mode fit dengan rasio efektif', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(editorSessionProvider.notifier);

      notifier.start(_buildDocument());
      notifier.setElementManualSize(1, widthMm: 80, heightMm: 40);
      notifier.setElementToFit(1);

      final element = container
          .read(editorSessionProvider)!
          .document
          .pages[1]
          .elements
          .first;
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
