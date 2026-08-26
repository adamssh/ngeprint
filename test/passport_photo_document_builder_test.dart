import 'package:flutter_test/flutter_test.dart';

import 'package:ngeprint/core/constants/paper_sizes.dart';
import 'package:ngeprint/core/constants/photo_size_presets.dart';
import 'package:ngeprint/features/editor/logic/passport_photo_document_builder.dart';
import 'package:ngeprint/features/editor/models/passport_photo_config.dart';

void main() {
  test('Menyusun 1 pas foto pada posisi awal dengan margin yang tepat', () {
    const config = PassportPhotoConfig(
      sourcePath: '/path/to/photo.jpg',
      paperSize: PaperSize.a4,
      preset: PhotoSizePreset.threeByFour,
      quantity: 1,
    );

    final document = PassportPhotoDocumentBuilder.build(config);

    expect(document.pageCount, 1);
    final page = document.pageAt(0)!;
    expect(page.elements.length, 1);

    final element = page.elements.first;
    expect(element.widthMm, 30);
    expect(element.heightMm, 40);
    expect(element.yMm, 10); // Margin atas 10 mm
    expect(element.xMm, greaterThanOrEqualTo(10));
  });

  test(
      'Menyusun 4 pas foto secara horizontal dengan jarak tepat 0,5 cm (5 mm)',
      () {
    const config = PassportPhotoConfig(
      sourcePath: '/path/to/photo.jpg',
      paperSize: PaperSize.a4,
      preset: PhotoSizePreset.threeByFour,
      quantity: 4,
    );

    final document = PassportPhotoDocumentBuilder.build(config);

    expect(document.pageCount, 1);
    final page = document.pageAt(0)!;
    expect(page.elements.length, 4);

    for (var i = 0; i < 4; i++) {
      final element = page.elements[i];
      expect(element.widthMm, 30);
      expect(element.heightMm, 40);
      expect(element.yMm, 10); // Semua foto pada baris pertama

      if (i > 0) {
        final prevElement = page.elements[i - 1];
        // Jarak antar foto = posisi kiri foto sekarang - posisi kanan foto sebelumnya
        final gap = element.xMm - (prevElement.xMm + prevElement.widthMm);
        expect(gap, closeTo(5.0, 0.001)); // Tepat 5 mm (0,5 cm)
      }
    }
  });

  test('Turun baris dengan jarak 0,5 cm jika lebar halaman tidak mencukupi', () {
    // Pada A4 (lebar 210, margin 10x2 = 190 mm), foto 3x4 (30+5 = 35 mm per kolom) muat 5 foto per baris.
    // Jika jumlah = 7, maka foto ke-6 dan ke-7 turun ke baris kedua.
    const config = PassportPhotoConfig(
      sourcePath: '/path/to/photo.jpg',
      paperSize: PaperSize.a4,
      preset: PhotoSizePreset.threeByFour,
      quantity: 7,
    );

    final document = PassportPhotoDocumentBuilder.build(config);

    expect(document.pageCount, 1);
    final page = document.pageAt(0)!;
    expect(page.elements.length, 7);

    // 5 foto pertama di baris 0 (y = 10 mm)
    for (var i = 0; i < 5; i++) {
      expect(page.elements[i].yMm, 10);
    }

    // Foto ke-6 dan ke-7 di baris 1: y = 10 + 40 (tinggi) + 5 (jarak) = 55 mm
    expect(page.elements[5].yMm, closeTo(55.0, 0.001));
    expect(page.elements[6].yMm, closeTo(55.0, 0.001));

    // Jarak horizontal baris 2 tetap 5 mm
    final gapRow2 = page.elements[6].xMm -
        (page.elements[5].xMm + page.elements[5].widthMm);
    expect(gapRow2, closeTo(5.0, 0.001));
  });

  test('Membagi ke halaman baru jika kapasitas 1 halaman terlampaui', () {
    // Kapasitas 3x4 di A4 adalah 5 kolom x 6 baris = 30 foto per halaman
    const config = PassportPhotoConfig(
      sourcePath: '/path/to/photo.jpg',
      paperSize: PaperSize.a4,
      preset: PhotoSizePreset.threeByFour,
      quantity: 35,
    );

    final document = PassportPhotoDocumentBuilder.build(config);

    expect(document.pageCount, 2);
    expect(document.pageAt(0)!.elements.length, 30);
    expect(document.pageAt(1)!.elements.length, 5);
  });

  test('Mendukung preset ukuran foto 2R, 3R, 4R, 5R, 6R dan kertas F4', () {
    const config3R = PassportPhotoConfig(
      sourcePath: '/path/to/photo.jpg',
      paperSize: PaperSize.f4,
      preset: PhotoSizePreset.threeR,
      quantity: 2,
    );

    final doc3R = PassportPhotoDocumentBuilder.build(config3R);
    expect(doc3R.paperSize, PaperSize.f4);
    expect(doc3R.pageAt(0)!.elements.length, 2);
    expect(doc3R.pageAt(0)!.elements.first.widthMm, 89);
    expect(doc3R.pageAt(0)!.elements.first.heightMm, 127);

    // Jarak antar foto 3R tetap 5 mm
    final gap = doc3R.pageAt(0)!.elements[1].xMm -
        (doc3R.pageAt(0)!.elements[0].xMm +
            doc3R.pageAt(0)!.elements[0].widthMm);
    expect(gap, closeTo(5.0, 0.001));
  });
}

