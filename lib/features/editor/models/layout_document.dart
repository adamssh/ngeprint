import '../../../core/constants/paper_sizes.dart';
import 'layout_page.dart';

class LayoutDocument {
  const LayoutDocument({required this.paperSize, required this.pages});

  final PaperSize paperSize;
  final List<LayoutPage> pages;

  double get pageWidthMm => paperSize.widthMm;

  double get pageHeightMm => paperSize.heightMm;

  int get pageCount => pages.length;

  LayoutPage? pageAt(int index) {
    if (index < 0 || index >= pages.length) return null;
    return pages[index];
  }

  LayoutDocument copyWith({
    PaperSize? paperSize,
    List<LayoutPage>? pages,
  }) {
    return LayoutDocument(
      paperSize: paperSize ?? this.paperSize,
      pages: pages ?? this.pages,
    );
  }
}
