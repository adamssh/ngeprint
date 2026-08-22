import 'package:flutter_test/flutter_test.dart';
import 'package:ngeprint/core/utils/unit_converter.dart';

void main() {
  group('UnitConverter', () {
    test('converts mm to points accurately', () {
      // 25.4 mm = 1 inch = 72 points
      final points = UnitConverter.mmToPoints(25.4);
      expect(points, closeTo(72.0, 0.001));
    });

    test('converts points to mm accurately', () {
      // 72 points = 25.4 mm
      final mm = UnitConverter.pointsToMm(72.0);
      expect(mm, closeTo(25.4, 0.001));
    });

    test('converts cm to points accurately', () {
      // 2.54 cm = 1 inch = 72 points
      final points = UnitConverter.cmToPoints(2.54);
      expect(points, closeTo(72.0, 0.001));
    });

    test('converts points to cm accurately', () {
      final cm = UnitConverter.pointsToCm(72.0);
      expect(cm, closeTo(2.54, 0.001));
    });

    test('converts mm to screen pixels based on scale factor', () {
      // Scale factor 2.0 (2 px per point)
      // 25.4 mm = 72 points -> 144 px
      final px = UnitConverter.mmToPx(25.4, 2.0);
      expect(px, closeTo(144.0, 0.001));
    });

    test('converts screen pixels to mm based on scale factor', () {
      // Scale factor 2.0 (2 px per point)
      // 144 px -> 72 points -> 25.4 mm
      final mm = UnitConverter.pxToMm(144.0, 2.0);
      expect(mm, closeTo(25.4, 0.001));
    });
  });
}

