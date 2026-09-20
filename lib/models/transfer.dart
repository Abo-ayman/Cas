enum Currency { usd, syp, eur }

extension CurrencyInfo on Currency {
  String get code => switch (this) {
        Currency.usd => 'USD',
        Currency.syp => 'SYP',
        Currency.eur => 'EUR',
      };

  String get symbol => switch (this) {
        Currency.usd => '\$',
        Currency.syp => 'ل.س',
        Currency.eur => '€',
      };

  String get arabicName => switch (this) {
        Currency.usd => 'دولار أمريكي',
        Currency.syp => 'ليرة سورية',
        Currency.eur => 'يورو',
      };
}

class Transfer {
  final String id;
  final String name;
  final double amount;
  final Currency currency;
  final bool incoming;
  final DateTime date;

  const Transfer({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.incoming,
    required this.date,
  });
}
