import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngeprint/main.dart';

void main() {
  testWidgets('PrintAssistantApp renders HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PrintAssistantApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Print Assistant'), findsOneWidget);
    expect(find.text('Aksi Cepat'), findsOneWidget);
  });
}
