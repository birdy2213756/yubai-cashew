import 'package:budget/struct/wishBudget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cooling period: creation, boundary and old Goals', () {
    final created = DateTime(2026, 10, 23, 23, 59);
    expect(coolingDaysRemaining(created, DateTime(2026, 10, 23)), 30);
    expect(coolingDaysRemaining(created, DateTime(2026, 10, 24)), 29);
    expect(coolingDaysRemaining(created, DateTime(2026, 11, 21)), 1);
    expect(coolingDaysRemaining(created, DateTime(2026, 11, 22)), 0);
    expect(coolingDaysRemaining(created, DateTime(2027, 1, 1)), 0);
    expect(coolingDaysRemaining(created, DateTime(2026, 10, 1)), 30);
  });
  test('Cooling period handles leap day and month boundaries', () {
    expect(
        coolingDaysRemaining(DateTime(2024, 2, 28), DateTime(2024, 3, 1)), 28);
    expect(
        coolingDaysRemaining(DateTime(2026, 12, 31), DateTime(2027, 1, 1)), 29);
  });
  test('Manual money parsing rejects invalid or imprecise values', () {
    expect(parseBudgetCents('0'), 0);
    expect(parseBudgetCents(' 12.3 '), 1230);
    expect(parseBudgetCents('0.01'), 1);
    for (final value in [
      '',
      '-1',
      'NaN',
      'Infinity',
      '1e3',
      '1.234',
      '1,000',
      '1000000000000'
    ]) {
      expect(parseBudgetCents(value), isNull, reason: value);
    }
  });
  test('Savings and essentials deducted once with exact cents', () {
    expect(
        budgetAfterPurchase(
            available: 200000, reserved: 80000, necessary: 50000, price: 60000),
        10000);
    expect(
        budgetAfterPurchase(
            available: 100000, reserved: 80000, necessary: 50000, price: 60000),
        -90000);
    expect(
        budgetAfterPurchase(
            available: 30, reserved: 10, necessary: 10, price: 10),
        0);
  });
}
