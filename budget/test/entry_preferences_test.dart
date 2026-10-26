import 'package:budget/struct/yubaiEntryPreferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('existing users start category first without changing ledger settings', () {
    final settings = <String, dynamic>{
      'askForTransactionTitle': true,
      'selectedWalletPk': 'bank',
      'locale': 'zh',
      'theme': 'dark',
    };
    expect(migrateYubaiEntryPreferences(settings), isTrue);
    expect(settings['askForTransactionTitle'], isFalse);
    expect(settings['yubaiEntryFlowVersion'], 1);
    expect(settings['selectedWalletPk'], 'bank');
    expect(settings['locale'], 'zh');
    expect(settings['theme'], 'dark');
  });

  test('already disabled name prompt stays disabled', () {
    final settings = <String, dynamic>{'askForTransactionTitle': false};
    migrateYubaiEntryPreferences(settings);
    expect(settings['askForTransactionTitle'], isFalse);
  });

  test('a later choice to enter name first survives the next startup', () {
    final settings = <String, dynamic>{};
    migrateYubaiEntryPreferences(settings);
    settings['askForTransactionTitle'] = true;
    expect(migrateYubaiEntryPreferences(settings), isFalse);
    expect(settings['askForTransactionTitle'], isTrue);
  });

  test('restoring settings that have migrated does not migrate twice', () {
    final settings = <String, dynamic>{
      'yubaiEntryFlowVersion': 1,
      'askForTransactionTitle': false,
      'selectedWalletPk': 'restored',
    };
    final original = Map<String, dynamic>.from(settings);
    expect(migrateYubaiEntryPreferences(settings), isFalse);
    expect(settings, original);
  });
}
