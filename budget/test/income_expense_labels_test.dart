import 'package:budget/colors.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/incomeExpenseTabSelector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('YubaiSansSC')
          ..addFont(rootBundle.load('assets/fonts/YubaiSansSC-Regular.otf')))
        .load();
  });

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('Chinese tabs stay complete at $brightness / $scale',
          (tester) async {
        appStateSettings = {
          'font': 'YubaiSansSC',
          'locale': 'zh',
          'materialYou': true,
          'outlinedIcons': false,
          'increaseTextContrast': false,
        };
        final selected = <bool>[];
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(brightness: brightness, extensions: [
            AppColors(colors: {
              'black':
                  brightness == Brightness.dark ? Colors.white : Colors.black,
              'incomeAmount': Colors.green,
              'expenseAmount': Colors.red,
            }),
          ]),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 320,
                  child: Row(children: [
                    Expanded(
                      flex: 2,
                      child: IncomeExpenseTabSelector(
                        initialTabIsIncome: false,
                        expenseLabel: '支出',
                        incomeLabel: '收入',
                        onTabChanged: selected.add,
                      ),
                    ),
                    const Expanded(
                        child: ExpenseIncomeSelectorLabel(
                      selectedIncome: false,
                      showIcons: false,
                      isIncome: true,
                      label: '转账',
                      customIcon: Icon(Icons.compare_arrows),
                    )),
                  ]),
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        void checkLabels() {
          for (final label in ['支出', '收入', '转账']) {
            expect(find.text(label), findsOneWidget);
            final paragraph = tester.renderObject<RenderParagraph>(
                find.descendant(
                    of: find.text(label), matching: find.byType(RichText)));
            expect(paragraph.didExceedMaxLines, isFalse);
            expect(paragraph.size.height, greaterThan(0));
          }
          expect(tester.takeException(), isNull);
        }

        checkLabels();
        await tester.tap(find.text('收入'));
        await tester.pumpAndSettle();
        checkLabels();
        await tester.tap(find.text('支出'));
        await tester.pumpAndSettle();
        checkLabels();
        expect(selected, [true, false]);
      });
    }
  }
}
