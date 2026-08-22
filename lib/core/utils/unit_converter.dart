import '../constants/app_constants.dart';

/// Central unit conversion service for physical dimensions (mm, cm, inch),
/// PDF points (72 points = 1 inch), and logical screen pixels.
class UnitConverter {
  UnitConverter._();

  /// Converts millimeters (mm) to PDF Points (72 dpi).
  static double mmToPoints(double mm) {
    return (mm / AppConstants.mmPerInch) * AppConstants.pdfPointsPerInch;
  }

  /// Converts PDF Points (72 dpi) to millimeters (mm).
  static double pointsToMm(double points) {
    return (points / AppConstants.pdfPointsPerInch) * AppConstants.mmPerInch;
  }

  /// Converts centimeters (cm) to PDF Points (72 dpi).
  static double cmToPoints(double cm) {
    return (cm / AppConstants.cmPerInch) * AppConstants.pdfPointsPerInch;
  }

  /// Converts PDF Points (72 dpi) to centimeters (cm).
  static double pointsToCm(double points) {
    return (points / AppConstants.pdfPointsPerInch) * AppConstants.cmPerInch;
  }

  /// Converts inches to PDF Points (72 dpi).
  static double inchToPoints(double inch) {
    return inch * AppConstants.pdfPointsPerInch;
  }

  /// Converts PDF Points (72 dpi) to inches.
  static double pointsToInch(double points) {
    return points / AppConstants.pdfPointsPerInch;
  }

  /// Converts millimeters (mm) to screen logical pixels using a given scale factor.
  /// Scale factor is (available canvas pixels) / (page physical width in points or mm).
  static double mmToPx(double mm, double scaleFactorPointsToPx) {
    return mmToPoints(mm) * scaleFactorPointsToPx;
  }

  /// Converts screen logical pixels to millimeters (mm) using a given scale factor.
  static double pxToMm(double px, double scaleFactorPointsToPx) {
    if (scaleFactorPointsToPx == 0) return 0.0;
    return pointsToMm(px / scaleFactorPointsToPx);
  }
}

