import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngeprint/core/constants/paper_sizes.dart';
import 'package:ngeprint/features/editor/logic/editor_session.dart';
import 'package:ngeprint/features/editor/models/layout_document.dart';
import 'package:ngeprint/features/editor/models/layout_element.dart';
import 'package:ngeprint/features/editor/models/layout_page.dart';
import 'package:ngeprint/features/editor/presentation/editor_screen.dart';
import 'package:ngeprint/features/file_import/models/import_mode.dart';

void main() {
  testWidgets('Editor menampilkan kanvas halaman dan tombol print',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(editorSessionProvider.notifier)
        .start(_buildSinglePageDocument());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: EditorScreen(mode: ImportMode.imagePrint)),
      ),
    );
    await tester.pump();

    expect(find.text('Cetak Gambar'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
    expect(find.byIcon(Icons.print_outlined), findsOneWidget);
    expect(find.text('A4'), findsOneWidget);
    expect(find.text('Ukuran Gambar'), findsOneWidget);
  });

  testWidgets('Sheet ukuran gambar menyediakan opsi fit dan manual',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(editorSessionProvider.notifier)
        .start(_buildSinglePageDocument());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: EditorScreen(mode: ImportMode.imagePrint)),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Ukuran Gambar'));
    await tester.pumpAndSettle();

    expect(find.text('Pas ke halaman'), findsOneWidget);
    expect(find.text('Ukuran manual'), findsOneWidget);
    expect(find.text('Terapkan'), findsOneWidget);
  });

  testWidgets(
      'Editor mode PDF hanya menampilkan pengaturan ukuran kertas dan tombol cetak',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(editorSessionProvider.notifier)
        .start(_buildSinglePageDocument());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: EditorScreen(mode: ImportMode.pdfPrint)),
      ),
    );
    await tester.pump();

    // Verifikasi judul dan elemen utama
    expect(find.text('Cetak PDF'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
    expect(find.byIcon(Icons.print_outlined), findsOneWidget);
    expect(find.byIcon(Icons.save_alt_rounded), findsOneWidget);

    // Verifikasi opsi pengaturan bawah: hanya ukuran kertas yang ada
    expect(find.text('A4'), findsOneWidget);
    expect(find.text('Ukuran Gambar'), findsNothing);
    expect(find.byIcon(Icons.rotate_right_rounded), findsNothing);

    // Verifikasi ganti ukuran kertas ke F4
    await tester.tap(find.text('A4'));
    await tester.pumpAndSettle();

    expect(find.text('F4'), findsOneWidget);
    await tester.tap(find.text('F4'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(find.text('F4'), findsOneWidget);
  });
}

LayoutDocument _buildSinglePageDocument() {
  return LayoutDocument(
    paperSize: PaperSize.a4,
    pages: [
      LayoutPage(
        index: 0,
        elements: [
          LayoutElement(
            id: 'el-0',
            type: LayoutElementType.image,
            sourcePath: '/dummy/image_0.jpg',
            pageIndex: 0,
            xMm: 0,
            yMm: 0,
            widthMm: 210,
            heightMm: 297,
            sizeMode: ElementSizeMode.fitToPage,
          ),
        ],
      ),
    ],
  );
}
