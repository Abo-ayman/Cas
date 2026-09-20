import 'package:flutter/material.dart';

import '../models/transfer.dart';
import '../services/wallet_controller.dart';
import '../theme/app_theme.dart';
import 'transfer_tile.dart';

class CurrencySelector extends StatelessWidget {
  final WalletController wallet;

  const CurrencySelector({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Currency.values.map((currency) {
        final selected = wallet.selectedCurrency == currency;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              onTap: () => wallet.selectCurrency(currency),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(.20)
                      : Colors.white.withOpacity(.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? AppColors.accent.withOpacity(.65)
                        : Colors.white.withOpacity(.05),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currency.code,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: selected ? Colors.white : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      child: Text(
                        wallet.hidden
                            ? '••••'
                            : TransferTile.money(
                                wallet.balances[currency] ?? 0,
                                currency,
                              ),
                        style: TextStyle(
                          fontSize: 11,
                          color: selected ? Colors.white : Colors.white60,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
