enum ImportMode { imagePrint, pdfPrint, passportPhoto }

extension ImportModeInfo on ImportMode {
  String get listTitle => switch (this) {
        ImportMode.imagePrint => 'Daftar Gambar',
        ImportMode.pdfPrint => 'Daftar PDF',
        ImportMode.passportPhoto => 'Daftar Pas Foto',
      };

  String get emptyTitle => switch (this) {
        ImportMode.imagePrint => 'Belum ada gambar',
        ImportMode.pdfPrint => 'Belum ada dokumen PDF',
        ImportMode.passportPhoto => 'Belum ada foto pas foto',
      };

  String get emptyHint => switch (this) {
        ImportMode.imagePrint =>
          'Pilih satu atau banyak gambar sekaligus untuk dicetak.',
        ImportMode.pdfPrint => 'Pilih dokumen PDF yang ingin dicetak.',
        ImportMode.passportPhoto =>
          'Pilih foto pas foto untuk diatur ukuran dan jumlahnya.',
      };

  String get continueActionLabel => switch (this) {
        ImportMode.imagePrint => 'Lanjut ke Pengaturan Cetak Gambar',
        ImportMode.pdfPrint => 'Lanjut ke Pengaturan Cetak PDF',
        ImportMode.passportPhoto => 'Lanjut ke Atur Ukuran Pas Foto',
      };
}
