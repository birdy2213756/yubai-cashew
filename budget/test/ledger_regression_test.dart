import 'dart:ffi';
import 'dart:io';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/wishBudget.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final dll = Platform.environment['YUBAI_SQLITE_DLL'];
  if (Platform.isWindows && dll != null) {
    open.overrideFor(OperatingSystem.windows, () => DynamicLibrary.open(dll));
  }
  late FinanceDatabase db;
  late AllWallets wallets;
  late Directory folder;
  late File file;

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('yubai-ledger-test-');
    file = File('${folder.path}/ledger.sqlite');
    db = FinanceDatabase(NativeDatabase(file));
    appStateSettings = {
      'selectedWalletPk': '0',
      'currentUserEmail': '',
      'cachedCurrencyExchange': {}
    };
    await db.into(db.wallets).insert(WalletsCompanion.insert(
        walletPk: const Value('0'),
        name: 'Cash',
        order: 0,
        currency: const Value('cny')));
    final list = await db.getAllWallets();
    wallets = AllWallets(
        list: list, indexedByPk: {for (final w in list) w.walletPk: w});
    await db.into(db.categories).insert(CategoriesCompanion.insert(
        categoryPk: const Value('food'), name: 'Food', order: 0));
    await db.into(db.objectives).insert(ObjectivesCompanion.insert(
        objectivePk: const Value('wish'),
        name: 'Camera',
        amount: 600,
        order: 0,
        income: const Value(true),
        dateCreated: Value(DateTime(2026, 10, 1))));
    for (final row in [
      ('meal', -120.0, false, true, DateTime(2026, 10, 5), null),
      ('travel', -80.0, false, true, DateTime(2026, 10, 12), null),
      ('salary', 1000.0, true, true, DateTime(2026, 10, 1), null),
      ('pending', -50.0, false, false, DateTime(2026, 10, 13), null),
      ('previous-month', -20.0, false, true, DateTime(2026, 9, 30), null),
      ('savings', 200.0, true, true, DateTime(2026, 10, 15), 'wish'),
    ]) {
      await db.into(db.transactions).insert(TransactionsCompanion.insert(
            transactionPk: Value(row.$1),
            name: row.$1,
            amount: row.$2,
            note: '',
            categoryFk: 'food',
            income: Value(row.$3),
            paid: Value(row.$4),
            dateCreated: Value(row.$5),
            objectiveFk: Value(row.$6),
          ));
    }
  });
  tearDown(() async {
    await db.close();
    await folder.delete(recursive: true);
  });

  test('Original monthly budget total excludes unpaid and other months',
      () async {
    final total = await db
        .watchTotalOfBudget(
          allWallets: wallets,
          start: DateTime(2026, 10, 1),
          end: DateTime(2026, 10, 31),
          categoryFks: null,
          categoryFksExclude: null,
          budgetTransactionFilters: null,
          memberTransactionFilters: null,
          isIncome: false,
        )
        .first;
    expect(total, -200);
    expect(1000 + total!, 800); // 1000 budget, 200 spent.
  });
  test('Original category statistics match monthly spending', () async {
    final categories = await db
        .watchTotalSpentInEachCategoryInTimeRangeFromCategories(
          allWallets: wallets,
          start: DateTime(2026, 10, 1),
          end: DateTime(2026, 10, 31),
          categoryFks: ['food'],
          categoryFksExclude: null,
          budgetTransactionFilters: null,
          memberTransactionFilters: null,
          isIncome: false,
        )
        .first;
    expect(categories.length, 1);
    expect(categories.single.total, -200);
  });
  test('Original Goal savings and budget check do not create expenses',
      () async {
    final goal = await db.getObjective('wish').first;
    expect(await db.watchTotalTowardsObjective(wallets, goal).first, 200);
    final before = await db.select(db.transactions).get();
    expect(
        budgetAfterPurchase(
            available: 200000, reserved: 80000, necessary: 50000, price: 60000),
        10000);
    expect((await db.select(db.transactions).get()).length, before.length);
    expect(coolingDaysRemaining(goal.dateCreated, DateTime(2026, 10, 23)), 8);
  });
  test('Existing schema and Goal survive close, reopen and SQLite backup',
      () async {
    expect(db.schemaVersion, 46);
    final before = await db.getObjective('wish').first;
    await db.close();
    final backup = File('${folder.path}/backup.sqlite');
    await file.copy(backup.path);
    db = FinanceDatabase(NativeDatabase(backup));
    final after = await db.getObjective('wish').first;
    expect(after, before);
    expect((await db.select(db.transactions).get()).length, 6);
    expect(await db.watchTotalTowardsObjective(wallets, after).first, 200);
    expect(
        await db
            .customSelect('PRAGMA integrity_check')
            .getSingle()
            .then((r) => r.data.values.single),
        'ok');
  });
}
