class RectMm {
  const RectMm({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;
}

abstract final class LayoutGeometry {
  static RectMm fitContainCentered({
    required double pageWidthMm,
    required double pageHeightMm,
    double? sourceAspectRatio,
  }) {
    if (sourceAspectRatio == null || sourceAspectRatio <= 0) {
      return RectMm(
        x: 0,
        y: 0,
        width: pageWidthMm,
        height: pageHeightMm,
      );
    }
    final pageAspect = pageWidthMm / pageHeightMm;
    double width;
    double height;
    if (sourceAspectRatio >= pageAspect) {
      width = pageWidthMm;
      height = width / sourceAspectRatio;
    } else {
      height = pageHeightMm;
      width = height * sourceAspectRatio;
    }
    return RectMm(
      x: (pageWidthMm - width) / 2,
      y: (pageHeightMm - height) / 2,
      width: width,
      height: height,
    );
  }

  static RectMm manualCentered({
    required double pageWidthMm,
    required double pageHeightMm,
    required double widthMm,
    required double heightMm,
  }) {
    var width = widthMm;
    var height = heightMm;
    if (width <= 0 || height <= 0) {
      return fitContainCentered(
        pageWidthMm: pageWidthMm,
        pageHeightMm: pageHeightMm,
      );
    }
    if (width > pageWidthMm || height > pageHeightMm) {
      final scale =
          (pageWidthMm / width) < (pageHeightMm / height)
              ? pageWidthMm / width
              : pageHeightMm / height;
      width *= scale;
      height *= scale;
    }
    return RectMm(
      x: (pageWidthMm - width) / 2,
      y: (pageHeightMm - height) / 2,
      width: width,
      height: height,
    );
  }
}
