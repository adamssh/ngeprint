import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:ngeprint/core/constants/paper_sizes.dart';
import 'package:ngeprint/features/editor/models/layout_document.dart';
import 'package:ngeprint/features/editor/models/layout_element.dart';
import 'package:ngeprint/features/editor/models/layout_page.dart';
import 'package:ngeprint/features/pdf/logic/pdf_layout_generator.dart';

void main() {
  test(
    'generator menghasilkan PDF valid dengan jumlah halaman yang benar',
    () async {
      final document = _buildDocument();
      final result = await PdfLayoutGenerator.generate(document);

      expect(_asLatin1(result.bytes).startsWith('%PDF-'), isTrue);
      expect(result.bytes.length, greaterThan(1000));
      expect(result.unavailableSourcePaths.length, 2);
      final content = _asLatin1(result.bytes);
      expect('/MediaBox'.allMatches(content).length, 2);
    },
  );

  test('ukuran halaman F4 memakai konversi mm ke poin yang benar', () async {
    final document = LayoutDocument(paperSize: PaperSize.f4, pages: [
      LayoutPage(index: 0, elements: [_element(0)]),
    ]);
    final result = await PdfLayoutGenerator.generate(document);
    final content = _asLatin1(result.bytes);
    expect(content.contains('935.43'), isTrue);
  });
}

String _asLatin1(Uint8List bytes) => String.fromCharCodes(bytes);

LayoutElement _element(int pageIndex) => LayoutElement(
      id: 'el-$pageIndex',
      type: LayoutElementType.image,
      sourcePath: '/dummy/image_$pageIndex.jpg',
      pageIndex: pageIndex,
      xMm: 10,
      yMm: 20,
      widthMm: 100,
      heightMm: 50,
      sizeMode: ElementSizeMode.manual,
      rotationDeg: pageIndex == 0 ? 90 : 0,
    );

LayoutDocument _buildDocument() {
  return LayoutDocument(
    paperSize: PaperSize.a4,
    pages: [
      LayoutPage(index: 0, elements: [_element(0)]),
      LayoutPage(index: 1, elements: [_element(1)]),
    ],
  );
}
