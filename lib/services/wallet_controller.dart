import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transfer.dart';

class WalletController extends ChangeNotifier {
  static const initialBalances = <Currency, double>{
    Currency.usd: 500,
    Currency.syp: 2500000,
    Currency.eur: 10,
  };

  final Map<Currency, double> balances = Map.of(initialBalances);
  final List<Transfer> transfers = [];

  Currency selectedCurrency = Currency.usd;
  bool hidden = false;
  String accountName = 'محمد علي العباس';

  double get selectedBalance => balances[selectedCurrency] ?? 0;

  void selectCurrency(Currency value) {
    selectedCurrency = value;
    notifyListeners();
  }

  void toggleHidden() {
    hidden = !hidden;
    notifyListeners();
  }

  bool send(String name, double amount) {
    if (amount <= 0 || amount > selectedBalance) return false;

    balances[selectedCurrency] = selectedBalance - amount;
    transfers.insert(
      0,
      Transfer(
        id: _id(),
        name: name,
        amount: amount,
        currency: selectedCurrency,
        incoming: false,
        date: DateTime.now(),
      ),
    );

    _restoreIfEmpty();
    _persist();
    notifyListeners();
    return true;
  }

  void receive(String name, double amount) {
    if (amount <= 0) return;

    balances[selectedCurrency] = selectedBalance + amount;
    transfers.insert(
      0,
      Transfer(
        id: _id(),
        name: name,
        amount: amount,
        currency: selectedCurrency,
        incoming: true,
        date: DateTime.now(),
      ),
    );
    _persist();
    notifyListeners();
  }

  void resetDemoBalances() {
    balances
      ..clear()
      ..addAll(initialBalances);
    _persist();
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    accountName = prefs.getString('account_name') ?? accountName;

    for (final currency in Currency.values) {
      final stored = prefs.getDouble('balance_${currency.code.toLowerCase()}');
      balances[currency] = stored ?? initialBalances[currency]!;
    }

    final raw = prefs.getString('transfers');
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        transfers
          ..clear()
          ..addAll(
            list.map((item) {
              final map = Map<String, dynamic>.from(item as Map);
              return Transfer(
                id: map['id'] as String,
                name: map['name'] as String,
                amount: (map['amount'] as num).toDouble(),
                currency: Currency.values.byName(map['currency'] as String),
                incoming: map['incoming'] as bool,
                date: DateTime.parse(map['date'] as String),
              );
            }),
          );
      } catch (_) {
        transfers.clear();
      }
    }
    notifyListeners();
  }

  Future<void> saveAccountName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('account_name', accountName);
  }

  Future<void> clearHistory() async {
    transfers.clear();
    await _persist();
    notifyListeners();
  }

  void _restoreIfEmpty() {
    if ((balances[selectedCurrency] ?? 0) <= 0) {
      balances[selectedCurrency] = initialBalances[selectedCurrency]!;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    for (final currency in Currency.values) {
      await prefs.setDouble(
        'balance_${currency.code.toLowerCase()}',
        balances[currency]!,
      );
    }
    await prefs.setString(
      'transfers',
      jsonEncode(
        transfers
            .map(
              (t) => {
                'id': t.id,
                'name': t.name,
                'amount': t.amount,
                'currency': t.currency.name,
                'incoming': t.incoming,
                'date': t.date.toIso8601String(),
              },
            )
            .toList(),
      ),
    );
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString().substring(4);
}
