import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:vector_math/vector_math_64.dart' as vm;

import '../../../core/utils/unit_converter.dart';
import '../../editor/models/layout_document.dart';
import '../../editor/models/layout_element.dart';

class PdfGenerationResult {
  const PdfGenerationResult({
    required this.bytes,
    required this.unavailableSourcePaths,
  });

  final Uint8List bytes;
  final List<String> unavailableSourcePaths;
}

abstract final class PdfLayoutGenerator {
  static Future<PdfGenerationResult> generate(LayoutDocument document) async {
    final doc = pw.Document();
    final pageWidthPt = UnitConverter.mmToPoints(document.pageWidthMm);
    final pageHeightPt = UnitConverter.mmToPoints(document.pageHeightMm);

    final sourcePaths = <String>{
      for (final page in document.pages)
        for (final element in page.elements) element.sourcePath,
    };
    final images = <String, PdfImage?>{};
    for (final path in sourcePaths) {
      images[path] = await _createPdfImage(doc, path);
    }

    for (final page in document.pages) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(pageWidthPt, pageHeightPt),
          margin: pw.EdgeInsets.zero,
          build: (context) => pw.CustomPaint(
            size: PdfPoint(pageWidthPt, pageHeightPt),
            painter: (canvas, _) => _paintPage(
              canvas,
              page.elements,
              images,
              pageHeightPt,
            ),
          ),
        ),
      );
    }

    final bytes = await doc.save();
    final unavailable =
        images.entries.where((e) => e.value == null).map((e) => e.key).toList();
    return PdfGenerationResult(bytes: bytes, unavailableSourcePaths: unavailable);
  }

  static void _paintPage(
    PdfGraphics canvas,
    List<LayoutElement> elements,
    Map<String, PdfImage?> images,
    double pageHeightPt,
  ) {
    for (final element in elements) {
      final x = UnitConverter.mmToPoints(element.xMm);
      final width = UnitConverter.mmToPoints(element.widthMm);
      final height = UnitConverter.mmToPoints(element.heightMm);
      final y = pageHeightPt -
          UnitConverter.mmToPoints(element.yMm) -
          height;

      final image = images[element.sourcePath];
      if (image == null) {
        _paintPlaceholder(canvas, x, y, width, height);
        continue;
      }

      final quarterTurns = ((element.rotationDeg % 360) ~/ 90) % 4;
      if (quarterTurns == 0) {
        canvas.drawImage(image, x, y, width, height);
        continue;
      }
      canvas.saveContext();
      canvas.setTransform(_rotationMatrix(x, y, width, height, quarterTurns));
      canvas.drawImage(image, x, y, width, height);
      canvas.restoreContext();
    }
  }

  static vm.Matrix4 _rotationMatrix(
    double x,
    double y,
    double width,
    double height,
    int quarterTurns,
  ) {
    final centerX = x + width / 2;
    final centerY = y + height / 2;
    final angleRad = -quarterTurns * math.pi / 2;
    return vm.Matrix4.identity()
      ..translateByDouble(centerX, centerY, 0, 1)
      ..rotateZ(angleRad)
      ..translateByDouble(-centerX, -centerY, 0, 1);
  }

  static void _paintPlaceholder(
    PdfGraphics canvas,
    double x,
    double y,
    double width,
    double height,
  ) {
    canvas.saveContext();
    canvas.setColor(const PdfColor(0.93, 0.93, 0.93));
    canvas.drawRect(x, y, width, height);
    canvas.fillPath();
    canvas.setStrokeColor(const PdfColor(0.7, 0.7, 0.7));
    canvas.setLineWidth(0.5);
    canvas.drawRect(x, y, width, height);
    canvas.strokePath();
    canvas.restoreContext();
  }

  static Future<PdfImage?> _createPdfImage(pw.Document doc, String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      if (_isJpeg(bytes)) {
        return PdfImage.jpeg(doc.document, image: bytes);
      }
      return await _rasterizeViaPlatformCodec(doc.document, bytes);
    } catch (_) {
      return null;
    }
  }

  static bool _isJpeg(Uint8List bytes) =>
      bytes.length > 3 && bytes[0] == 0xFF && bytes[1] == 0xD8;

  static Future<PdfImage?> _rasterizeViaPlatformCodec(
    PdfDocument pdfDocument,
    Uint8List bytes,
  ) async {
    ui.Image? image;
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    try {
      buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      codec = await descriptor.instantiateCodec();
      final frame = await codec.getNextFrame();
      image = frame.image;
      final data = await image.toByteData(
        format: ui.ImageByteFormat.rawStraightRgba,
      );
      if (data == null) return null;
      return PdfImage(
        pdfDocument,
        image: data.buffer.asUint8List(),
        width: image.width,
        height: image.height,
      );
    } catch (_) {
      return null;
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }
}
