import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ngeprint/app.dart';

void main() {
  testWidgets('Home menampilkan tiga menu cetak utama', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NgeprintApp()));
    await tester.pump();

    expect(find.text('Cetak Gambar'), findsOneWidget);
    expect(find.text('Cetak PDF'), findsOneWidget);
    expect(find.text('Cetak Pas Foto'), findsOneWidget);
  });
}
