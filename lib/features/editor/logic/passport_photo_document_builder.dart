import 'dart:math' as math;

import '../../../core/utils/id_generator.dart';
import '../models/layout_document.dart';
import '../models/layout_element.dart';
import '../models/layout_page.dart';
import '../models/passport_photo_config.dart';

abstract final class PassportPhotoDocumentBuilder {
  static const double gapMm = 5.0; // 0.5 cm antar foto
  static const double marginMm = 5.0; // 0.5 cm dari tepi kertas

  static LayoutDocument build(PassportPhotoConfig config) {
    final paperWidth = config.paperSize.widthMm;
    final paperHeight = config.paperSize.heightMm;
    final photoWidth = config.preset.widthMm;
    final photoHeight = config.preset.heightMm;

    final availableWidth = paperWidth - 2 * marginMm;
    final availableHeight = paperHeight - 2 * marginMm;

    final cols = math.max(
      1,
      ((availableWidth + gapMm) / (photoWidth + gapMm)).floor(),
    );
    final rows = math.max(
      1,
      ((availableHeight + gapMm) / (photoHeight + gapMm)).floor(),
    );
    final capacityPerPage = cols * rows;

    final totalPhotos = math.max(1, config.quantity);
    final totalPages = (totalPhotos / capacityPerPage).ceil();

    const startX = marginMm; // Posisi pojok kiri atas
    const startY = marginMm; // Posisi pojok kiri atas

    final pages = <LayoutPage>[];
    var placed = 0;

    for (var pageIdx = 0; pageIdx < totalPages; pageIdx++) {
      final elements = <LayoutElement>[];
      final photosOnPage = math.min(capacityPerPage, totalPhotos - placed);

      for (var i = 0; i < photosOnPage; i++) {
        final r = i ~/ cols;
        final c = i % cols;
        final x = startX + c * (photoWidth + gapMm);
        final y = startY + r * (photoHeight + gapMm);

        elements.add(
          LayoutElement(
            id: IdGenerator.nextId(),
            type: LayoutElementType.image,
            sourcePath: config.sourcePath,
            pageIndex: pageIdx,
            xMm: x,
            yMm: y,
            widthMm: photoWidth,
            heightMm: photoHeight,
            sizeMode: ElementSizeMode.manual,
            sourcePixelWidth: config.sourcePixelWidth,
            sourcePixelHeight: config.sourcePixelHeight,
          ),
        );
      }
      pages.add(LayoutPage(index: pageIdx, elements: elements));
      placed += photosOnPage;
    }

    return LayoutDocument(paperSize: config.paperSize, pages: pages);
  }
}

