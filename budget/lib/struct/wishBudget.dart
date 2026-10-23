/// Calendar days, independent of 23/25-hour daylight-saving days.
int coolingDaysRemaining(DateTime created, DateTime now) {
  final start = DateTime.utc(created.year, created.month, created.day);
  final today = DateTime.utc(now.year, now.month, now.day);
  return (30 - today.difference(start).inDays).clamp(0, 30);
}

/// Exact minor units; the manual check accepts up to two decimal places.
int? parseBudgetCents(String input) {
  final text = input.trim();
  if (!RegExp(r'^\d{1,12}(\.\d{1,2})?$').hasMatch(text)) return null;
  final parts = text.split('.');
  return int.parse(parts[0]) * 100 +
      (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
}

int budgetAfterPurchase({
  required int available,
  required int reserved,
  required int necessary,
  required int price,
}) =>
    available - reserved - necessary - price;
