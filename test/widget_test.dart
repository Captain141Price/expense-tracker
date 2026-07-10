import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('App smoke test — renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ExpenseNotebookApp(),
      ),
    );
    // Verify the app initialises without throwing.
    expect(find.byType(ExpenseNotebookApp), findsOneWidget);

    // Advance the splash screen delay timer to resolve pending timer assertions.
    await tester.pump(const Duration(seconds: 2));
  });
}
