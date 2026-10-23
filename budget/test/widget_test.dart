// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:budget/widgets/wishReview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Budget worksheet validates inputs and clears stale results',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
      body: WishBudgetCheck(price: 600),
    )));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('yubai-money-error'), findsNWidgets(3));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '2000');
    await tester.enterText(fields.at(1), '800');
    await tester.enterText(fields.at(2), '500');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('yubai-budget-ok'), findsOneWidget);
    await tester.enterText(fields.at(0), '1000');
    await tester.pump();
    expect(find.text('yubai-budget-ok'), findsNothing);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('yubai-budget-short'), findsOneWidget);
    expect(find.text('yubai-no-transaction'), findsOneWidget);
  });
}
