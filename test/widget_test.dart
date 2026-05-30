import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quki_notes/app.dart';

void main() {
  testWidgets('Phase 0 scaffold smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: QuKiNotesApp()),
    );
    expect(find.text('QuKi-Notes — Phase 0 scaffold'), findsOneWidget);
  });
}
