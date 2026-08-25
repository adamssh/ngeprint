enum PhysicalUnit { millimeter, centimeter, inch }

extension PhysicalUnitInfo on PhysicalUnit {
  String get symbol => switch (this) {
        PhysicalUnit.millimeter => 'mm',
        PhysicalUnit.centimeter => 'cm',
        PhysicalUnit.inch => 'in',
      };

  double get millimetersPerUnit => switch (this) {
        PhysicalUnit.millimeter => 1,
        PhysicalUnit.centimeter => 10,
        PhysicalUnit.inch => UnitConverter.mmPerInch,
      };
}

abstract final class UnitConverter {
  static const double pointsPerInch = 72;
  static const double mmPerInch = 25.4;

  static double mmToPoints(double mm) => mm * pointsPerInch / mmPerInch;

  static double cmToPoints(double cm) => mmToPoints(cm * 10);

  static double inchToPoints(double inches) => inches * pointsPerInch;

  static double pointsToMm(double points) =>
      points * mmPerInch / pointsPerInch;

  static double pointsToCm(double points) => pointsToMm(points) / 10;

  static double pointsToInch(double points) => points / pointsPerInch;

  static double toPoints(double value, PhysicalUnit unit) => switch (unit) {
        PhysicalUnit.millimeter => mmToPoints(value),
        PhysicalUnit.centimeter => cmToPoints(value),
        PhysicalUnit.inch => inchToPoints(value),
      };

  static double fromPoints(double points, PhysicalUnit unit) => switch (unit) {
        PhysicalUnit.millimeter => pointsToMm(points),
        PhysicalUnit.centimeter => pointsToCm(points),
        PhysicalUnit.inch => pointsToInch(points),
      };

  static double toMillimeters(double value, PhysicalUnit unit) =>
      value * unit.millimetersPerUnit;

  static double fromMillimeters(double millimeters, PhysicalUnit unit) =>
      millimeters / unit.millimetersPerUnit;
}
