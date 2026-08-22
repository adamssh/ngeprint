class AppConstants {
  static const String appName = 'Print Assistant';

  /// Standard PDF Points per inch (DPI)
  static const double pdfPointsPerInch = 72.0;

  /// Millimeters per inch
  static const double mmPerInch = 25.4;

  /// Centimeters per inch
  static const double cmPerInch = 2.54;

  /// Standard physical paper dimensions in millimeters (Width x Height in Portrait)
  static const Map<String, ({double widthMm, double heightMm})> paperSizesMm = {
    'A4': (widthMm: 210.0, heightMm: 297.0),
    'A5': (widthMm: 148.0, heightMm: 210.0),
    'Letter': (widthMm: 215.9, heightMm: 279.4),
    'Legal': (widthMm: 215.9, heightMm: 355.6),
    'F4': (widthMm: 210.0, heightMm: 330.0), // F4 / Folio standard in ID
  };

  /// Standard photo presets in millimeters (Width x Height in Portrait)
  static const Map<String, ({double widthMm, double heightMm})> photoPresetsMm = {
    '2x3': (widthMm: 20.0, heightMm: 30.0),
    '3x4': (widthMm: 30.0, heightMm: 40.0),
    '4x6': (widthMm: 40.0, heightMm: 60.0),
  };
}

