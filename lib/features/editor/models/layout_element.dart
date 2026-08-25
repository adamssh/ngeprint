enum LayoutElementType { image }

enum ElementSizeMode { fitToPage, manual }

class LayoutElement {
  const LayoutElement({
    required this.id,
    required this.type,
    required this.sourcePath,
    required this.pageIndex,
    required this.xMm,
    required this.yMm,
    required this.widthMm,
    required this.heightMm,
    required this.sizeMode,
    this.sourcePixelWidth,
    this.sourcePixelHeight,
    this.rotationDeg = 0,
  });

  final String id;
  final LayoutElementType type;
  final String sourcePath;
  final int pageIndex;

  final double xMm;
  final double yMm;
  final double widthMm;
  final double heightMm;

  final ElementSizeMode sizeMode;
  final int? sourcePixelWidth;
  final int? sourcePixelHeight;
  final double rotationDeg;

  double? get sourceAspectRatio {
    final width = sourcePixelWidth;
    final height = sourcePixelHeight;
    if (width == null || height == null || height <= 0 || width <= 0) {
      return null;
    }
    return width / height;
  }

  bool get isImage => type == LayoutElementType.image;

  LayoutElement copyWith({
    String? id,
    LayoutElementType? type,
    String? sourcePath,
    int? pageIndex,
    double? xMm,
    double? yMm,
    double? widthMm,
    double? heightMm,
    ElementSizeMode? sizeMode,
    int? sourcePixelWidth,
    int? sourcePixelHeight,
    double? rotationDeg,
  }) {
    return LayoutElement(
      id: id ?? this.id,
      type: type ?? this.type,
      sourcePath: sourcePath ?? this.sourcePath,
      pageIndex: pageIndex ?? this.pageIndex,
      xMm: xMm ?? this.xMm,
      yMm: yMm ?? this.yMm,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      sizeMode: sizeMode ?? this.sizeMode,
      sourcePixelWidth: sourcePixelWidth ?? this.sourcePixelWidth,
      sourcePixelHeight: sourcePixelHeight ?? this.sourcePixelHeight,
      rotationDeg: rotationDeg ?? this.rotationDeg,
    );
  }
}
