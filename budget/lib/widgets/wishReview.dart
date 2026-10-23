import 'package:budget/database/tables.dart';
import 'package:budget/struct/wishBudget.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';

class WishReview extends StatelessWidget {
  const WishReview({super.key, required this.objective});
  final Objective objective;

  @override
  Widget build(BuildContext context) {
    if (objective.type != ObjectiveType.goal) return const SizedBox.shrink();
    return TimerBuilder.periodic(const Duration(minutes: 1),
        builder: (context) {
      final remaining =
          coolingDaysRemaining(objective.dateCreated, DateTime.now());
      final colors = Theme.of(context).colorScheme;
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.secondaryContainer.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.primary.withOpacity(0.12)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('yubai-wish-review'.tr(),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text('yubai-created'.tr(namedArgs: {
            'date': DateFormat.yMMMd(context.locale.toString())
                .format(objective.dateCreated),
          })),
          const SizedBox(height: 8),
          Text(
              remaining == 0
                  ? 'yubai-cooling-done'.tr()
                  : 'yubai-cooling-left'.tr(namedArgs: {'days': '$remaining'}),
              style: TextStyle(
                  color: colors.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text('yubai-cooling-note'.tr(), style: const TextStyle(height: 1.5)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size(44, 48)),
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: Text('yubai-budget-check'.tr()),
            onPressed: () => openBottomSheet(
              context,
              WishBudgetCheck(price: objective.amount),
              fullSnap: true,
              useCustomController: true,
            ),
          ),
        ]),
      );
    });
  }
}

/// A read-only worksheet: no database or transaction writes.
class WishBudgetCheck extends StatefulWidget {
  const WishBudgetCheck({super.key, required this.price});
  final double price;
  @override
  State<WishBudgetCheck> createState() => _WishBudgetCheckState();
}

class _WishBudgetCheckState extends State<WishBudgetCheck> {
  final form = GlobalKey<FormState>();
  final available = TextEditingController();
  final reserved = TextEditingController();
  final necessary = TextEditingController();
  int? result;

  void selectAmount(String label, TextEditingController controller) {
    openBottomSheet(
        context,
        PopupFramework(
          title: label.tr(),
          child: SelectAmount(
            amountPassed: controller.text,
            allowZero: true,
            convertToMoney: false,
            decimals: 2,
            setSelectedAmount: (amount, _) {
              controller.text = amount.abs().toStringAsFixed(2);
              setState(() => result = null);
            },
            nextLabel: 'set-amount'.tr(),
            next: () => Navigator.pop(context),
          ),
        ),
        fullSnap: true,
        useCustomController: true);
  }

  @override
  void dispose() {
    available.dispose();
    reserved.dispose();
    necessary.dispose();
    super.dispose();
  }

  Widget field(String label, TextEditingController controller) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
              labelText: label.tr(),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: 'enter-amount'.tr(),
                icon: const Icon(Icons.calculate_outlined),
                onPressed: () => selectAmount(label, controller),
              )),
          validator: (value) => parseBudgetCents(value ?? '') == null
              ? 'yubai-money-error'.tr()
              : null,
          onChanged: (_) {
            if (result != null) setState(() => result = null);
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
        child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('yubai-budget-check'.tr(),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text('yubai-price'
                  .tr(namedArgs: {'amount': widget.price.toStringAsFixed(2)})),
              const SizedBox(height: 8),
              Text('yubai-budget-currency-note'.tr(),
                  style: const TextStyle(height: 1.5)),
              field('yubai-available', available),
              field('yubai-reserved', reserved),
              field('yubai-necessary', necessary),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(44, 48)),
                onPressed: () {
                  if (!form.currentState!.validate()) return;
                  setState(() => result = budgetAfterPurchase(
                        available: parseBudgetCents(available.text)!,
                        reserved: parseBudgetCents(reserved.text)!,
                        necessary: parseBudgetCents(necessary.text)!,
                        price: (widget.price * 100).round(),
                      ));
                },
                child: Text('yubai-calculate'.tr()),
              ),
              if (result != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                      (result! >= 0 ? 'yubai-budget-ok' : 'yubai-budget-short')
                          .tr(namedArgs: {
                        'amount': (result!.abs() / 100).toStringAsFixed(2)
                      }),
                      style: TextStyle(
                          color: result! >= 0 ? colors.primary : colors.error,
                          height: 1.5)),
                ),
              Text('yubai-no-transaction'.tr(),
                  style: const TextStyle(height: 1.5)),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('close'.tr())),
            ],
          )),
    ));
  }
}
