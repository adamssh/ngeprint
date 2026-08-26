import '../../../core/constants/paper_sizes.dart';
import '../../../core/services/image_metadata_service.dart';
import '../../../core/utils/id_generator.dart';
import '../../file_import/models/imported_file.dart';
import '../models/layout_document.dart';
import '../models/layout_element.dart';
import '../models/layout_page.dart';
import 'layout_geometry.dart';

abstract final class ImagePrintDocumentBuilder {
  static Future<LayoutDocument?> build(
    List<ImportedFile> sources, {
    PaperSize paperSize = PaperSize.a4,
  }) async {
    final pages = <LayoutPage>[];
    var pageIndex = 0;

    for (final source in sources) {
      if (!source.isImage) continue;
      final dimensions =
          await ImageMetadataService.readDimensions(source.path);
      final rect = LayoutGeometry.fitContainTopLeft(
        pageWidthMm: paperSize.widthMm,
        pageHeightMm: paperSize.heightMm,
        sourceAspectRatio: dimensions?.aspectRatio,
      );
      pages.add(
        LayoutPage(
          index: pageIndex,
          elements: [
            LayoutElement(
              id: IdGenerator.nextId(),
              type: LayoutElementType.image,
              sourcePath: source.path,
              pageIndex: pageIndex,
              xMm: rect.x,
              yMm: rect.y,
              widthMm: rect.width,
              heightMm: rect.height,
              sizeMode: ElementSizeMode.fitToPage,
              sourcePixelWidth: dimensions?.widthPx,
              sourcePixelHeight: dimensions?.heightPx,
            ),
          ],
        ),
      );
      pageIndex += 1;
    }

    if (pages.isEmpty) return null;
    return LayoutDocument(paperSize: paperSize, pages: pages);
  }
}
