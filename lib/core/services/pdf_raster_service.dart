import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

abstract interface class PdfRasterizer {
  Stream<PdfRaster> raster(
    Uint8List document, {
    List<int>? pages,
    double dpi = PdfPageFormat.inch,
  });
}

class DefaultPdfRasterizer implements PdfRasterizer {
  const DefaultPdfRasterizer();

  @override
  Stream<PdfRaster> raster(
    Uint8List document, {
    List<int>? pages,
    double dpi = PdfPageFormat.inch,
  }) {
    return Printing.raster(document, pages: pages, dpi: dpi);
  }
}

