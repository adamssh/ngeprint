import 'dart:io';

import '../../../core/constants/paper_sizes.dart';
import '../../../core/services/pdf_raster_service.dart';
import '../../../core/utils/id_generator.dart';
import '../../editor/logic/layout_geometry.dart';
import '../../editor/models/layout_document.dart';
import '../../editor/models/layout_element.dart';
import '../../editor/models/layout_page.dart';
import '../../file_import/models/imported_file.dart';

abstract final class PdfPrintDocumentBuilder {
  static const double defaultRasterDpi = 200;

  static Future<LayoutDocument?> build(
    List<ImportedFile> sources, {
    PaperSize paperSize = PaperSize.a4,
    PdfRasterizer rasterizer = const DefaultPdfRasterizer(),
    double dpi = defaultRasterDpi,
  }) async {
    final pages = <LayoutPage>[];
    var pageIndex = 0;
    Directory? tempDir;

    for (final source in sources) {
      if (!source.isPdf) continue;
      try {
        final file = File(source.path);
        if (!await file.exists()) continue;
        final fileBytes = await file.readAsBytes();
        if (fileBytes.isEmpty) continue;

        tempDir ??= Directory.systemTemp.createTempSync('ngeprint_pdf_');

        await for (final raster in rasterizer.raster(fileBytes, dpi: dpi)) {
          final pngBytes = await raster.toPng();
          final tempFilePath =
              '${tempDir.path}/page_${pageIndex}_${IdGenerator.nextId()}.png';
          final tempFile = File(tempFilePath);
          await tempFile.writeAsBytes(pngBytes);

          final widthPx = raster.width;
          final heightPx = raster.height;
          final aspectRatio = heightPx > 0 ? widthPx / heightPx : 1.0;

          final rect = LayoutGeometry.fitContainTopLeft(
            pageWidthMm: paperSize.widthMm,
            pageHeightMm: paperSize.heightMm,
            sourceAspectRatio: aspectRatio,
          );

          pages.add(
            LayoutPage(
              index: pageIndex,
              elements: [
                LayoutElement(
                  id: IdGenerator.nextId(),
                  type: LayoutElementType.image,
                  sourcePath: tempFilePath,
                  pageIndex: pageIndex,
                  xMm: rect.x,
                  yMm: rect.y,
                  widthMm: rect.width,
                  heightMm: rect.height,
                  sizeMode: ElementSizeMode.fitToPage,
                  sourcePixelWidth: widthPx,
                  sourcePixelHeight: heightPx,
                ),
              ],
            ),
          );
          pageIndex += 1;
        }
      } catch (_) {
        // Skip corrupted or unreadable PDF files
      }
    }

    if (pages.isEmpty) return null;
    return LayoutDocument(paperSize: paperSize, pages: pages);
  }
}

