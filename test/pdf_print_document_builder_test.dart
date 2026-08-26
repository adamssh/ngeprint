import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:ngeprint/core/constants/paper_sizes.dart';
import 'package:ngeprint/core/services/pdf_raster_service.dart';
import 'package:ngeprint/features/editor/models/layout_element.dart';
import 'package:ngeprint/features/file_import/models/imported_file.dart';
import 'package:ngeprint/features/pdf/logic/pdf_print_document_builder.dart';

class FakePdfRasterizer implements PdfRasterizer {
  FakePdfRasterizer(this.pagesPerDocument);

  final int pagesPerDocument;

  @override
  Stream<PdfRaster> raster(
    Uint8List document, {
    List<int>? pages,
    double dpi = PdfPageFormat.inch,
  }) async* {
    for (var i = 0; i < pagesPerDocument; i++) {
      const width = 200;
      const height = 300;
      final pixels = Uint8List(width * height * 4);
      yield PdfRaster(width, height, pixels);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File testPdf1;
  late File testPdf2;
  late File testImage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ngeprint_test_');
    testPdf1 = File('${tempDir.path}/doc1.pdf')..writeAsBytesSync([1, 2, 3]);
    testPdf2 = File('${tempDir.path}/doc2.pdf')..writeAsBytesSync([4, 5, 6]);
    testImage = File('${tempDir.path}/img.jpg')..writeAsBytesSync([7, 8, 9]);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('PdfPrintDocumentBuilder menggabungkan banyak berkas PDF menjadi urutan halaman yang benar', () async {
    final importedFiles = [
      ImportedFile(
        id: '1',
        path: testPdf1.path,
        name: 'doc1.pdf',
        sizeBytes: 3,
        mimeType: 'application/pdf',
      ),
      ImportedFile(
        id: '2',
        path: testPdf2.path,
        name: 'doc2.pdf',
        sizeBytes: 3,
        mimeType: 'application/pdf',
      ),
      ImportedFile(
        id: '3',
        path: testImage.path,
        name: 'img.jpg',
        sizeBytes: 3,
        mimeType: 'image/jpeg',
      ),
    ];

    final document = await PdfPrintDocumentBuilder.build(
      importedFiles,
      paperSize: PaperSize.f4,
      rasterizer: FakePdfRasterizer(2),
    );

    expect(document, isNotNull);
    expect(document!.paperSize, PaperSize.f4);
    // 2 PDFs * 2 pages each = 4 pages (image is skipped)
    expect(document.pageCount, 4);

    for (var i = 0; i < 4; i++) {
      final page = document.pageAt(i);
      expect(page, isNotNull);
      expect(page!.index, i);
      expect(page.elements.length, 1);

      final element = page.elements.first;
      expect(element.pageIndex, i);
      expect(element.sizeMode, ElementSizeMode.fitToPage);
      expect(element.type, LayoutElementType.image);
      expect(File(element.sourcePath).existsSync(), isTrue);
      // Dimensions fit within F4 (210 x 330 mm)
      expect(element.widthMm, lessThanOrEqualTo(PaperSize.f4.widthMm + 0.01));
      expect(element.heightMm, lessThanOrEqualTo(PaperSize.f4.heightMm + 0.01));
    }
  });

  test('PdfPrintDocumentBuilder mengembalikan null jika tidak ada PDF valid', () async {
    final importedFiles = [
      ImportedFile(
        id: '1',
        path: testImage.path,
        name: 'img.jpg',
        sizeBytes: 3,
        mimeType: 'image/jpeg',
      ),
    ];

    final document = await PdfPrintDocumentBuilder.build(
      importedFiles,
      paperSize: PaperSize.a4,
      rasterizer: FakePdfRasterizer(2),
    );

    expect(document, isNull);
  });
}

